`timescale 1ns/1ps

`include "adam/macros_bhv.svh"
`include "axi/assign.svh"
`include "vunit_defines.svh"

module adam_axil_pause_tb;
    import adam_axil_mst_bhv::*;
    import adam_axil_slv_bhv::*;

    `ADAM_BHV_CFG_LOCALPARAMS;

    localparam MAX_TRANS = 7;

    localparam NO_TESTS = 100;

    ADAM_SEQ   seq   ();
    ADAM_PAUSE pause ();

    AXI_LITE #(
        .AXI_ADDR_WIDTH (ADDR_WIDTH),
        .AXI_DATA_WIDTH (DATA_WIDTH)
    ) slave ();
    
    AXI_LITE_DV #(
        .AXI_ADDR_WIDTH(ADDR_WIDTH),
        .AXI_DATA_WIDTH(DATA_WIDTH)
    ) slave_dv (seq.clk);

    `AXI_LITE_ASSIGN(slave_dv, slave);

    adam_axil_slv_bhv #(
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
    ) master_dv (seq.clk);

    `AXI_LITE_ASSIGN(master, master_dv);

    adam_axil_mst_bhv #(
        .ADDR_WIDTH (ADDR_WIDTH),
        .DATA_WIDTH (DATA_WIDTH),
    
        .TA (TA),
        .TT (TT),

        .MAX_TRANS (MAX_TRANS)
    ) master_bhv = new(master_dv);

    adam_seq_bhv #(
        .CLK_PERIOD (CLK_PERIOD),
        .RST_CYCLES (RST_CYCLES),

        .TA (TA),
        .TT (TT)
    ) adam_seq_bhv (
        .seq (seq)
    );

    adam_axil_pause #(
        .ADDR_WIDTH (ADDR_WIDTH),
        .DATA_WIDTH (DATA_WIDTH),

        .MAX_TRANS  (MAX_TRANS)
    ) dut (
        .seq   (seq),
        .pause (pause), 

        .slv (master),
        .mst (slave)
    );

    initial slave_bhv.loop();
    initial master_bhv.loop();

    `TEST_SUITE begin
        `TEST_CASE("test") begin
            pause.req = 0;

            repeat (NO_TESTS) begin
                random_delay(100);

                pause.req <= #TA 1;
                cycle_start();
                while (pause.ack != 1) begin
                    cycle_end();
                    cycle_start();
                end
                cycle_end();

                random_delay(100);

                pause.req <= #TA 0;
                cycle_start();
                while (pause.ack != 0) begin
                    cycle_end();
                    cycle_start();
                end
                cycle_end();
            end
        end
    end

    initial begin
        #1000us $error("timeout");
    end

    initial begin
        @(negedge seq.rst);
        @(posedge seq.clk);
        
        forever begin
            fork
                repeat (MAX_TRANS) begin
                    automatic ADDR_T addr;
                    addr = $urandom();
                    random_delay(5);
                    master_bhv.send_aw(addr, 3'b000);
                end

                repeat (MAX_TRANS) begin
                    automatic DATA_T data;
                    data = $urandom();
                    random_delay(5);
                    master_bhv.send_w(data, 4'b1111);
                end
                
                repeat (MAX_TRANS) begin
                    automatic ADDR_T addr;
                    addr = $urandom();
                    random_delay(5);
                    master_bhv.send_ar(addr, 3'b000);
                end
                
                repeat (MAX_TRANS) begin
                    automatic RESP_T resp;
                    master_bhv.recv_b(resp);
                    random_delay(5);
                end
                
                repeat (MAX_TRANS) begin
                    automatic DATA_T data;
                    automatic RESP_T resp;
                    master_bhv.recv_r(data, resp);
                    random_delay(5);
                end
            join
        end
    end

    initial begin
        @(negedge seq.rst);
        @(posedge seq.clk);
        
        forever begin
            fork
                repeat (MAX_TRANS) begin
                    automatic ADDR_T addr;
                    automatic PROT_T prot;
                    automatic DATA_T data;
                    automatic STRB_T strb;
                    automatic RESP_T resp = 0;

                    slave_bhv.recv_aw(addr, prot);
                    slave_bhv.recv_w(data, strb);
                    slave_bhv.send_b(resp);

                    random_delay(50);
                end

                repeat (MAX_TRANS) begin
                    automatic ADDR_T addr;
                    automatic PROT_T prot;
                    automatic DATA_T data;
                    automatic RESP_T resp;

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
        @(posedge seq.clk);
    endtask

endmodule