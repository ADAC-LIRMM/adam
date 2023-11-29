/*
 * This module adds non-standard functionality to pause.req and pause.ack.
 * In addition to their conventional roles, when both are asserted, the
 * modification of the configuration signals is allowed. This functionality is
 * NOT part of the standard "pause protocol".
 */

module adam_periph_uart_rx #(
    parameter DATA_WIDTH = 32,

    // Dependent parameters bellow, do not override.

    parameter type data_t = logic [DATA_WIDTH-1:0]
) (
    ADAM_SEQ.Slave   seq,
    ADAM_PAUSE.Slave pause,

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

    // double buffering the rx signal
    logic s_rx;
    logic s_srx; // Stable rx
    

    always_ff @(posedge clk) begin
        if (rst) begin
            s_rx <= 0;
            s_srx <= 0;
        end
        else if (pause_req && pause_ack) begin
            // PAUSED
        end
        else begin
            s_rx    <= rx;
            s_srx   <= s_rx;
        end
    end

    data_t frame_size;

    data_t clk_count;
    data_t bit_count;
    logic  parity;

    assign frame_size = 1 + data_length + parity_control + (1 + stop_bits);

    always_ff @(posedge seq.clk) begin
        if (seq.rst) begin
            clk_count  <= 0;
            bit_count  <= 0;
            parity     <= 0;
            data       <= 0;
            data_valid <= 0;
            pause.ack  <= 1;
        end
        else if (pause.req && pause.ack) begin
            // PAUSED
        end
        else begin
            if (clk_count == 0 && bit_count == 0) begin
                // idle
                if (!pause.req && s_srx == 0) begin
                    start @(negedge s_srx)
                    clk_count <= baud_rate/2;
                    bit_count <= 0;
                    parity    <= 0;
                    data      <= 0;
                end
                else begin
                    // able to pause
                    pause.ack <= pause.req;
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
                    if (s_srx != 0) begin
                        // error
                        clk_count <= 0;
                        bit_count <= 0;
                    end
                end
                else if (bit_count < 1 + data_length) begin
                    // data bit
                    data[bit_count-1] <= s_srx;
                    parity <= parity ^ s_srx;
                end
                else if (bit_count < 1 + data_length + parity_control) begin
                    // parity
                    if (s_srx != parity) begin
                        // error
                        clk_count <= 0;
                        bit_count <= 0;
                    end
                end
                else begin
                    // stop bit
                    if (s_srx != 1) begin
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