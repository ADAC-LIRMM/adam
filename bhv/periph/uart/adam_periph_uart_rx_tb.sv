`timescale 1ns/1ps
`include "adam/macros_bhv.svh"
`include "vunit_defines.svh"

module adam_periph_uart_rx_tb;
    import adam_stream_slv_bhv::*;

    `ADAM_BHV_CFG_LOCALPARAMS;

    localparam BAUD_RATE = 115200;
    localparam MSG_LEN   = 256;

    ADAM_SEQ   seq   ();
    ADAM_PAUSE pause ();

    logic       parity_select;
    logic       parity_control;
    logic [3:0] data_length;
    logic [1:0] stop_bits;
    DATA_T      baud_rate;

    `ADAM_STREAM_BHV_SLV_FACTORY(DATA_T, TA, TT, 1, slv, seq.clk);

    logic rx;

    adam_periph_uart_rx #(
        `ADAM_CFG_PARAMS_MAP
    ) dut (
        .seq   (seq),
        .pause (pause),

        .parity_select  (parity_select),
        .parity_control (parity_control),
        .data_length    (data_length),
        .stop_bits      (stop_bits),
        .baud_rate      (baud_rate),

        .mst (slv),

        .rx(rx)
    );

    adam_seq_bhv #(
        `ADAM_BHV_CFG_PARAMS_MAP
    ) adam_seq_bhv (
        .seq (seq)
    );

    adam_pause_bhv #(
        `ADAM_BHV_CFG_PARAMS_MAP,

        .DELAY    (1ms),
        .DURATION (1ms)
    ) adam_pause_bhv (
        .seq   (seq),
        .pause (pause)
    );

    `TEST_SUITE begin
        `TEST_CASE("test") begin
            automatic DATA_T data;

            parity_select  = 0;
            parity_control = 1;
            data_length    = 8;
            stop_bits      = 1;
            baud_rate      = 1s / (BAUD_RATE * CLK_PERIOD);

            @(negedge seq.rst);
            @(posedge seq.clk);

            for (int i = 0; i < MSG_LEN; i++) begin
                slv_bhv.recv(data);
                assert(data == DATA_T'(i));
            end
        end
    end

    initial begin
        #100ms $error("timeout");
    end

    initial begin
        automatic logic parity;

        rx = 1;

        @(negedge seq.rst);
        @(posedge seq.clk);
        
        for (int i = 0; i < MSG_LEN; i++) begin
            
            // wait for pause signals
            `ADAM_UNTIL(pause.req == 0 && pause.ack == 0);
            
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
        @(posedge seq.clk);
    endtask

endmodule