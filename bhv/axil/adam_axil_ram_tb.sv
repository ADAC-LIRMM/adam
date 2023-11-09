`include "axi/assign.svh"
`include "vunit_defines.svh"

module adam_axil_ram_tb;
    import adam_axil_master_bhv::*;

    localparam ADDR_WIDTH = 32;
    localparam DATA_WIDTH = 32;
    localparam STRB_WIDTH = DATA_WIDTH/8;

    localparam SIZE = 4096;
    
    localparam CLK_PERIOD = 20ns;
    localparam RST_CYCLES = 5;

    localparam TA = 2ns;
    localparam TT = CLK_PERIOD - TA;

    localparam NO_TESTS = 1000;

    localparam MAX_TRANS = 7;

    localparam MIN_ADDR = 0;
    localparam MAX_ADDR = 8192;

    typedef logic [ADDR_WIDTH-1:0] addr_t;
    typedef logic [2:0]            prot_t;       
    typedef logic [DATA_WIDTH-1:0] data_t;
    typedef logic [STRB_WIDTH-1:0] strb_t;
    typedef logic [1:0]            resp_t;

    logic clk;
    logic rst;
    logic test;

    logic pause_req;
    logic pause_ack;

    AXI_LITE #(
        .AXI_ADDR_WIDTH (ADDR_WIDTH),
        .AXI_DATA_WIDTH (DATA_WIDTH)
    ) axil ();
    
    AXI_LITE_DV #(
        .AXI_ADDR_WIDTH(ADDR_WIDTH),
        .AXI_DATA_WIDTH(DATA_WIDTH)
    ) axil_dv (clk);

    `AXI_LITE_ASSIGN(axil, axil_dv)

    adam_axil_master_bhv #(
        .ADDR_WIDTH (ADDR_WIDTH),
        .DATA_WIDTH (DATA_WIDTH),
    
        .TA (TA),
        .TT (TT),

        .MAX_TRANS (MAX_TRANS)
    ) master = new(axil_dv);

    // TODO: implement pause
    assign pause_ack = 0;

    adam_clk_rst_bhv #(
        .CLK_PERIOD (CLK_PERIOD),
        .RST_CYCLES (RST_CYCLES),

        .TA (TA),
        .TT (TT)
    ) adam_clk_rst_bhv (
        .clk (clk),
        .rst (rst)
    );

    adam_axil_ram #(
        .ADDR_WIDTH (ADDR_WIDTH),
        .DATA_WIDTH (DATA_WIDTH),
        
        .SIZE (SIZE)
    ) dut (
        .clk  (clk),
        .rst  (rst),
        .test (test),

        .pause_req (pause_req),
        .pause_ack (pause_ack),

        .axil (axil)
    );

    // TODO: implement pause
    assign pause_req = 0;

    initial master.loop();

    `TEST_SUITE begin
        `TEST_CASE("test") begin
            test = 0;

            @(negedge rst); 
            repeat (10) @(posedge clk);

            // Write
            for (addr_t addr = 0; addr < SIZE; addr += STRB_WIDTH) begin
                automatic resp_t resp;

                master.send_aw(addr, 3'b000);
                master.send_w(addr, 4'b1111);
                master.recv_b(resp);

                assert (resp == axi_pkg::RESP_OKAY);
            end
            
            // Read
            for (addr_t addr = 0; addr < SIZE; addr += STRB_WIDTH) begin
                automatic data_t data;
                automatic resp_t resp;
                
                master.send_ar(addr, 3'b000);
                master.recv_r(data, resp);

                assert (resp == axi_pkg::RESP_OKAY);
                assert (data == addr);
            end
            
            // Random access
            for(int i = 0; i < NO_TESTS; i += 4) begin
                automatic addr_t addr;
                automatic data_t data;
                automatic resp_t b_resp;
                automatic data_t r_data;
                automatic resp_t r_resp;

                addr = $urandom_range(MIN_ADDR, MAX_ADDR);

                // force alligned access on 50% of the operations
                if(i % 2) begin
                    addr[$clog2(STRB_WIDTH)-1:0] = 0;
                end

                data = addr;

                fork
                    repeat (MAX_TRANS) begin
                        master.send_aw(addr, 3'b000);
                    end

                    repeat (MAX_TRANS) begin
                        master.send_w(data, 4'b1111);
                    end
                    
                    repeat (MAX_TRANS) begin
                        master.send_ar(addr, 3'b000);
                    end
                    
                    repeat (MAX_TRANS) begin
                        master.recv_b(b_resp);

                        // if valid address
                        if (
                            (addr[$clog2(STRB_WIDTH)-1:0] == 0) &&
                            (addr < SIZE)
                        ) begin
                            assert (b_resp == axi_pkg::RESP_OKAY);
                        end
                        else begin
                            assert (b_resp == axi_pkg::RESP_DECERR);
                        end
                    end
                    
                    repeat (MAX_TRANS) begin
                        master.recv_r(r_data, r_resp);

                        // if valid address
                        if (
                            (addr[$clog2(STRB_WIDTH)-1:0] == 0) &&
                            (addr < SIZE)
                        ) begin
                            assert (r_resp == axi_pkg::RESP_OKAY);
                            assert (r_data == data);
                        end
                        else begin
                            assert (r_resp == axi_pkg::RESP_DECERR);
                        end
                    end
                join
            end
        end
    end

endmodule