module adam_clk_div #(
    parameter WIDTH = 2
) (
    input  logic in,
    output logic out
);

    logic [WIDTH-1:0] counter;

    assign out = counter[WIDTH-1];

    always_ff @(posedge in) begin
        counter <= counter + 1;
    end

endmodule