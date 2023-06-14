module adam_clk_gate (
    input logic clk,
    input logic rst,
    input logic test,
    
    input  logic enable,
    output logic gated_clk
);

  logic ctrl;

  always_latch begin
      if (clk == 0) ctrl <= enable | rst | test;
  end

  assign gated_clk = clk & ctrl;

endmodule
