`timescale 1ns/1ps
`include "adam/macros_bhv.svh"
`include "vunit_defines.svh"

module adam_periph_uart_tx_tb;
    import adam_stream_mst_bhv::*;

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
    
    `ADAM_STREAM_BHV_MST_FACTORY(DATA_T, TA, TT, mst, seq.clk);

    logic tx;

    adam_periph_uart_tx #(
        `ADAM_CFG_PARAMS_MAP
    ) dut (
        .seq   (seq),
        .pause (pause),

        .parity_select  (parity_select),
        .parity_control (parity_control),
        .data_length    (data_length),
        .stop_bits      (stop_bits),
        .baud_rate      (baud_rate),
        
        .slv (mst),
        
        .tx (tx)
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
            parity_select  = 0;
            parity_control = 1;
            data_length    = 8;
            stop_bits      = 1;
            baud_rate      = 1s / (BAUD_RATE * CLK_PERIOD);
            
            @(negedge seq.rst);
            @(posedge seq.clk);

            for(int i = 0; i < MSG_LEN; i++) begin
                mst_bhv.send(DATA_T'(i));
            end
        end
    end

    initial begin
        #100ms $error("timeout");
    end
    
    initial begin
        automatic logic parity;
        
        for(int i = 0; i < MSG_LEN; i++) begin
            @(negedge tx);
            #(0.5s / BAUD_RATE);
            assert(tx == 0);
            
            parity = 0;

            for(int j = 0; j < data_length; j++) begin
                #(1s / BAUD_RATE);
                parity = parity ^ tx;
                assert (tx == i[j]);
            end

            if(parity_control) begin
                #(1s / BAUD_RATE);
                assert (tx == parity ^ parity_select);
            end

            for(int j = 0; j < 1 + stop_bits; j++) begin
                #(1s / BAUD_RATE);
                assert (tx == 1);
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