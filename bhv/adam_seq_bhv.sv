`timescale 1ns/1ps
`include "adam/macros_bhv.svh"

module adam_seq_bhv #(
    `ADAM_BHV_CFG_PARAMS
) (
    ADAM_SEQ.Master seq
);

    initial begin
        seq.clk <= 1;
        forever #(CLK_PERIOD/2) seq.clk <= ~seq.clk;
    end

    initial begin
        seq.rst <= 1;
        repeat (RST_CYCLES) @(posedge seq.clk);
        seq.rst <= #TA 0;
    end

endmodule