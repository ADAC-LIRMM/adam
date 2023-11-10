`include "vunit_defines.svh"

module adam_clk_div_tb;
    
    localparam WIDTH = 1;

    localparam CLK_PERIOD = 5ns;
    localparam RST_CYCLES = 1;

    localparam TA = 1ns;
    localparam TT = CLK_PERIOD - TA;

    logic rst;
    logic in;
    logic out;

    adam_clk_rst_bhv #(
        .CLK_PERIOD (CLK_PERIOD),
        .RST_CYCLES (RST_CYCLES),

        .TA (TA),
        .TT (TT)
    ) adam_clk_rst_bhv (
        .clk (in),
        .rst (rst)
    );

    adam_clk_div #(
        .WIDTH (WIDTH)
    ) dut (
        .rst (rst),
        .in  (in),
        .out (out)
    );

    `TEST_SUITE begin
        `TEST_CASE("test") begin
            #200ns;
        end
    end

endmodule