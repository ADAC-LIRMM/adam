`timescale 1ns/1ps

module adam_clk_rst_bhv #(
    parameter CLK_PERIOD = 20ns,
    parameter RST_CYCLES = 5,

    parameter TA = 2ns,
    parameter TT = CLK_PERIOD - TA
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