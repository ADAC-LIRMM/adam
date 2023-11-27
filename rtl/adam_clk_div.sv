module adam_clk_div #(
    parameter WIDTH = 2
) (
    ADAM_SEQ.Slave  slv,
    ADAM_SEQ.Master mst
);

    logic [WIDTH-1:0] counter;

    assign mst.clk = counter[WIDTH-1];
    assign mst.rst = slv.rst;

    always_ff @(posedge slv.clk) begin
        if (slv.rst) begin
            counter <= 0;
        end
        else begin
            counter <= counter + 1;
        end
    end

endmodule