module cv32e40p_clock_gate (
    input  logic clk_i,
    input  logic en_i,
    input  logic scan_cg_en_i,
    output logic clk_o
);

    ADAM_SEQ slv ();
    ADAM_SEQ mst ();

    assign slv.clk = clk_i;
    assign slv.rst = '0;

    assign clk_o = mst.clk;

    adam_clk_gate adam_clk_gate (
        .slv (slv),
        .mst (mst),

        .enable (en_i)
    );

endmodule
