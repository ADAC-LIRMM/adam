`include "adam/macros_bhv.svh"
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

    `ADAM_STREAM_MST_BHV_FACTORY(data_t, TA, TT, mst, seq.clk);
    `ADAM_STREAM_SLV_BHV_FACTORY(data_t, TA, TT, 1, slv, seq.clk);

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
