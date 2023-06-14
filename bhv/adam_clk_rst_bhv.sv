module adam_clk_rst_bhv #(
    parameter CLK_PERIOD = 20ns,
    parameter RST_CYCLES = 5,

    parameter TA = 2ns,
    parameter TT = CLK_PERIOD - TA
) (
    output logic clk,
    output logic rst
);

    initial begin
        clk <= 1;
        forever #(CLK_PERIOD/2) clk <= ~clk;
    end

    initial begin
        rst <= 1;
        repeat (RST_CYCLES) @(posedge clk);
        rst <= #TA 0;
    end

endmodule