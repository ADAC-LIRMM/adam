`timescale 1ns/1ps
`include "adam/macros_bhv.svh"
`include "vunit_defines.svh"

module adam_stream_skid_tb;
    import adam_stream_mst_bhv::*;
    import adam_stream_slv_bhv::*;

    `ADAM_BHV_CFG_LOCALPARAMS;
    
    ADAM_SEQ seq();

    `ADAM_STREAM_BHV_MST_FACTORY(DATA_T, TA, TT, mst, seq.clk);
    `ADAM_STREAM_BHV_SLV_FACTORY(DATA_T, TA, TT, 1, slv, seq.clk);

    adam_stream_skid #(
        .T (DATA_T)
    ) dut (
        .seq(seq),

        .slv (mst),
        .mst (slv)
    );

    adam_seq_bhv #(
        .CLK_PERIOD(CLK_PERIOD),
        .RST_CYCLES(RST_CYCLES),
        
        .TA(TA),
        .TT(TT)
    ) clk_rst_bhv (
        .seq(seq)
    );

    `TEST_SUITE begin
        `TEST_CASE("basic") begin
            automatic DATA_T data = '0;

            @(negedge seq.rst);
            @(posedge seq.clk);

            mst_bhv.send(data);
            slv_bhv.recv(data);
        end

        `TEST_CASE("stall") begin
            automatic DATA_T data = '0;

            @(negedge seq.rst);
            @(posedge seq.clk);

            repeat (2) mst_bhv.send(data);
            @(negedge mst.ready);
            repeat (2) slv_bhv.recv(data);
        end
    end

    initial begin
        #10us $error("timeout");
    end

endmodule
