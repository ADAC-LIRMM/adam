`include "adam/stream/assign.svh"
`include "vunit_defines.svh"

module adam_stream_skid_tb;
    import adam_stream_mst_bhv::*;
    import adam_stream_slv_bhv::*;

    localparam type data_t = logic [31:0];
    
    localparam CLK_PERIOD = 20ns;
    localparam RST_CYCLES = 5;

    localparam TA = 2ns;
    localparam TT = CLK_PERIOD - TA;

    ADAM_SEQ seq();

    ADAM_STREAM #(
        .data_t (data_t)
    ) mst ();
    
    ADAM_STREAM_DV #(
        .data_t (data_t)
    ) mst_dv (seq.clk);

    `ADAM_STREAM_ASSIGN(mst, mst_dv);

    adam_stream_mst_bhv #(
        .data_t (data_t),

        .TA (TA),
        .TT (TT)
    ) mst_bhv;

    initial begin
        mst_bhv = new(mst_dv);
        mst_bhv.loop();
    end

    ADAM_STREAM #(
        .data_t (data_t)
    ) slv ();
    
    ADAM_STREAM_DV #(
        .data_t (data_t)
    ) slv_dv (seq.clk);

    `ADAM_STREAM_ASSIGN(slv_dv, slv);

    adam_stream_slv_bhv #(
        .data_t (data_t),

        .TA (TA),
        .TT (TT),

        .MAX_TRANS (1)
    ) slv_bhv;

    initial begin
        slv_bhv = new(slv_dv);
        slv_bhv.loop();
    end

    adam_stream_skid #(
        .data_t (data_t)
    ) dut (
        .seq(seq),

        .slv (mst),
        .mst (slv)
    );

    adam_clk_rst_bhv #(
        .CLK_PERIOD(CLK_PERIOD),
        .RST_CYCLES(RST_CYCLES),
        
        .TA(TA),
        .TT(TT)
    ) clk_rst_bhv (
        .seq(seq)
    );

    `TEST_SUITE begin
        `TEST_CASE("basic") begin
            automatic data_t data = '0;

            @(negedge seq.rst);
            @(posedge seq.clk);

            mst_bhv.send(data);
            slv_bhv.recv(data);
        end

        `TEST_CASE("stall") begin
            automatic data_t data = '0;

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
