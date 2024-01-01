`timescale 1ns/1ps
`include "adam/macros_bhv.svh"
`include "axi/assign.svh"
`include "vunit_defines.svh"

module adam_fabric_lspx_tb;
    import adam_axil_mst_bhv::*;

    `ADAM_BHV_CFG_LOCALPARAMS;
    
    localparam MAX_TRANS = FAB_MAX_TRANS;

    localparam NO_SLVS = 8;
    localparam INC     = 1024;

    // seq and pause ==========================================================
    
    ADAM_SEQ   seq   ();
    ADAM_PAUSE pause ();
    
    adam_seq_bhv #(
        `ADAM_BHV_CFG_PARAMS_MAP
    ) adam_seq_bhv (
        .seq (seq)
    );

    adam_pause_bhv #(
        `ADAM_BHV_CFG_PARAMS_MAP,

        .DELAY    (10us),
        .DURATION (10us)
    ) adam_pause_bhv (
        .seq   (seq),
        .pause (pause)
    );

    // Master =================================================================

    `ADAM_AXIL_BHV_MST_FACTORY(MAX_TRANS, mst, seq.clk);

    // Slaves =================================================================

    `ADAM_APB_I slv [NO_SLVS+1] ();

    MMAP_T addr_map[NO_SLVS+1];

    generate
        for (genvar i = 0; i < NO_SLVS; i++) begin
            assign addr_map[i] = '{
                start : INC*i,
                end_  : INC*(i+1)
            };

            assign slv[i].pready  = '1;
            assign slv[i].prdata  = DATA_T'(i);
            assign slv[i].pslverr = '0;
        end
    endgenerate
    
    // DUT ====================================================================

    adam_fabric_lspx #(
        `ADAM_CFG_PARAMS_MAP,
        
        .NO_MSTS (NO_SLVS),
        .INC     (INC)
    ) dut (
        .seq   (seq),
        .pause (pause),
        
        .slv (mst),
        .mst (slv)
    );

    // Test ===================================================================

    `TEST_SUITE begin
        `TEST_CASE("test") begin
            ADDR_T addr;
            DATA_T wdata, rdata;
            RESP_T wresp, rresp;

            `ADAM_UNTIL(!seq.rst);

            for (int i = 0; i < NO_SLVS; i++) begin
                for (int j = 0; j < 2; j++) begin
                    if (j == 0) begin
                        addr = addr_map[i].start;
                    end
                    else begin
                        addr = addr_map[i].end_ - 1;
                    end

                    wdata = DATA_T'(i);

                    fork
                        mst_bhv.send_aw(addr, 3'b000);
                        mst_bhv.send_w(wdata, 4'b1111);
                        mst_bhv.recv_b(wresp);
                        mst_bhv.send_ar(addr, 3'b000);
                        mst_bhv.recv_r(rdata, rresp);
                    join

                    assert(wresp == axi_pkg::RESP_OKAY); 
                    assert(rresp == axi_pkg::RESP_OKAY);
                    assert(rdata == wdata);
                end
            end
        end
    end

    initial begin
        #1000us $error("timeout");
    end

    task cycle_start();
        #TT;
    endtask

    task cycle_end();
        @(posedge seq.clk);
    endtask

endmodule
