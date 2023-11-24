`include "vunit_defines.svh"

module adam_periph_uart_rx_tb;

    localparam DATA_WIDTH = 32;

    localparam CLK_PERIOD = 20ns;
    localparam RST_CYCLES = 5;

    localparam TA = 2ns;
    localparam TT = CLK_PERIOD - TA;

    localparam BAUD_RATE = 115200;
    localparam MSG_LEN   = 256;

    typedef logic [DATA_WIDTH-1:0] word_t;

    logic clk;
    logic rst;

    logic pause_req;
    logic pause_ack;

    logic       parity_select;
    logic       parity_control;
    logic [3:0] data_length;
    logic [1:0] stop_bits;
    word_t      baud_rate;

    word_t data;
    logic  data_valid;
    logic  data_ready;

    logic rx;

    adam_periph_uart_rx #(
        .DATA_WIDTH (DATA_WIDTH)
    ) dut (
        .clk  (clk),
        .rst  (rst),

        .pause_req (pause_req),
        .pause_ack (pause_ack),

        .parity_select  (parity_select),
        .parity_control (parity_control),
        .data_length    (data_length),
        .stop_bits      (stop_bits),
        .baud_rate      (baud_rate),

        .data       (data),
        .data_valid (data_valid),
        .data_ready (data_ready),

        .rx(rx)
    );

    adam_clk_rst_bhv #(
        .CLK_PERIOD (CLK_PERIOD),
        .RST_CYCLES (RST_CYCLES),

        .TA (TA),
        .TT (TT)
    ) adam_clk_rst_bhv (
        .clk (clk),
        .rst (rst)
    );

    adam_pause_bhv #(
        .DELAY    (1ms),
        .DURATION (1ms),

        .TA (TA),
        .TT (TT)
    ) adam_pause_bhv (
        .rst (rst),
        .clk (clk),

        .pause_req (pause_req),
        .pause_ack (pause_ack)
    );

    `TEST_SUITE begin
        `TEST_CASE("test") begin
            parity_select  = 0;
            parity_control = 1;
            data_length    = 8;
            stop_bits      = 1;
            baud_rate      = 1s / (BAUD_RATE * CLK_PERIOD);
            data_ready     = 1;
            
        rx = 1;

        @(negedge rst);
        @(posedge clk);
        
        for (int i = 0; i < MSG_LEN; i++) begin
            
            // wait for pause signals
            cycle_start();
            while (pause_req == 1 || pause_ack == 1) begin
                cycle_end();
                cycle_start();
            end
            cycle_end();
            
            rx = 0; // start bit
            parity = 0;
            #(1s / BAUD_RATE);
            for (int j = 0; j < data_length; j++) begin
                rx = i[j]; // data bits
                parity = parity ^ i[j];
                #(1s / BAUD_RATE);
            end
            if (parity_control) begin
                rx = parity ^ parity_select; // parity bit
                #(1s / BAUD_RATE);
            end
            for(int j = 0; j < 1 + stop_bits; j++) begin
                rx = 1; // stop bit
                #(1s / BAUD_RATE);
            end
        end
    end

    task cycle_start();
        #TT;
    endtask

    task cycle_end();
        @(posedge clk);
    endtask

endmodule