`timescale 1ns/1ps
`include "vunit_defines.svh"

module adam_tb;

    localparam ADDR_WIDTH = 32;
    localparam DATA_WIDTH = 32;
    localparam GPIO_WIDTH = 16;

    localparam NO_CPUS = 2;
    localparam NO_MEMS = 3;
    
    localparam EN_LPCPU = 1;
    localparam EN_LPMEM = 1;
    localparam EN_DEBUG = 1;

    localparam NO_LSBP_GPIOS  = 1;
    localparam NO_LSBP_SPIS   = 1;
    localparam NO_LSBP_TIMERS = 1;
    localparam NO_LSBP_UARTS  = 1;

    localparam BOOT_ADDR = 32'h0000_0000;
    
    localparam integer MEM_SIZE [NO_MEMS] = 
        '{32768, 32768, 32768};

    localparam CLK_PERIOD = 20ns;
    localparam RST_CYCLES = 5;

    localparam TA = 2ns;
    localparam TT = CLK_PERIOD - TA;

    localparam NO_GPIOS  = NO_LSBP_GPIOS;
    localparam NO_SPIS   = NO_LSBP_SPIS;
    localparam NO_TIMERS = NO_LSBP_TIMERS;
    localparam NO_UARTS  = NO_LSBP_UARTS;

    ADAM_SEQ   lsdom_seq ();
    ADAM_PAUSE lsdom_pause ();

    ADAM_SEQ   lsdom_lpmem_seq ();
    ADAM_PAUSE lsdom_lpmem_pause ();
    AXI_LITE   lsdom_lpmem_axil ();

    ADAM_SEQ hsdom_seq ();

    ADAM_SEQ   hsdom_mem_seq   [NO_MEMS] ();
    ADAM_PAUSE hsdom_mem_pause [NO_MEMS] ();
    AXI_LITE   hsdom_mem_axil  [NO_MEMS] ();

    ADAM_IO     gpio_io   [NO_GPIOS*GPIO_WIDTH] ();
    logic [1:0] gpio_func [NO_GPIOS*GPIO_WIDTH];

    ADAM_IO spi_sclk [NO_SPIS] ();
    ADAM_IO spi_mosi [NO_SPIS] ();
    ADAM_IO spi_miso [NO_SPIS] ();
    ADAM_IO spi_ss_n [NO_SPIS] ();

    ADAM_IO uart_tx [NO_UARTS] ();
    ADAM_IO uart_rx [NO_UARTS] ();

    // TODO: implement pause
    assign lsdom_pause.req = 0;

    assign uart_rx[0].i = uart_tx[0].o; // loopback

    adam_seq_bhv #(
        .CLK_PERIOD (CLK_PERIOD),
        .RST_CYCLES (RST_CYCLES),

        .TA (TA),
        .TT (TT)
    ) lsdom_seq_bhv (
        .seq (lsdom_seq)
    );

    adam_seq_bhv #(
        .CLK_PERIOD (CLK_PERIOD),
        .RST_CYCLES (RST_CYCLES),

        .TA (TA),
        .TT (TT)
    ) hsdom_seq_bhv (
        .seq (hsdom_seq)
    );

    adam #(

    ) dut (
        .lsdom_seq       (lsdom_seq),
        .lsdom_pause     (lsdom_pause),
        .lsdom_lpmem_seq   (lsdom_lpmem_seq),
        .lsdom_lpmem_pause (lsdom_lpmem_pause),
        .lsdom_lpmem_axil  (lsdom_lpmem_axil),

        .hsdom_seq       (hsdom_seq),
        .hsdom_mem_seq   (hsdom_mem_seq),
        .hsdom_mem_pause (hsdom_mem_pause),
        .hsdom_mem_axil  (hsdom_mem_axil),

        .gpio_io   (gpio_io),
        .gpio_func (gpio_func),

        .spi_sclk (spi_sclk),
        .spi_mosi (spi_mosi),
        .spi_miso (spi_miso),
        .spi_ss_n (spi_ss_n),

        .uart_tx (uart_tx),
        .uart_rx (uart_rx)
    );

    generate
        bootloader bootloader (
            .clk   (hsdom_mem_seq[0].clk),
            .rst   (hsdom_mem_seq[0].rst),
            
            .pause_req (hsdom_mem_pause[0].req),
            .pause_ack (hsdom_mem_pause[0].ack),

            .slv (hsdom_mem_axil[0])
        );

        for (genvar i = 1; i < NO_MEMS; i++) begin
            adam_axil_ram #(
                .ADDR_WIDTH (ADDR_WIDTH),
                .DATA_WIDTH (DATA_WIDTH),

                .SIZE (MEM_SIZE[i])
            ) adam_axil_ram (
                .seq   (hsdom_mem_seq[i]),
                .pause (hsdom_mem_pause[i]),

                .slv (hsdom_mem_axil[i])
            );
        end
    endgenerate
    
    `TEST_SUITE begin
        `TEST_CASE("test") begin
            #10us;
        end
    end

endmodule
