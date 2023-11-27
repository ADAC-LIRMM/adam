`include "axi/assign.svh"
`include "vunit_defines.svh"

module adam_axil_xbar_tb;
    import adam_axil_master_bhv::*;
    import adam_axil_slave_bhv::*;

    localparam ADDR_WIDTH = 32;
    localparam DATA_WIDTH = 32;
    
    localparam NO_XBAR_SLVS = 4;
    localparam NO_XBAR_MSTS = 4;

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
    
    integer done;

    ADAM_SEQ   seq   ();
    ADAM_PAUSE pause ();

    rule_t [NO_XBAR_SLVS-1:0] addr_map;

    AXI_LITE #(
        .AXI_ADDR_WIDTH (ADDR_WIDTH),
        .AXI_DATA_WIDTH (DATA_WIDTH)
    ) master [NO_XBAR_SLVS] ();
    
    AXI_LITE #(
        .AXI_ADDR_WIDTH (ADDR_WIDTH),
        .AXI_DATA_WIDTH (DATA_WIDTH)
    ) slave [NO_XBAR_MSTS] ();

    AXI_LITE_DV #(
        .AXI_ADDR_WIDTH(ADDR_WIDTH),
        .AXI_DATA_WIDTH(DATA_WIDTH)
    ) master_dv [NO_XBAR_SLVS] (seq.clk);

    AXI_LITE_DV #(
        .AXI_ADDR_WIDTH(ADDR_WIDTH),
        .AXI_DATA_WIDTH(DATA_WIDTH)
    ) slave_dv [NO_XBAR_MSTS] (seq.clk);

    adam_axil_master_bhv #(
        .ADDR_WIDTH (ADDR_WIDTH),
        .DATA_WIDTH (DATA_WIDTH),
    
        .TA (TA),
        .TT (TT),

        .MAX_TRANS (MAX_TRANS)
    ) master_bhv [NO_XBAR_SLVS];

    adam_axil_slave_bhv #(
        .ADDR_WIDTH (ADDR_WIDTH),
        .DATA_WIDTH (DATA_WIDTH),

        .TA (TA),
        .TT (TT),

        .MAX_TRANS (MAX_TRANS)
    ) slave_bhv [NO_XBAR_MSTS];

    generate
        for (genvar i = 0; i < NO_XBAR_SLVS; i++) begin
            `AXI_LITE_ASSIGN(master[i], master_dv[i]);

            initial begin
                master_bhv[i] = new(master_dv[i]);
                master_bhv[i].loop();
            end
        end

        for (genvar i = 0; i < NO_XBAR_MSTS; i++) begin
            `AXI_LITE_ASSIGN(slave_dv[i], slave[i]);

            initial begin
                slave_bhv[i] = new(slave_dv[i]);
                slave_bhv[i].loop();
            end
        end
    endgenerate

    always_comb begin
        for (int i = 0; i < NO_XBAR_MSTS; i++) begin
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
        .seq (seq)
    );
    
    adam_pause_bhv #(
        .DELAY    (10us),
        .DURATION (10us),

        .TA (TA),
        .TT (TT)
    ) adam_pause_bhv (
        .seq   (seq),
        .pause (pause)
    );

    adam_axil_xbar #(
        .ADDR_WIDTH (ADDR_WIDTH),
        .DATA_WIDTH (DATA_WIDTH),

        .NO_SLVS (NO_XBAR_SLVS),
        .NO_MSTS (NO_XBAR_MSTS),
        
        .MAX_TRANS (MAX_TRANS),

        .rule_t (rule_t)
    ) adam_axil_xbar (
        .seq   (seq),
        .pause (pause),

        .axil_slvs (master),
        .axil_msts (slave),

        .addr_map (addr_map)
    );

    `TEST_SUITE begin
        `TEST_CASE("test") begin
            done = 0;

            @(negedge seq.rst); 
            @(posedge seq.clk);

            cycle_start();
            while (done < NO_XBAR_SLVS) begin
                cycle_end();
                cycle_start();
            end
            cycle_end();
        end
    end

    generate
        for (genvar i = 0; i < NO_XBAR_SLVS; i++) begin
            initial begin
                automatic addr_t addr_high;
                automatic addr_t addr_low;
                automatic addr_t addr;
                automatic data_t data;
                automatic resp_t resp;

                @(negedge seq.rst); 
                @(posedge seq.clk);

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
                        assert (data == i);
                    end
                end

                done += 1;
            end
        end

        for (genvar i = 0; i < NO_XBAR_MSTS; i++) begin
            initial begin
                automatic addr_t addr;
                automatic prot_t prot;
                automatic data_t data;
                automatic strb_t strb;
                automatic resp_t resp;

                @(negedge seq.rst); 
                @(posedge seq.clk);

                resp = axi_pkg::RESP_OKAY;

                for (int j = 0; j < NO_TESTS; j++) begin
                    fork
                        slave_bhv[i].recv_aw(addr, prot);
                        slave_bhv[i].recv_w(data, strb);
                    join
    
                    assert ((data >> 16) == i);
                    
                    slave_bhv[i].send_b(resp);
                end
            end

            initial begin
                automatic addr_t addr;
                automatic prot_t prot;
                automatic data_t data;
                automatic strb_t strb;
                automatic resp_t resp;

                @(negedge seq.rst); 
                @(posedge seq.clk);

                resp = axi_pkg::RESP_OKAY;

                for (int j = 0; j < NO_TESTS; j++) begin    
                    slave_bhv[i].recv_ar(addr, prot);
                    data = (addr >> 16);
                    slave_bhv[i].send_r(data, resp);
                end
            end
        end
    endgenerate

    task cycle_start();
        #TT;
    endtask

    task cycle_end();
        @(posedge seq.clk);
    endtask

endmodule