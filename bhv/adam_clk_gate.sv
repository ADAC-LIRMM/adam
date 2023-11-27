module adam_clk_gate (
    ADAM_SEQ.Slave  slv,
    ADAM_SEQ.Master mst,

    input  logic enable
);

    logic ctrl;

    always_latch begin
        if (slv.clk == 0) ctrl <= enable | slv.rst;
    end

    assign mst.rst = slv.rst;
    assign mst.clk = slv.clk & ctrl;

endmodule
