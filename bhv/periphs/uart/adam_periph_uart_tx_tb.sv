`include "vunit_defines.svh"

module adam_periph_uart_tx_tb;

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
    logic data_valid;
    logic data_ready;
    
    logic tx;

    adam_periph_uart_tx #(
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
        
        .tx (tx)
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
            data           = 0;
            data_valid     = 0;
            
            @(negedge rst);
            @(posedge clk);

            for(int i = 0; i < MSG_LEN; i++) begin
                
                data       <= #TA word_t'(i);
                data_valid <= #TA 1;

                cycle_start();
                while (!data_valid || !data_ready) begin
                    cycle_end();
                    cycle_start();
                end
                cycle_end();

            end
        end
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
        @(posedge clk);
    endtask

endmodule