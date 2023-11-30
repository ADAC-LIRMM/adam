`include "adam/macros_bhv.svh"
`include "vunit_defines.svh"

module adam_periph_uart_tx_tb;
    import adam_stream_mst_bhv::*;

    localparam DATA_WIDTH = 32;

    localparam CLK_PERIOD = 20ns;
    localparam RST_CYCLES = 5;

    localparam TA = 2ns;
    localparam TT = CLK_PERIOD - TA;

    localparam BAUD_RATE = 115200;
    localparam MSG_LEN   = 256;

    typedef logic [DATA_WIDTH-1:0] data_t;
    
    ADAM_SEQ   seq   ();
    ADAM_PAUSE pause ();

    logic       parity_select;
    logic       parity_control;
    logic [3:0] data_length;
    logic [1:0] stop_bits;
    data_t      baud_rate;
    
    `ADAM_STREAM_MST_BHV_FACTORY(data_t, TA, TT, mst, seq.clk);

    logic tx;

    adam_periph_uart_tx #(
        .DATA_WIDTH (DATA_WIDTH)
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
    
    adam_clk_rst_bhv #(
        .CLK_PERIOD (CLK_PERIOD),
        .RST_CYCLES (RST_CYCLES),

        .TA (TA),
        .TT (TT)
    ) adam_clk_rst_bhv (
        .seq (seq)
    );

    adam_pause_bhv #(
        .DELAY    (1ms),
        .DURATION (1ms),

        .TA (TA),
        .TT (TT)
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
                mst_bhv.send(data_t'(i));
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