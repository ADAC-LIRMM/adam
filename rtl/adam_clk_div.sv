module adam_clk_div #(
    parameter WIDTH = 2
) (
    input  logic rst,
    input  logic in,
    output logic out
);

    logic [WIDTH-1:0] counter;

    assign out = counter[WIDTH-1];

    always_ff @(posedge in) begin
        if (rst) begin
            counter <= 0;
        end
        else begin
            counter <= counter + 1;
        end
    end

endmodule