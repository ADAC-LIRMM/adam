module simple_clk_div_tb;

    localparam WIDTH = 1;

    logic clk_in;
    logic clk_out;

    simple_clk_div #(
        .WIDTH (WIDTH)
    ) dut (
        .clk_in  (clk_in),
        .clk_out (clk_out)
    );

    initial begin
        clk_in = 0;
        forever #5ns clk_in = ~clk_in; // 100 MHz
    end

    initial begin
        #200ns;
        $finish();
    end

endmodule