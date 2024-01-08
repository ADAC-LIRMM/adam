`timescale 1ns/1ps
`include "adam/macros_bhv.svh"
`include "vunit_defines.svh"

module adam_periph_tb;

    `ADAM_BHV_CFG_LOCALPARAMS;

    localparam NO_GPIOS  = 1;
    localparam NO_SPIS   = 1;
    localparam NO_TIMERS = 1;
    localparam NO_UARTS  = 1;
    
    localparam NO_SLVS = NO_GPIOS + NO_SPIS + NO_TIMERS + NO_UARTS;
    
    // seq and pause ==========================================================

    ADAM_SEQ   seq   ();
    ADAM_PAUSE pause ();
    
    adam_seq_bhv #(
        `ADAM_BHV_CFG_PARAMS_MAP
    ) adam_seq_bhv (
        .seq (seq)
    );

    adam_pause_bhv #(
        `ADAM_BHV_CFG_PARAMS_MAP,

        .DELAY    (10us),
        .DURATION (10us)
    ) adam_pause_bhv (
        .seq   (seq),
        .pause (pause)
    );
    
    // dut ====================================================================

    APB   slv [NO_SLVS+1] ();
    logic irq [NO_SLVS+1];

    ADAM_IO     gpio_io   [NO_GPIOS*GPIO_WIDTH+1] ();
    logic [1:0] gpio_func [NO_GPIOS*GPIO_WIDTH+1];
    
    ADAM_IO spi_sclk [NO_SPIS+1] ();
    ADAM_IO spi_mosi [NO_SPIS+1] ();
    ADAM_IO spi_miso [NO_SPIS+1] ();
    ADAM_IO spi_ss_n [NO_SPIS+1] ();

    ADAM_IO uart_tx [NO_UARTS+1] ();
    ADAM_IO uart_rx [NO_UARTS+1] ();

    generate
        for (genvar i = 0; i < NO_SLVS; i++) begin
            `ADAM_APB_MST_TIE_OFF(slv[i]);
        end

        for (genvar i = 0; i < NO_GPIOS*GPIO_WIDTH; i++) begin
            `ADAM_IO_SLV_TIE_OFF(gpio_io[i]);
        end

        for (genvar i = 0; i < NO_SPIS; i++) begin
            `ADAM_IO_SLV_TIE_OFF(spi_sclk[i]);
            `ADAM_IO_SLV_TIE_OFF(spi_mosi[i]);
            `ADAM_IO_SLV_TIE_OFF(spi_miso[i]);
            `ADAM_IO_SLV_TIE_OFF(spi_ss_n[i]);
        end

        for (genvar i = 0; i < NO_UARTS; i++) begin
            `ADAM_IO_SLV_TIE_OFF(uart_tx[i]);
            `ADAM_IO_SLV_TIE_OFF(uart_rx[i]);
        end
    endgenerate

    adam_periph #(
        `ADAM_CFG_PARAMS_MAP,

        .NO_GPIOS  (NO_GPIOS),
        .NO_SPIS   (NO_SPIS),
        .NO_TIMERS (NO_TIMERS),
        .NO_UARTS  (NO_UARTS)
    ) dut (
        .seq   (seq),
        .pause (pause),

        .slv (slv),
        .irq (irq),
        
        .gpio_io   (gpio_io),
        .gpio_func (gpio_func),
    
        .spi_sclk (spi_sclk),
        .spi_mosi (spi_mosi),
        .spi_miso (spi_miso),
        .spi_ss_n (spi_ss_n),

        .uart_tx (uart_tx),
        .uart_rx (uart_rx)
    );

    // test ===================================================================
      
    `TEST_SUITE begin
        `TEST_CASE("test") begin
            `ADAM_UNTIL(!seq.rst);
            `ADAM_UNTIL(!pause.req && !pause.ack);
            `ADAM_UNTIL(pause.req && pause.ack);
            `ADAM_UNTIL(!pause.req && !pause.ack);
        end
    end

    initial begin
        #1000us $error("timeout");
    end

    task cycle_start();
        #TT;
    endtask

    task cycle_end();
        @(posedge seq.clk);
    endtask

endmodule