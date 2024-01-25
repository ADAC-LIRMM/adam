module adam_clk_div #(
    parameter WIDTH = 2
) (
    ADAM_SEQ.Slave  slv,
    ADAM_SEQ.Master mst
);

    logic [WIDTH-1:0] counter;

    assign mst.clk = counter[WIDTH-1];
    assign mst.rst = slv.rst;

    // initial counter = 0;

    always_ff @(posedge slv.clk) begin
        counter <= counter + 1;
    end

endmodule