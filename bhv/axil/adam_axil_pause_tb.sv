`include "axi/assign.svh"
`include "vunit_defines.svh"

module adam_axil_pause_tb;
    import adam_axil_master_bhv::*;
    import adam_axil_slave_bhv::*;

    localparam ADDR_WIDTH = 32;
    localparam DATA_WIDTH = 32;
    
    localparam MAX_TRANS = 7;

    localparam CLK_PERIOD = 20ns;
    localparam RST_CYCLES = 5;

    localparam TA = 2ns;
    localparam TT = CLK_PERIOD - TA;

    localparam STRB_WIDTH = DATA_WIDTH/8;

    localparam NO_TESTS = 1000;

    typedef logic [ADDR_WIDTH-1:0] addr_t;
    typedef logic [2:0]            prot_t;       
    typedef logic [DATA_WIDTH-1:0] data_t;
    typedef logic [STRB_WIDTH-1:0] strb_t;
    typedef logic [1:0]            resp_t;

    logic clk;
    logic rst;

    logic pause_req;
    logic pause_ack;

    AXI_LITE #(
        .AXI_ADDR_WIDTH (ADDR_WIDTH),
        .AXI_DATA_WIDTH (DATA_WIDTH)
    ) slave ();
    
    AXI_LITE_DV #(
        .AXI_ADDR_WIDTH(ADDR_WIDTH),
        .AXI_DATA_WIDTH(DATA_WIDTH)
    ) slave_dv (clk);

    `AXI_LITE_ASSIGN(slave_dv, slave);

    adam_axil_slave_bhv #(
        .ADDR_WIDTH (ADDR_WIDTH),
        .DATA_WIDTH (DATA_WIDTH),
    
        .TA (TA),
        .TT (TT),

        .MAX_TRANS (MAX_TRANS)
    ) slave_bhv = new(slave_dv);

    AXI_LITE #(
        .AXI_ADDR_WIDTH (ADDR_WIDTH),
        .AXI_DATA_WIDTH (DATA_WIDTH)
    ) master ();
    
    AXI_LITE_DV #(
        .AXI_ADDR_WIDTH(ADDR_WIDTH),
        .AXI_DATA_WIDTH(DATA_WIDTH)
    ) master_dv (clk);

    `AXI_LITE_ASSIGN(master, master_dv);

    adam_axil_master_bhv #(
        .ADDR_WIDTH (ADDR_WIDTH),
        .DATA_WIDTH (DATA_WIDTH),
    
        .TA (TA),
        .TT (TT),

        .MAX_TRANS (MAX_TRANS)
    ) master_bhv = new(master_dv);

    adam_clk_rst_bhv #(
        .CLK_PERIOD (CLK_PERIOD),
        .RST_CYCLES (RST_CYCLES),

        .TA (TA),
        .TT (TT)
    ) adam_clk_rst_bhv (
        .clk (clk),
        .rst (rst)
    );

    adam_axil_pause #(
        .ADDR_WIDTH (ADDR_WIDTH),
        .DATA_WIDTH (DATA_WIDTH),

        .MAX_TRANS  (MAX_TRANS)
    ) dut (
        .clk  (clk),
        .rst  (rst),

        .pause_req (pause_req),
        .pause_ack (pause_ack), 

        .slv (master),
        .mst (slave)
    );

    initial slave_bhv.loop();
    initial master_bhv.loop();

    `TEST_SUITE begin
        `TEST_CASE("test") begin
            pause_req = 0;

            repeat (NO_TESTS) begin
                random_delay(100);

                pause_req <= #TA 1;
                cycle_start();
                while (pause_ack != 1) begin
                    cycle_end();
                    cycle_start();
                end
                cycle_end();

                random_delay(100);

                pause_req <= #TA 0;
                cycle_start();
                while (pause_ack != 0) begin
                    cycle_end();
                    cycle_start();
                end
                cycle_end();
            end
        end
    end

    initial begin
        @(negedge rst);
        @(posedge clk);
        
        forever begin
            fork
                repeat (MAX_TRANS) begin
                    automatic addr_t addr;
                    addr = $urandom();
                    random_delay(5);
                    master_bhv.send_aw(addr, 3'b000);
                end

                repeat (MAX_TRANS) begin
                    automatic data_t data;
                    data = $urandom();
                    random_delay(5);
                    master_bhv.send_w(data, 4'b1111);
                end
                
                repeat (MAX_TRANS) begin
                    automatic addr_t addr;
                    addr = $urandom();
                    random_delay(5);
                    master_bhv.send_ar(addr, 3'b000);
                end
                
                repeat (MAX_TRANS) begin
                    automatic resp_t resp;
                    master_bhv.recv_b(resp);
                    random_delay(5);
                end
                
                repeat (MAX_TRANS) begin
                    automatic data_t data;
                    automatic resp_t resp;
                    master_bhv.recv_r(data, resp);
                    random_delay(5);
                end
            join
        end
    end

    initial begin
        @(negedge rst);
        @(posedge clk);
        
        forever begin
            fork
                repeat (MAX_TRANS) begin
                    automatic addr_t addr;
                    automatic prot_t prot;
                    automatic data_t data;
                    automatic strb_t strb;
                    automatic resp_t resp = 0;

                    slave_bhv.recv_aw(addr, prot);
                    slave_bhv.recv_w(data, strb);
                    slave_bhv.send_b(resp);

                    random_delay(50);
                end

                repeat (MAX_TRANS) begin
                    automatic addr_t addr;
                    automatic prot_t prot;
                    automatic data_t data;
                    automatic resp_t resp;

                    data = $urandom();
                    resp = 0;

                    slave_bhv.recv_ar(addr, prot);
                    slave_bhv.send_r(data, resp);

                    random_delay(50);
                end
            join
        end
    end
    
    task random_delay(integer max);
        repeat ($urandom_range(0, max)) begin
            cycle_start();
            cycle_end();
        end
    endtask

    task cycle_start();
        #TT;
    endtask

    task cycle_end();
        @(posedge clk);
    endtask

endmodule