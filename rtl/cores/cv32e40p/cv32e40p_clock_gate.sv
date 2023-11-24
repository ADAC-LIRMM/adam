module cv32e40p_clock_gate (
    input  logic clk_i,
    input  logic en_i,
    input  logic scan_cg_en_i,
    output logic clk_o
);

  adam_clk_gate adam_clk_gate (
    .clk       (clk_i),
    .rst       ('0),
    .enable    (en_i),
    .gated_clk (clk_o)
  );

endmodule
