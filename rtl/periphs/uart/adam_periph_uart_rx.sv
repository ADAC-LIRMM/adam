/*
 * This module adds non-standard functionality to pause_req and pause_ack.
 * In addition to their conventional roles, when both are asserted, the
 * modification of the configuration signals is allowed. This functionality is
 * NOT part of the standard "pause protocol".
 */

module adam_periph_uart_rx #(
    parameter DATA_WIDTH = 32,

    // Dependent parameters bellow, do not override.

    parameter type data_t = logic [DATA_WIDTH-1:0]
) (
    input logic clk,
    input logic rst,
    input logic test,

    input  logic pause_req,
    output logic pause_ack,

    input  logic       parity_select,
    input  logic       parity_control,
    input  logic [3:0] data_length,
    input  logic       stop_bits,
    input  data_t      baud_rate,

    output data_t data,
    output logic  data_valid,
    input  logic  data_ready,

    input  logic rx
);
    data_t frame_size;

    data_t clk_count;
    data_t bit_count;
    logic  parity;

    assign frame_size = 1 + data_length + parity_control + (1 + stop_bits);

    always_ff @(posedge clk) begin
        if (rst) begin
            clk_count  <= 0;
            bit_count  <= 0;
            parity     <= 0;
            data       <= 0;
            data_valid <= 0;
            pause_ack  <= 0;
        end
        else if (pause_req && pause_ack) begin
            // PAUSED
        end
        else begin
            if (clk_count == 0 && bit_count == 0) begin
                // idle
                if (!pause_req && rx == 0) begin
                    // start @(negedge rx)
                    clk_count <= baud_rate/2;
                    bit_count <= 0;
                    parity    <= 0;
                    data      <= 0;
                end
                else begin
                    // able to pause
                    pause_ack <= pause_req;
                end
            end
            else if (bit_count >= frame_size) begin
                // end of transmission
                if (data_valid & data_ready) begin
                    // transfer complete
                    clk_count  <= 0;
                    bit_count  <= 0;
                    data_valid <= 0;
                end
                else begin
                    // waiting for data_ready
                    data_valid <= 1;
                end
            end
            else if (clk_count >= baud_rate) begin
                // increment bit_count
                clk_count <= 0;
                bit_count <= bit_count + 1;

                if (bit_count < 1) begin
                    // start bit
                    if (rx != 0) begin
                        // error
                        clk_count <= 0;
                        bit_count <= 0;
                    end
                end
                else if (bit_count < 1 + data_length) begin
                    // data bit
                    data[bit_count-1] <= rx;
                    parity <= parity ^ rx;
                end
                else if (bit_count < 1 + data_length + parity_control) begin
                    // parity
                    if (rx != parity) begin
                        // error
                        clk_count <= 0;
                        bit_count <= 0;
                    end
                end
                else begin
                    // stop bit
                    if (rx != 1) begin
                        // error
                        clk_count <= 0;
                        bit_count <= 0;
                    end
                end
            end
            else begin
                // increment clk_count
                clk_count <= clk_count + 1;
            end
        end
    end
endmodule