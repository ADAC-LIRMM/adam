`timescale 1ns/1ps
`include "adam/macros_bhv.svh"
`include "vunit_defines.svh"

module adam_tb;

    // `ADAM_BHV_CFG_LOCALPARAMS;
    
    // localparam integer MEM_SIZE [NO_MEMS] = 
    //     '{32768, 32768, 32768};

    // ADAM_SEQ   lsdom_seq ();
    // ADAM_PAUSE lsdom_pause ();

    // ADAM_SEQ   lsdom_lpmem_seq ();
    // ADAM_PAUSE lsdom_lpmem_pause ();
    // AXI_LITE   lsdom_lpmem_axil ();

    // ADAM_SEQ hsdom_seq ();

    // ADAM_SEQ   hsdom_mem_seq   [NO_MEMS+1] ();
    // ADAM_PAUSE hsdom_mem_pause [NO_MEMS+1] ();
    // AXI_LITE   hsdom_mem_axil  [NO_MEMS+1] ();

    // ADAM_IO     lspa_gpio_io   [NO_GPIOS*GPIO_WIDTH+1] ();
    // logic [1:0] lspa_gpio_func [NO_GPIOS*GPIO_WIDTH+1];

    // ADAM_IO lspa_spi_sclk [NO_SPIS] ();
    // ADAM_IO lspa_spi_mosi [NO_SPIS] ();
    // ADAM_IO lspa_spi_miso [NO_SPIS] ();
    // ADAM_IO lspa_spi_ss_n [NO_SPIS] ();

    // ADAM_IO lspa_uart_tx [NO_UARTS] ();
    // ADAM_IO lspa_uart_rx [NO_UARTS] ();

    // // TODO: implement pause
    // assign lsdom_pause.req = 0;

    // assign uart_rx[0].i = uart_tx[0].o; // loopback

    // adam_seq_bhv #(
    //     .CLK_PERIOD (CLK_PERIOD),
    //     .RST_CYCLES (RST_CYCLES),

    //     .TA (TA),
    //     .TT (TT)
    // ) lsdom_seq_bhv (
    //     .seq (lsdom_seq)
    // );

    // adam_seq_bhv #(
    //     .CLK_PERIOD (CLK_PERIOD),
    //     .RST_CYCLES (RST_CYCLES),

    //     .TA (TA),
    //     .TT (TT)
    // ) hsdom_seq_bhv (
    //     .seq (hsdom_seq)
    // );

    // adam #(

    // ) dut (
    //     .lsdom_seq       (lsdom_seq),
    //     .lsdom_pause     (lsdom_pause),
    //     .lsdom_lpmem_seq   (lsdom_lpmem_seq),
    //     .lsdom_lpmem_pause (lsdom_lpmem_pause),
    //     .lsdom_lpmem_axil  (lsdom_lpmem_axil),

    //     .hsdom_seq       (hsdom_seq),
    //     .hsdom_mem_seq   (hsdom_mem_seq),
    //     .hsdom_mem_pause (hsdom_mem_pause),
    //     .hsdom_mem_axil  (hsdom_mem_axil),

    //     .gpio_io   (gpio_io),
    //     .gpio_func (gpio_func),

    //     .spi_sclk (spi_sclk),
    //     .spi_mosi (spi_mosi),
    //     .spi_miso (spi_miso),
    //     .spi_ss_n (spi_ss_n),

    //     .uart_tx (uart_tx),
    //     .uart_rx (uart_rx)
    // );

    // generate
    //     bootloader bootloader (
    //         .clk   (hsdom_mem_seq[0].clk),
    //         .rst   (hsdom_mem_seq[0].rst),
            
    //         .pause_req (hsdom_mem_pause[0].req),
    //         .pause_ack (hsdom_mem_pause[0].ack),

    //         .slv (hsdom_mem_axil[0])
    //     );

    //     for (genvar i = 1; i < NO_MEMS; i++) begin
    //         adam_axil_ram #(
    //             `ADAM_CFG_PARAMS_MAP,

    //             .SIZE (MEM_SIZE[i])
    //         ) adam_axil_ram (
    //             .seq   (hsdom_mem_seq[i]),
    //             .pause (hsdom_mem_pause[i]),

    //             .slv (hsdom_mem_axil[i])
    //         );
    //     end
    // endgenerate
    
    `TEST_SUITE begin
        `TEST_CASE("test") begin
            #10us;
        end
    end

endmodule
