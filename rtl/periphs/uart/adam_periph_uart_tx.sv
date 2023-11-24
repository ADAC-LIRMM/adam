/*
 * This module adds non-standard functionality to pause_req and pause_ack.
 * In addition to their conventional roles, when both are asserted, the
 * modification of the configuration signals is allowed. This functionality is
 * NOT part of the standard "pause protocol".
 */
 
module adam_periph_uart_tx #(
    parameter DATA_WIDTH = 32,

    // Dependent parameters bellow, do not override.

    parameter type data_t = logic [DATA_WIDTH-1:0]
) (
    input logic clk,
    input logic rst,

    input  logic pause_req,
    output logic pause_ack,

    input  logic       parity_select,
    input  logic       parity_control,
    input  logic [3:0] data_length,
    input  logic       stop_bits,
    input  data_t      baud_rate,

    input  data_t data,
    input  logic  data_valid,
    output logic  data_ready,
    
    output logic tx
);
    data_t frame_size;

    data_t clk_count;
    data_t bit_count;
    data_t shift;
    logic  parity;

    /* 
     * This implementation places the start and stop bits at the beginning,
     * because it is simpler and the receiver is not able to perceive the
     * difference.
     */

    assign frame_size = 2 + stop_bits + data_length + parity_control;

    always_ff @(posedge clk) begin
        if (rst) begin
            clk_count  <= 0;
            bit_count  <= 0;
            shift      <= 0;
            parity     <= 0;
            data_ready <= 0;
            pause_ack  <= 0;
        end
        else begin
            if (clk_count == 0 && bit_count == 0) begin
                // idle
                if (data_valid && data_ready) begin
                    // transfer complete
                    data_ready <= 0;
                end 
                else if (!pause_req && !pause_ack && data_valid) begin
                    // start
                    clk_count <= 1;
                    bit_count <= 0;
                    shift     <= data;
                    parity    <= 0;
                end
                else begin
                    // able to pause
                    pause_ack <= pause_req;
                end
            end
            else if (clk_count >= baud_rate) begin
                // increment bit_count
                clk_count <= 0;
                bit_count <= bit_count + 1;

                if (bit_count >= 2 + stop_bits) begin
                    // shift data
                    shift  <= (shift >> 1);
                    parity <= parity ^ shift[0];
                end

                if (bit_count + 1 >= frame_size) begin
                    // end
                    clk_count  <= 0;
                    bit_count  <= 0;
                    shift      <= 0;
                    parity     <= 0;
                    data_ready <= 1;
                end
            end
            else begin
                // increment clk_count
                clk_count <= clk_count + 1;
            end
        end
    end

    always_comb begin
        if (bit_count < 1 + stop_bits) begin
            // stop bit or idle
            tx = 1;
        end
        else if (bit_count < 2 + stop_bits) begin 
            // start
            tx = 0;
        end
        else if (bit_count < 2 + stop_bits + data_length) begin
            // send bit
            tx = shift[0];
        end
        else if (bit_count < 2 + stop_bits + data_length + parity_control) begin
            // send parity
            tx = parity ^ parity_select;
        end
        else begin
            // default
            tx = 1;
        end
    end
endmodule