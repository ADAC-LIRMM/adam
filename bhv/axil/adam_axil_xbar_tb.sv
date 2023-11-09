`include "axi/assign.svh"
`include "vunit_defines.svh"

module adam_axil_xbar_tb;
    import adam_axil_master_bhv::*;
    import adam_axil_slave_bhv::*;

    localparam ADDR_WIDTH = 32;
    localparam DATA_WIDTH = 32;
    
    localparam NO_XBAR_SLAVES  = 4;
    localparam NO_XBAR_MASTERS = 4;

    localparam MAX_TRANS = 7;

    localparam CLK_PERIOD = 20ns;
    localparam RST_CYCLES = 5;

    localparam TA = 2ns;
    localparam TT = CLK_PERIOD - TA;

    localparam NO_TESTS = 1000;

    localparam STRB_WIDTH = DATA_WIDTH/8;

    typedef logic [ADDR_WIDTH-1:0] addr_t;
    typedef logic [2:0]            prot_t;       
    typedef logic [DATA_WIDTH-1:0] data_t;
    typedef logic [STRB_WIDTH-1:0] strb_t;
    typedef logic [1:0]            resp_t;

    typedef struct packed {
        int unsigned idx;
        addr_t start_addr;
        addr_t end_addr;
    } rule_t;
    
    logic clk;
    logic rst;
    logic test;

    logic pause_req;
    logic pause_ack;

    rule_t [NO_XBAR_SLAVES-1:0] addr_map;

    AXI_LITE #(
        .AXI_ADDR_WIDTH (ADDR_WIDTH),
        .AXI_DATA_WIDTH (DATA_WIDTH)
    ) master [NO_XBAR_SLAVES] ();
    
    AXI_LITE #(
        .AXI_ADDR_WIDTH (ADDR_WIDTH),
        .AXI_DATA_WIDTH (DATA_WIDTH)
    ) slave [NO_XBAR_MASTERS] ();

    AXI_LITE_DV #(
        .AXI_ADDR_WIDTH(ADDR_WIDTH),
        .AXI_DATA_WIDTH(DATA_WIDTH)
    ) master_dv [NO_XBAR_SLAVES] (clk);

    AXI_LITE_DV #(
        .AXI_ADDR_WIDTH(ADDR_WIDTH),
        .AXI_DATA_WIDTH(DATA_WIDTH)
    ) slave_dv [NO_XBAR_MASTERS] (clk);

    adam_axil_master_bhv #(
        .ADDR_WIDTH (ADDR_WIDTH),
        .DATA_WIDTH (DATA_WIDTH),
    
        .TA (TA),
        .TT (TT),

        .MAX_TRANS (MAX_TRANS)
    ) master_bhv [NO_XBAR_SLAVES];

     adam_axil_slave_bhv #(
        .ADDR_WIDTH (ADDR_WIDTH),
        .DATA_WIDTH (DATA_WIDTH),
    
        .TA (TA),
        .TT (TT),

        .MAX_TRANS (MAX_TRANS)
     ) slave_bhv [NO_XBAR_MASTERS];

    generate
        for (genvar i = 0; i < NO_XBAR_SLAVES; i++) begin
            `AXI_LITE_ASSIGN(master[i], master_dv[i]);

            initial begin
                master_bhv[i] = new(master_dv[i]);
                master_bhv[i].loop();
            end
        end

        for (genvar i = 0; i < NO_XBAR_MASTERS; i++) begin
            `AXI_LITE_ASSIGN(slave_dv[i], slave[i]);

            initial begin
                slave_bhv[i] = new(slave_dv[i]);
                slave_bhv[i].loop();
            end
        end
    endgenerate

    always_comb begin
        for (int i = 0; i < NO_XBAR_MASTERS; i++) begin
            addr_map[i] = '{
                idx: i,
                start_addr: i << 16,
                end_addr: (i + 1) << 16
            };
        end
    end

    adam_clk_rst_bhv #(
        .CLK_PERIOD (CLK_PERIOD),
        .RST_CYCLES (RST_CYCLES),

        .TA (TA),
        .TT (TT)
    ) adam_clk_rst_bhv (
        .clk (clk),
        .rst (rst)
    );
    
    adam_pause_bhv #(
        .DELAY    (10us),
        .DURATION (10us),

        .TA (TA),
        .TT (TT)
    ) adam_pause_bhv (
        .rst (rst),
        .clk (clk),

        .pause_req (pause_req),
        .pause_ack (pause_ack)
    );

    adam_axil_xbar #(
        .ADDR_WIDTH (ADDR_WIDTH),
        .DATA_WIDTH (DATA_WIDTH),

        .NO_SLAVES  (NO_XBAR_SLAVES),
        .NO_MASTERS (NO_XBAR_MASTERS),
        
        .MAX_TRANS (MAX_TRANS),

        .rule_t (rule_t)
    ) adam_axil_xbar (
        .clk  (clk),
        .rst  (rst),
        .test (test),
        
        .pause_req (pause_req),
        .pause_ack (pause_ack),

        .axil_slv (master),
        .axil_mst (slave),

        .addr_map (addr_map)
    );

    assign test = 0;

    generate
        for (genvar i = 0; i < NO_XBAR_SLAVES; i++) begin
            initial begin
                automatic addr_t addr_high;
                automatic addr_t addr_low;
                automatic addr_t addr;
                automatic data_t data;
                automatic resp_t resp;

                @(negedge rst); 
                @(posedge clk);

                for (int j = 0; j < NO_TESTS; j++) begin
                    addr_high = i << 16;
                    addr_low  = $urandom_range(0, 32'hFFFF);
                    addr = addr_high | addr_low;
                    
                    if($urandom_range(0, 1)) begin
                        data = addr_low;

                        fork
                            master_bhv[i].send_aw(addr, 3'b000);
                            master_bhv[i].send_w(addr, 4'b1111);
                            master_bhv[i].recv_b(resp);
                        join

                        assert (resp == axi_pkg::RESP_OKAY); 
                    end
                    else begin
                        fork
                            master_bhv[i].send_ar(addr, 3'b000);
                            master_bhv[i].recv_r(data, resp);
                        join

                        assert (resp == axi_pkg::RESP_OKAY);
                        assert (data == addr_low);
                    end
                end

                $stop();
            end
        end

        for (genvar i = 0; i < NO_XBAR_MASTERS; i++) begin
            initial begin
                automatic addr_t addr;
                automatic prot_t prot;
                automatic data_t data;
                automatic strb_t strb;
                automatic resp_t resp;

                @(negedge rst); 
                @(posedge clk);

                resp = axi_pkg::RESP_OKAY;

                for (int j = 0; j < NO_TESTS; j++) begin
                    fork
                        slave_bhv[i].recv_aw(addr, prot);
                        slave_bhv[i].recv_w(data, strb);
                    join
    
                    assert (addr == (data & 32'hFFFF));
                    
                    slave_bhv[i].send_b(resp);
                end
            end

            initial begin
                automatic addr_t addr;
                automatic prot_t prot;
                automatic data_t data;
                automatic strb_t strb;
                automatic resp_t resp;

                @(negedge rst); 
                @(posedge clk);

                resp = axi_pkg::RESP_OKAY;

                for (int j = 0; j < NO_TESTS; j++) begin    
                    slave_bhv[i].recv_ar(addr, prot);
                    data = addr;
                    slave_bhv[i].send_r(data, resp);
                end
            end
        end
    endgenerate
endmodule