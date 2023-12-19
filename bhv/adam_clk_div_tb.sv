`timescale 1ns/1ps
`include "vunit_defines.svh"

module adam_clk_div_tb;
    
    localparam WIDTH = 1;

    localparam CLK_PERIOD = 5ns;
    localparam RST_CYCLES = 1;

    localparam TA = 1ns;
    localparam TT = CLK_PERIOD - TA;

    ADAM_SEQ mst ();
    ADAM_SEQ slv ();
    
    adam_seq_bhv #(
        .CLK_PERIOD (CLK_PERIOD),
        .RST_CYCLES (RST_CYCLES),

        .TA (TA),
        .TT (TT)
    ) adam_seq_bhv (
        .seq (mst)
    );

    adam_clk_div #(
        .WIDTH (WIDTH)
    ) dut (
        .slv (mst),
        .mst (slv)
    );

    `TEST_SUITE begin
        `TEST_CASE("test") begin
            #200ns;
        end
    end

endmodule