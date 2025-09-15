/*
 * Copyright 2025 LIRMM
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

`include "adam/macros.svh"
`include "apb/assign.svh"
`include "axi/assign.svh"

module adam_wrap #(
    `ADAM_CFG_PARAMS
) (
    // lsdom ==================================================================

    ADAM_SEQ.Slave lsdom_seq,

    output logic            lsdom_lpmem_req,
    output ADDR_T           lsdom_lpmem_addr,
    output logic            lsdom_lpmem_we,
    output STRB_T           lsdom_lpmem_be,
    output DATA_T           lsdom_lpmem_wdata,
    input  DATA_T           lsdom_lpmem_rdata,

    // hsdom ==================================================================

    ADAM_SEQ.Slave hsdom_seq,

    // HSDOM Memory Interface
    output logic            hsdom_mem_req   [NO_MEMS+1],
    output ADDR_T           hsdom_mem_addr  [NO_MEMS+1],
    output logic            hsdom_mem_we    [NO_MEMS+1],
    output STRB_T           hsdom_mem_be    [NO_MEMS+1],
    output DATA_T           hsdom_mem_wdata [NO_MEMS+1],
    input  DATA_T           hsdom_mem_rdata [NO_MEMS+1],

    // jtag ===================================================================

    ADAM_JTAG.Slave jtag,

    // async - lspa ===========================================================
    
    ADAM_IO.Master     lspa_gpio_io   [NO_LSPA_GPIOS*GPIO_WIDTH+1],
    output logic [1:0] lspa_gpio_func [NO_LSPA_GPIOS*GPIO_WIDTH+1],
    
    ADAM_IO.Master lspa_spi_sclk [NO_LSPA_SPIS+1],
    ADAM_IO.Master lspa_spi_mosi [NO_LSPA_SPIS+1],
    ADAM_IO.Master lspa_spi_miso [NO_LSPA_SPIS+1],
    ADAM_IO.Master lspa_spi_ss_n [NO_LSPA_SPIS+1],

    ADAM_IO.Master lspa_uart_tx [NO_LSPA_UARTS+1],
    ADAM_IO.Master lspa_uart_rx [NO_LSPA_UARTS+1],

    // async - lspb ===========================================================

    ADAM_IO.Master     lspb_gpio_io   [NO_LSPB_GPIOS*GPIO_WIDTH+1],
    output logic [1:0] lspb_gpio_func [NO_LSPB_GPIOS*GPIO_WIDTH+1],
    
    ADAM_IO.Master lspb_spi_sclk [NO_LSPB_SPIS+1],
    ADAM_IO.Master lspb_spi_mosi [NO_LSPB_SPIS+1],
    ADAM_IO.Master lspb_spi_miso [NO_LSPB_SPIS+1],
    ADAM_IO.Master lspb_spi_ss_n [NO_LSPB_SPIS+1],

    ADAM_IO.Master lspb_uart_tx [NO_LSPB_UARTS+1],
    ADAM_IO.Master lspb_uart_rx [NO_LSPB_UARTS+1]
);

// hsdom signals =============================================================
logic   hsdom_mem_pause_req   [NO_MEMS+1];
logic   hsdom_mem_pause_ack   [NO_MEMS+1];
genvar i;

generate
    for (i = 0; i < NO_MEMS+1; i++) begin : hsdom_mem
        assign hsdom_mem_pause[i].req = hsdom_mem_pause_req[i];
        assign hsdom_mem_pause_ack[i] = hsdom_mem_pause[i].ack;
    end
endgenerate



// lspa signals ==============================================================
    logic           s_lspa_gpio_io_i      [NO_LSPA_GPIOS*GPIO_WIDTH+1];
    logic           s_lspa_gpio_io_o      [NO_LSPA_GPIOS*GPIO_WIDTH+1];
    logic           s_lspa_gpio_io_mode   [NO_LSPA_GPIOS*GPIO_WIDTH+1];
    logic           s_lspa_gpio_io_otype  [NO_LSPA_GPIOS*GPIO_WIDTH+1];
    // SPI Interface
        // SCLK
    logic           s_lspa_spi_sclk_i      [NO_LSPA_SPIS+1];
    logic           s_lspa_spi_sclk_o      [NO_LSPA_SPIS+1];
    logic           s_lspa_spi_sclk_mode   [NO_LSPA_SPIS+1];
    logic           s_lspa_spi_sclk_otype  [NO_LSPA_SPIS+1];
        // MOSI
    logic           s_lspa_spi_mosi_i      [NO_LSPA_SPIS+1];
    logic           s_lspa_spi_mosi_o      [NO_LSPA_SPIS+1];
    logic           s_lspa_spi_mosi_mode   [NO_LSPA_SPIS+1];
    logic           s_lspa_spi_mosi_otype  [NO_LSPA_SPIS+1];
        // MISO
    logic           s_lspa_spi_miso_i      [NO_LSPA_SPIS+1];
    logic           s_lspa_spi_miso_o      [NO_LSPA_SPIS+1];
    logic           s_lspa_spi_miso_mode   [NO_LSPA_SPIS+1];
    logic           s_lspa_spi_miso_otype  [NO_LSPA_SPIS+1];
        // SS_n
    logic           s_lspa_spi_ss_n_i      [NO_LSPA_SPIS+1];
    logic           s_lspa_spi_ss_n_o      [NO_LSPA_SPIS+1];
    logic           s_lspa_spi_ss_n_mode   [NO_LSPA_SPIS+1];
    logic           s_lspa_spi_ss_n_otype  [NO_LSPA_SPIS+1];
    // UART Interface
        // TX
    logic           s_lspa_uart_tx_i       [NO_LSPA_UARTS+1];
    logic           s_lspa_uart_tx_o       [NO_LSPA_UARTS+1];
    logic           s_lspa_uart_tx_mode    [NO_LSPA_UARTS+1];
    logic           s_lspa_uart_tx_otype   [NO_LSPA_UARTS+1];
        // RX
    logic           s_lspa_uart_rx_i       [NO_LSPA_UARTS+1];
    logic           s_lspa_uart_rx_o       [NO_LSPA_UARTS+1];
    logic           s_lspa_uart_rx_mode    [NO_LSPA_UARTS+1];
    logic           s_lspa_uart_rx_otype   [NO_LSPA_UARTS+1];

generate
    for (i = 0; i <= NO_LSPA_GPIOS*GPIO_WIDTH; i++) begin : lspa_gpio
        assign s_lspa_gpio_io_i[i]      = lspa_gpio_io[i].i;
        assign lspa_gpio_io[i].o        = s_lspa_gpio_io_o[i];
        assign lspa_gpio_io[i].mode     = s_lspa_gpio_io_mode[i];
        assign lspa_gpio_io[i].otype    = s_lspa_gpio_io_otype[i];
    end
    for (i = 0; i<= NO_LSPA_SPIS; i++) begin
        assign s_lspa_spi_sclk_i[i]     = lspa_spi_sclk[i].i;
        assign lspa_spi_sclk[i].o       = s_lspa_spi_sclk_o[i];
        assign lspa_spi_sclk[i].mode    = s_lspa_spi_sclk_mode[i];
        assign lspa_spi_sclk[i].otype   = s_lspa_spi_sclk_otype[i];
    end
    for (i = 0; i<= NO_LSPA_SPIS; i++) begin
        assign s_lspa_spi_mosi_i[i]     = lspa_spi_mosi[i].i;
        assign lspa_spi_mosi[i].o       = s_lspa_spi_mosi_o[i];
        assign lspa_spi_mosi[i].mode    = s_lspa_spi_mosi_mode[i];
        assign lspa_spi_mosi[i].otype   = s_lspa_spi_mosi_otype[i];
    end
    for (i = 0; i<= NO_LSPA_SPIS; i++) begin
        assign s_lspa_spi_miso_i[i]     = lspa_spi_miso[i].i;
        assign lspa_spi_miso[i].o       = s_lspa_spi_miso_o[i];
        assign lspa_spi_miso[i].mode    = s_lspa_spi_miso_mode[i];
        assign lspa_spi_miso[i].otype   = s_lspa_spi_miso_otype[i];
    end
    for (i = 0; i<= NO_LSPA_SPIS; i++) begin
        assign s_lspa_spi_ss_n_i[i]     = lspa_spi_ss_n[i].i;
        assign lspa_spi_ss_n[i].o       = s_lspa_spi_ss_n_o[i];
        assign lspa_spi_ss_n[i].mode    = s_lspa_spi_ss_n_mode[i];
        assign lspa_spi_ss_n[i].otype   = s_lspa_spi_ss_n_otype[i];
    end
    for (i = 0; i<= NO_LSPA_UARTS; i++) begin
        assign s_lspa_uart_tx_i[i]      = lspa_uart_tx[i].i;
        assign lspa_uart_tx[i].o        = s_lspa_uart_tx_o[i];
        assign lspa_uart_tx[i].mode     = s_lspa_uart_tx_mode[i];
        assign lspa_uart_tx[i].otype    = s_lspa_uart_tx_otype[i];
    end
    for (i = 0; i<= NO_LSPA_UARTS; i++) begin
        assign s_lspa_uart_rx_i[i]      = lspa_uart_rx[i].i;
        assign lspa_uart_rx[i].o        = s_lspa_uart_rx_o[i];
        assign lspa_uart_rx[i].mode     = s_lspa_uart_rx_mode[i];
        assign lspa_uart_rx[i].otype    = s_lspa_uart_rx_otype[i];
    end

endgenerate

// lspb signals ==============================================================
    logic           s_lspb_gpio_io_i      [NO_LSPB_GPIOS*GPIO_WIDTH+1];
    logic           s_lspb_gpio_io_o      [NO_LSPB_GPIOS*GPIO_WIDTH+1];
    logic           s_lspb_gpio_io_mode   [NO_LSPB_GPIOS*GPIO_WIDTH+1];
    logic           s_lspb_gpio_io_otype  [NO_LSPB_GPIOS*GPIO_WIDTH+1];
    // SPI Interface
        // SCLK
    logic           s_lspb_spi_sclk_i      [NO_LSPB_SPIS+1];
    logic           s_lspb_spi_sclk_o      [NO_LSPB_SPIS+1];
    logic           s_lspb_spi_sclk_mode   [NO_LSPB_SPIS+1];
    logic           s_lspb_spi_sclk_otype  [NO_LSPB_SPIS+1];
        // MOSI
    logic           s_lspb_spi_mosi_i      [NO_LSPB_SPIS+1];
    logic           s_lspb_spi_mosi_o      [NO_LSPB_SPIS+1];
    logic           s_lspb_spi_mosi_mode   [NO_LSPB_SPIS+1];
    logic           s_lspb_spi_mosi_otype  [NO_LSPB_SPIS+1];
        // MISO
    logic           s_lspb_spi_miso_i      [NO_LSPB_SPIS+1];
    logic           s_lspb_spi_miso_o      [NO_LSPB_SPIS+1];
    logic           s_lspb_spi_miso_mode   [NO_LSPB_SPIS+1];
    logic           s_lspb_spi_miso_otype  [NO_LSPB_SPIS+1];
        // SS_n
    logic           s_lspb_spi_ss_n_i      [NO_LSPB_SPIS+1];
    logic           s_lspb_spi_ss_n_o      [NO_LSPB_SPIS+1];
    logic           s_lspb_spi_ss_n_mode   [NO_LSPB_SPIS+1];
    logic           s_lspb_spi_ss_n_otype  [NO_LSPB_SPIS+1];
    // UART Interface
        // TX
    logic           s_lspb_uart_tx_i       [NO_LSPB_UARTS+1];
    logic           s_lspb_uart_tx_o       [NO_LSPB_UARTS+1];
    logic           s_lspb_uart_tx_mode    [NO_LSPB_UARTS+1];
    logic           s_lspb_uart_tx_otype   [NO_LSPB_UARTS+1];
        // RX
    logic           s_lspb_uart_rx_i       [NO_LSPB_UARTS+1];
    logic           s_lspb_uart_rx_o       [NO_LSPB_UARTS+1];
    logic           s_lspb_uart_rx_mode    [NO_LSPB_UARTS+1];
    logic           s_lspb_uart_rx_otype   [NO_LSPB_UARTS+1];

generate
    for (i = 0; i <= NO_LSPB_GPIOS*GPIO_WIDTH; i++) begin : lspb_gpio
        assign s_lspb_gpio_io_i[i]      = lspb_gpio_io[i].i;
        assign lspb_gpio_io[i].o        = s_lspb_gpio_io_o[i];
        assign lspb_gpio_io[i].mode     = s_lspb_gpio_io_mode[i];
        assign lspb_gpio_io[i].otype    = s_lspb_gpio_io_otype[i];
    end
    for (i = 0; i<= NO_LSPB_SPIS; i++) begin
        assign s_lspb_spi_sclk_i[i]     = lspb_spi_sclk[i].i;
        assign lspb_spi_sclk[i].o       = s_lspb_spi_sclk_o[i];
        assign lspb_spi_sclk[i].mode    = s_lspb_spi_sclk_mode[i];
        assign lspb_spi_sclk[i].otype   = s_lspb_spi_sclk_otype[i];
    end
    for (i = 0; i<= NO_LSPB_SPIS; i++) begin
        assign s_lspb_spi_mosi_i[i]     = lspb_spi_mosi[i].i;
        assign lspb_spi_mosi[i].o       = s_lspb_spi_mosi_o[i];
        assign lspb_spi_mosi[i].mode    = s_lspb_spi_mosi_mode[i];
        assign lspb_spi_mosi[i].otype   = s_lspb_spi_mosi_otype[i];
    end
    for (i = 0; i<= NO_LSPB_SPIS; i++) begin
        assign s_lspb_spi_miso_i[i]     = lspb_spi_miso[i].i;
        assign lspb_spi_miso[i].o       = s_lspb_spi_miso_o[i];
        assign lspb_spi_miso[i].mode    = s_lspb_spi_miso_mode[i];
        assign lspb_spi_miso[i].otype   = s_lspb_spi_miso_otype[i];
    end
    for (i = 0; i<= NO_LSPB_SPIS; i++) begin
        assign s_lspb_spi_ss_n_i[i]     = lspb_spi_ss_n[i].i;
        assign lspb_spi_ss_n[i].o       = s_lspb_spi_ss_n_o[i];
        assign lspb_spi_ss_n[i].mode    = s_lspb_spi_ss_n_mode[i];
        assign lspb_spi_ss_n[i].otype   = s_lspb_spi_ss_n_otype[i];
    end
    for (i = 0; i<= NO_LSPB_UARTS; i++) begin
        assign s_lspb_uart_tx_i[i]      = lspb_uart_tx[i].i;
        assign lspb_uart_tx[i].o        = s_lspb_uart_tx_o[i];
        assign lspb_uart_tx[i].mode     = s_lspb_uart_tx_mode[i];
        assign lspb_uart_tx[i].otype    = s_lspb_uart_tx_otype[i];
    end
    for (i = 0; i<= NO_LSPB_UARTS; i++) begin
        assign s_lspb_uart_rx_i[i]      = lspb_uart_rx[i].i;
        assign lspb_uart_rx[i].o        = s_lspb_uart_rx_o[i];
        assign lspb_uart_rx[i].mode     = s_lspb_uart_rx_mode[i];
        assign lspb_uart_rx[i].otype    = s_lspb_uart_rx_otype[i];
    end
endgenerate


adam_unwrap #(
    `ADAM_CFG_PARAMS_MAP
) adam_unwrap (
    .lsdom_seq_clk              (lsdom_seq.clk),
    .lsdom_seq_rst              (lsdom_seq.rst),
    .lsdom_lpmem_req            (lsdom_lpmem_req),
    .lsdom_lpmem_addr           (lsdom_lpmem_addr),
    .lsdom_lpmem_we             (lsdom_lpmem_we),
    .lsdom_lpmem_be             (lsdom_lpmem_be),
    .lsdom_lpmem_wdata          (lsdom_lpmem_wdata),
    .lsdom_lpmem_rdata          (lsdom_lpmem_rdata),
    .hsdom_seq_clk              (lsdom_seq.clk),
    .hsdom_seq_rst              (lsdom_seq.rst),
    .hsdom_mem_req              (hsdom_mem_req  ),
    .hsdom_mem_addr             (hsdom_mem_addr ),
    .hsdom_mem_we               (hsdom_mem_we   ),
    .hsdom_mem_be               (hsdom_mem_be   ),
    .hsdom_mem_wdata            (hsdom_mem_wdata),
    .hsdom_mem_rdata            (hsdom_mem_rdata),
    .jtag_trst_n                (jtag.trst_n),
    .jtag_tck                   (jtag.tck   ),
    .jtag_tms                   (jtag.tms   ),
    .jtag_tdi                   (jtag.tdi   ),
    .jtag_tdo                   (jtag.tdo   ),
    .lspa_gpio_io_i             (s_lspa_gpio_io_i    ),
    .lspa_gpio_io_o             (s_lspa_gpio_io_o    ),
    .lspa_gpio_io_mode          (s_lspa_gpio_io_mode ),
    .lspa_gpio_io_otype         (s_lspa_gpio_io_otype),
    .lspa_gpio_func             (lspa_gpio_func    ),
    .lspa_spi_sclk_i            (s_lspa_spi_sclk_i    ),
    .lspa_spi_sclk_o            (s_lspa_spi_sclk_o    ),
    .lspa_spi_sclk_mode         (s_lspa_spi_sclk_mode ),
    .lspa_spi_sclk_otype        (s_lspa_spi_sclk_otype),
    .lspa_spi_mosi_i            (s_lspa_spi_mosi_i     ),
    .lspa_spi_mosi_o            (s_lspa_spi_mosi_o     ),
    .lspa_spi_mosi_mode         (s_lspa_spi_mosi_mode  ),
    .lspa_spi_mosi_otype        (s_lspa_spi_mosi_otype ),
    .lspa_spi_miso_i            (s_lspa_spi_miso_i     ),
    .lspa_spi_miso_o            (s_lspa_spi_miso_o     ),
    .lspa_spi_miso_mode         (s_lspa_spi_miso_mode  ),
    .lspa_spi_miso_otype        (s_lspa_spi_miso_otype ),
    .lspa_spi_ss_n_i            (s_lspa_spi_ss_n_i    ),
    .lspa_spi_ss_n_o            (s_lspa_spi_ss_n_o    ),
    .lspa_spi_ss_n_mode         (s_lspa_spi_ss_n_mode ),
    .lspa_spi_ss_n_otype        (s_lspa_spi_ss_n_otype),
    .lspa_uart_tx_i             (s_lspa_uart_tx_i    ),
    .lspa_uart_tx_o             (s_lspa_uart_tx_o    ),
    .lspa_uart_tx_mode          (s_lspa_uart_tx_mode ),
    .lspa_uart_tx_otype         (s_lspa_uart_tx_otype),
    .lspa_uart_rx_i             (s_lspa_uart_rx_i    ),
    .lspa_uart_rx_o             (s_lspa_uart_rx_o    ),
    .lspa_uart_rx_mode          (s_lspa_uart_rx_mode ),
    .lspa_uart_rx_otype         (s_lspa_uart_rx_otype),
    .lspb_gpio_io_i             (s_lspb_gpio_io_i    ),
    .lspb_gpio_io_o             (s_lspb_gpio_io_o    ),
    .lspb_gpio_io_mode          (s_lspb_gpio_io_mode ),
    .lspb_gpio_io_otype         (s_lspb_gpio_io_otype),
    .lspb_gpio_func             (lspb_gpio_func),
    .lspb_spi_sclk_i            (s_lspb_spi_sclk_i    ),
    .lspb_spi_sclk_o            (s_lspb_spi_sclk_o    ),
    .lspb_spi_sclk_mode         (s_lspb_spi_sclk_mode ),
    .lspb_spi_sclk_otype        (s_lspb_spi_sclk_otype),
    .lspb_spi_mosi_i            (s_lspb_spi_mosi_i    ),
    .lspb_spi_mosi_o            (s_lspb_spi_mosi_o    ),
    .lspb_spi_mosi_mode         (s_lspb_spi_mosi_mode ),
    .lspb_spi_mosi_otype        (s_lspb_spi_mosi_otype),
    .lspb_spi_miso_i            (s_lspb_spi_miso_i    ),
    .lspb_spi_miso_o            (s_lspb_spi_miso_o    ),
    .lspb_spi_miso_mode         (s_lspb_spi_miso_mode ),
    .lspb_spi_miso_otype        (s_lspb_spi_miso_otype),
    .lspb_spi_ss_n_i            (s_lspb_spi_ss_n_i    ),
    .lspb_spi_ss_n_o            (s_lspb_spi_ss_n_o    ),
    .lspb_spi_ss_n_mode         (s_lspb_spi_ss_n_mode ),
    .lspb_spi_ss_n_otype        (s_lspb_spi_ss_n_otype),
    .lspb_uart_tx_i             (s_lspb_uart_tx_i    ),
    .lspb_uart_tx_o             (s_lspb_uart_tx_o    ),
    .lspb_uart_tx_mode          (s_lspb_uart_tx_mode ),
    .lspb_uart_tx_otype         (s_lspb_uart_tx_otype),
    .lspb_uart_rx_i             (s_lspb_uart_rx_i    ),
    .lspb_uart_rx_o             (s_lspb_uart_rx_o    ),
    .lspb_uart_rx_mode          (s_lspb_uart_rx_mode ),
    .lspb_uart_rx_otype         (s_lspb_uart_rx_otype)
);

endmodule


// `include "adam/macros.svh"
// `include "apb/assign.svh"
// `include "axi/assign.svh"

// module adam_wrap #(
//     `ADAM_CFG_PARAMS
// ) (
//     // lsdom ==================================================================

//     ADAM_SEQ.Slave lsdom_seq,

//     ADAM_PAUSE.Slave lsdom_pause_ext,

//     output logic      lsdom_lpmem_rst,
//     ADAM_PAUSE.Master lsdom_lpmem_pause,
//     AXI_LITE.Master   lsdom_lpmem_axil,

//     // hsdom ==================================================================

//     ADAM_SEQ.Slave hsdom_seq,

//     output logic      hsdom_mem_rst   [NO_MEMS+1],
//     ADAM_PAUSE.Master hsdom_mem_pause [NO_MEMS+1],
//     AXI_LITE.Master   hsdom_mem_axil  [NO_MEMS+1],

//     // jtag ===================================================================

//     ADAM_JTAG.Slave jtag,

//     // async - lspa ===========================================================
    
//     ADAM_IO.Master     lspa_gpio_io   [NO_LSPA_GPIOS*GPIO_WIDTH+1],
//     output logic [1:0] lspa_gpio_func [NO_LSPA_GPIOS*GPIO_WIDTH+1],
    
//     ADAM_IO.Master lspa_spi_sclk [NO_LSPA_SPIS+1],
//     ADAM_IO.Master lspa_spi_mosi [NO_LSPA_SPIS+1],
//     ADAM_IO.Master lspa_spi_miso [NO_LSPA_SPIS+1],
//     ADAM_IO.Master lspa_spi_ss_n [NO_LSPA_SPIS+1],

//     ADAM_IO.Master lspa_uart_tx [NO_LSPA_UARTS+1],
//     ADAM_IO.Master lspa_uart_rx [NO_LSPA_UARTS+1],

//     // async - lspb ===========================================================

//     ADAM_IO.Master     lspb_gpio_io   [NO_LSPB_GPIOS*GPIO_WIDTH+1],
//     output logic [1:0] lspb_gpio_func [NO_LSPB_GPIOS*GPIO_WIDTH+1],
    
//     ADAM_IO.Master lspb_spi_sclk [NO_LSPB_SPIS+1],
//     ADAM_IO.Master lspb_spi_mosi [NO_LSPB_SPIS+1],
//     ADAM_IO.Master lspb_spi_miso [NO_LSPB_SPIS+1],
//     ADAM_IO.Master lspb_spi_ss_n [NO_LSPB_SPIS+1],

//     ADAM_IO.Master lspb_uart_tx [NO_LSPB_UARTS+1],
//     ADAM_IO.Master lspb_uart_rx [NO_LSPB_UARTS+1]
// );

// // hsdom signals =============================================================
// logic   hsdom_mem_pause_req   [NO_MEMS+1];
// logic   hsdom_mem_pause_ack   [NO_MEMS+1];
// genvar i;

// generate
//     for (i = 0; i < NO_MEMS+1; i++) begin : hsdom_mem
//         assign hsdom_mem_pause[i].req = hsdom_mem_pause_req[i];
//         assign hsdom_mem_pause_ack[i] = hsdom_mem_pause[i].ack;
//     end
// endgenerate

// // AXI Signals ===============================================================
// // LPMEM AXILite Master Interface
// // AW channel
// logic[31:0]                 hsdom_mem_axil_aw_addr [NO_MEMS+1];
// axi_pkg::prot_t         hsdom_mem_axil_aw_prot [NO_MEMS+1];
// logic                   hsdom_mem_axil_aw_valid [NO_MEMS+1];
// logic                   hsdom_mem_axil_aw_ready [NO_MEMS+1];
// // W channel
// logic[31:0]                  hsdom_mem_axil_w_data [NO_MEMS+1];
// logic[3:0]                  hsdom_mem_axil_w_strb [NO_MEMS+1];
// logic                   hsdom_mem_axil_w_valid [NO_MEMS+1];
// logic                   hsdom_mem_axil_w_ready [NO_MEMS+1];
// // B channel
// axi_pkg::resp_t  hsdom_mem_axil_b_resp [NO_MEMS+1];
// logic            hsdom_mem_axil_b_valid [NO_MEMS+1];
// logic            hsdom_mem_axil_b_ready [NO_MEMS+1];
// // AR channel
// logic[31:0]                 hsdom_mem_axil_ar_addr [NO_MEMS+1];
// axi_pkg::prot_t         hsdom_mem_axil_ar_prot [NO_MEMS+1];
// logic                   hsdom_mem_axil_ar_valid [NO_MEMS+1];
// logic                   hsdom_mem_axil_ar_ready [NO_MEMS+1];
// // R channel
// logic[31:0]                  hsdom_mem_axil_r_data [NO_MEMS+1];
// axi_pkg::resp_t         hsdom_mem_axil_r_resp [NO_MEMS+1];
// logic                   hsdom_mem_axil_r_valid [NO_MEMS+1];
// logic                   hsdom_mem_axil_r_ready [NO_MEMS+1];

// generate
//     for (i = 0; i < NO_MEMS+1; i++) begin 
//         assign hsdom_mem_axil[i].aw_addr  = hsdom_mem_axil_aw_addr[i];
//         assign hsdom_mem_axil[i].aw_prot  = hsdom_mem_axil_aw_prot[i];
//         assign hsdom_mem_axil[i].aw_valid = hsdom_mem_axil_aw_valid[i];
//         assign hsdom_mem_axil_aw_ready[i] = hsdom_mem_axil[i].aw_ready;

//         assign hsdom_mem_axil[i].w_data  = hsdom_mem_axil_w_data[i];
//         assign hsdom_mem_axil[i].w_strb  = hsdom_mem_axil_w_strb[i];
//         assign hsdom_mem_axil[i].w_valid = hsdom_mem_axil_w_valid[i];
//         assign hsdom_mem_axil_w_ready[i] = hsdom_mem_axil[i].w_ready;

//         assign hsdom_mem_axil_b_resp[i] = hsdom_mem_axil[i].b_resp;
//         assign hsdom_mem_axil_b_valid[i] = hsdom_mem_axil[i].b_valid;
//         assign hsdom_mem_axil[i].b_ready = hsdom_mem_axil_b_ready[i];

//         assign hsdom_mem_axil[i].ar_addr  = hsdom_mem_axil_ar_addr[i];
//         assign hsdom_mem_axil[i].ar_prot  = hsdom_mem_axil_ar_prot[i];
//         assign hsdom_mem_axil[i].ar_valid = hsdom_mem_axil_ar_valid[i];
//         assign hsdom_mem_axil_ar_ready[i] = hsdom_mem_axil[i].ar_ready;

//         assign hsdom_mem_axil_r_data[i] = hsdom_mem_axil[i].r_data;
//         assign hsdom_mem_axil_r_resp[i] = hsdom_mem_axil[i].r_resp;
//         assign hsdom_mem_axil_r_valid[i] = hsdom_mem_axil[i].r_valid;
//         assign hsdom_mem_axil[i].r_ready = hsdom_mem_axil_r_ready[i];
//     end
// endgenerate

// // lspa signals ==============================================================
//     logic           s_lspa_gpio_io_i      [NO_LSPA_GPIOS*GPIO_WIDTH+1];
//     logic           s_lspa_gpio_io_o      [NO_LSPA_GPIOS*GPIO_WIDTH+1];
//     logic           s_lspa_gpio_io_mode   [NO_LSPA_GPIOS*GPIO_WIDTH+1];
//     logic           s_lspa_gpio_io_otype  [NO_LSPA_GPIOS*GPIO_WIDTH+1];
//     // SPI Interface
//         // SCLK
//     logic           s_lspa_spi_sclk_i      [NO_LSPA_SPIS+1];
//     logic           s_lspa_spi_sclk_o      [NO_LSPA_SPIS+1];
//     logic           s_lspa_spi_sclk_mode   [NO_LSPA_SPIS+1];
//     logic           s_lspa_spi_sclk_otype  [NO_LSPA_SPIS+1];
//         // MOSI
//     logic           s_lspa_spi_mosi_i      [NO_LSPA_SPIS+1];
//     logic           s_lspa_spi_mosi_o      [NO_LSPA_SPIS+1];
//     logic           s_lspa_spi_mosi_mode   [NO_LSPA_SPIS+1];
//     logic           s_lspa_spi_mosi_otype  [NO_LSPA_SPIS+1];
//         // MISO
//     logic           s_lspa_spi_miso_i      [NO_LSPA_SPIS+1];
//     logic           s_lspa_spi_miso_o      [NO_LSPA_SPIS+1];
//     logic           s_lspa_spi_miso_mode   [NO_LSPA_SPIS+1];
//     logic           s_lspa_spi_miso_otype  [NO_LSPA_SPIS+1];
//         // SS_n
//     logic           s_lspa_spi_ss_n_i      [NO_LSPA_SPIS+1];
//     logic           s_lspa_spi_ss_n_o      [NO_LSPA_SPIS+1];
//     logic           s_lspa_spi_ss_n_mode   [NO_LSPA_SPIS+1];
//     logic           s_lspa_spi_ss_n_otype  [NO_LSPA_SPIS+1];
//     // UART Interface
//         // TX
//     logic           s_lspa_uart_tx_i       [NO_LSPA_UARTS+1];
//     logic           s_lspa_uart_tx_o       [NO_LSPA_UARTS+1];
//     logic           s_lspa_uart_tx_mode    [NO_LSPA_UARTS+1];
//     logic           s_lspa_uart_tx_otype   [NO_LSPA_UARTS+1];
//         // RX
//     logic           s_lspa_uart_rx_i       [NO_LSPA_UARTS+1];
//     logic           s_lspa_uart_rx_o       [NO_LSPA_UARTS+1];
//     logic           s_lspa_uart_rx_mode    [NO_LSPA_UARTS+1];
//     logic           s_lspa_uart_rx_otype   [NO_LSPA_UARTS+1];

// generate
//     for (i = 0; i <= NO_LSPA_GPIOS*GPIO_WIDTH; i++) begin : lspa_gpio
//         assign s_lspa_gpio_io_i[i]      = lspa_gpio_io[i].i;
//         assign lspa_gpio_io[i].o        = s_lspa_gpio_io_o[i];
//         assign lspa_gpio_io[i].mode     = s_lspa_gpio_io_mode[i];
//         assign lspa_gpio_io[i].otype    = s_lspa_gpio_io_otype[i];
//     end
//     for (i = 0; i<= NO_LSPA_SPIS; i++) begin
//         assign s_lspa_spi_sclk_i[i]     = lspa_spi_sclk[i].i;
//         assign lspa_spi_sclk[i].o       = s_lspa_spi_sclk_o[i];
//         assign lspa_spi_sclk[i].mode    = s_lspa_spi_sclk_mode[i];
//         assign lspa_spi_sclk[i].otype   = s_lspa_spi_sclk_otype[i];
//     end
//     for (i = 0; i<= NO_LSPA_SPIS; i++) begin
//         assign s_lspa_spi_mosi_i[i]     = lspa_spi_mosi[i].i;
//         assign lspa_spi_mosi[i].o       = s_lspa_spi_mosi_o[i];
//         assign lspa_spi_mosi[i].mode    = s_lspa_spi_mosi_mode[i];
//         assign lspa_spi_mosi[i].otype   = s_lspa_spi_mosi_otype[i];
//     end
//     for (i = 0; i<= NO_LSPA_SPIS; i++) begin
//         assign s_lspa_spi_miso_i[i]     = lspa_spi_miso[i].i;
//         assign lspa_spi_miso[i].o       = s_lspa_spi_miso_o[i];
//         assign lspa_spi_miso[i].mode    = s_lspa_spi_miso_mode[i];
//         assign lspa_spi_miso[i].otype   = s_lspa_spi_miso_otype[i];
//     end
//     for (i = 0; i<= NO_LSPA_SPIS; i++) begin
//         assign s_lspa_spi_ss_n_i[i]     = lspa_spi_ss_n[i].i;
//         assign lspa_spi_ss_n[i].o       = s_lspa_spi_ss_n_o[i];
//         assign lspa_spi_ss_n[i].mode    = s_lspa_spi_ss_n_mode[i];
//         assign lspa_spi_ss_n[i].otype   = s_lspa_spi_ss_n_otype[i];
//     end
//     for (i = 0; i<= NO_LSPA_UARTS; i++) begin
//         assign s_lspa_uart_tx_i[i]      = lspa_uart_tx[i].i;
//         assign lspa_uart_tx[i].o        = s_lspa_uart_tx_o[i];
//         assign lspa_uart_tx[i].mode     = s_lspa_uart_tx_mode[i];
//         assign lspa_uart_tx[i].otype    = s_lspa_uart_tx_otype[i];
//     end
//     for (i = 0; i<= NO_LSPA_UARTS; i++) begin
//         assign s_lspa_uart_rx_i[i]      = lspa_uart_rx[i].i;
//         assign lspa_uart_rx[i].o        = s_lspa_uart_rx_o[i];
//         assign lspa_uart_rx[i].mode     = s_lspa_uart_rx_mode[i];
//         assign lspa_uart_rx[i].otype    = s_lspa_uart_rx_otype[i];
//     end

// endgenerate

// // lspb signals ==============================================================
//     logic           s_lspb_gpio_io_i      [NO_LSPB_GPIOS*GPIO_WIDTH+1];
//     logic           s_lspb_gpio_io_o      [NO_LSPB_GPIOS*GPIO_WIDTH+1];
//     logic           s_lspb_gpio_io_mode   [NO_LSPB_GPIOS*GPIO_WIDTH+1];
//     logic           s_lspb_gpio_io_otype  [NO_LSPB_GPIOS*GPIO_WIDTH+1];
//     // SPI Interface
//         // SCLK
//     logic           s_lspb_spi_sclk_i      [NO_LSPB_SPIS+1];
//     logic           s_lspb_spi_sclk_o      [NO_LSPB_SPIS+1];
//     logic           s_lspb_spi_sclk_mode   [NO_LSPB_SPIS+1];
//     logic           s_lspb_spi_sclk_otype  [NO_LSPB_SPIS+1];
//         // MOSI
//     logic           s_lspb_spi_mosi_i      [NO_LSPB_SPIS+1];
//     logic           s_lspb_spi_mosi_o      [NO_LSPB_SPIS+1];
//     logic           s_lspb_spi_mosi_mode   [NO_LSPB_SPIS+1];
//     logic           s_lspb_spi_mosi_otype  [NO_LSPB_SPIS+1];
//         // MISO
//     logic           s_lspb_spi_miso_i      [NO_LSPB_SPIS+1];
//     logic           s_lspb_spi_miso_o      [NO_LSPB_SPIS+1];
//     logic           s_lspb_spi_miso_mode   [NO_LSPB_SPIS+1];
//     logic           s_lspb_spi_miso_otype  [NO_LSPB_SPIS+1];
//         // SS_n
//     logic           s_lspb_spi_ss_n_i      [NO_LSPB_SPIS+1];
//     logic           s_lspb_spi_ss_n_o      [NO_LSPB_SPIS+1];
//     logic           s_lspb_spi_ss_n_mode   [NO_LSPB_SPIS+1];
//     logic           s_lspb_spi_ss_n_otype  [NO_LSPB_SPIS+1];
//     // UART Interface
//         // TX
//     logic           s_lspb_uart_tx_i       [NO_LSPB_UARTS+1];
//     logic           s_lspb_uart_tx_o       [NO_LSPB_UARTS+1];
//     logic           s_lspb_uart_tx_mode    [NO_LSPB_UARTS+1];
//     logic           s_lspb_uart_tx_otype   [NO_LSPB_UARTS+1];
//         // RX
//     logic           s_lspb_uart_rx_i       [NO_LSPB_UARTS+1];
//     logic           s_lspb_uart_rx_o       [NO_LSPB_UARTS+1];
//     logic           s_lspb_uart_rx_mode    [NO_LSPB_UARTS+1];
//     logic           s_lspb_uart_rx_otype   [NO_LSPB_UARTS+1];

// generate
//     for (i = 0; i <= NO_LSPB_GPIOS*GPIO_WIDTH; i++) begin : lspb_gpio
//         assign s_lspb_gpio_io_i[i]      = lspb_gpio_io[i].i;
//         assign lspb_gpio_io[i].o        = s_lspb_gpio_io_o[i];
//         assign lspb_gpio_io[i].mode     = s_lspb_gpio_io_mode[i];
//         assign lspb_gpio_io[i].otype    = s_lspb_gpio_io_otype[i];
//     end
//     for (i = 0; i<= NO_LSPB_SPIS; i++) begin
//         assign s_lspb_spi_sclk_i[i]     = lspb_spi_sclk[i].i;
//         assign lspb_spi_sclk[i].o       = s_lspb_spi_sclk_o[i];
//         assign lspb_spi_sclk[i].mode    = s_lspb_spi_sclk_mode[i];
//         assign lspb_spi_sclk[i].otype   = s_lspb_spi_sclk_otype[i];
//     end
//     for (i = 0; i<= NO_LSPB_SPIS; i++) begin
//         assign s_lspb_spi_mosi_i[i]     = lspb_spi_mosi[i].i;
//         assign lspb_spi_mosi[i].o       = s_lspb_spi_mosi_o[i];
//         assign lspb_spi_mosi[i].mode    = s_lspb_spi_mosi_mode[i];
//         assign lspb_spi_mosi[i].otype   = s_lspb_spi_mosi_otype[i];
//     end
//     for (i = 0; i<= NO_LSPB_SPIS; i++) begin
//         assign s_lspb_spi_miso_i[i]     = lspb_spi_miso[i].i;
//         assign lspb_spi_miso[i].o       = s_lspb_spi_miso_o[i];
//         assign lspb_spi_miso[i].mode    = s_lspb_spi_miso_mode[i];
//         assign lspb_spi_miso[i].otype   = s_lspb_spi_miso_otype[i];
//     end
//     for (i = 0; i<= NO_LSPB_SPIS; i++) begin
//         assign s_lspb_spi_ss_n_i[i]     = lspb_spi_ss_n[i].i;
//         assign lspb_spi_ss_n[i].o       = s_lspb_spi_ss_n_o[i];
//         assign lspb_spi_ss_n[i].mode    = s_lspb_spi_ss_n_mode[i];
//         assign lspb_spi_ss_n[i].otype   = s_lspb_spi_ss_n_otype[i];
//     end
//     for (i = 0; i<= NO_LSPB_UARTS; i++) begin
//         assign s_lspb_uart_tx_i[i]      = lspb_uart_tx[i].i;
//         assign lspb_uart_tx[i].o        = s_lspb_uart_tx_o[i];
//         assign lspb_uart_tx[i].mode     = s_lspb_uart_tx_mode[i];
//         assign lspb_uart_tx[i].otype    = s_lspb_uart_tx_otype[i];
//     end
//     for (i = 0; i<= NO_LSPB_UARTS; i++) begin
//         assign s_lspb_uart_rx_i[i]      = lspb_uart_rx[i].i;
//         assign lspb_uart_rx[i].o        = s_lspb_uart_rx_o[i];
//         assign lspb_uart_rx[i].mode     = s_lspb_uart_rx_mode[i];
//         assign lspb_uart_rx[i].otype    = s_lspb_uart_rx_otype[i];
//     end
// endgenerate


// adam_unwrap #(
//     `ADAM_CFG_PARAMS_MAP
// ) adam_unwrap (
//     .lsdom_seq_clk              (lsdom_seq.clk),
//     .lsdom_seq_rst              (lsdom_seq.rst),
//     .lsdom_pause_ext_req        (lsdom_pause_ext.req),
//     .lsdom_pause_ext_ack        (lsdom_pause_ext.ack),
//     .lsdom_lpmem_rst            (lsdom_lpmem_rst),
//     .lsdom_lpmem_pause_req      (lsdom_lpmem_pause.req),
//     .lsdom_lpmem_pause_ack      (lsdom_lpmem_pause.ack),
//     .lsdom_lpmem_axil_aw_addr   (lsdom_lpmem_axil.aw_addr),
//     .lsdom_lpmem_axil_aw_prot   (lsdom_lpmem_axil.aw_prot),
//     .lsdom_lpmem_axil_aw_valid  (lsdom_lpmem_axil.aw_valid),
//     .lsdom_lpmem_axil_aw_ready  (lsdom_lpmem_axil.aw_ready),
//     .lsdom_lpmem_axil_w_data    (lsdom_lpmem_axil.w_data),
//     .lsdom_lpmem_axil_w_strb    (lsdom_lpmem_axil.w_strb),
//     .lsdom_lpmem_axil_w_valid   (lsdom_lpmem_axil.w_valid),
//     .lsdom_lpmem_axil_w_ready   (lsdom_lpmem_axil.w_ready),
//     .lsdom_lpmem_axil_b_resp    (lsdom_lpmem_axil.b_resp),
//     .lsdom_lpmem_axil_b_valid   (lsdom_lpmem_axil.b_valid ),
//     .lsdom_lpmem_axil_b_ready   (lsdom_lpmem_axil.b_ready ),
//     .lsdom_lpmem_axil_ar_addr   (lsdom_lpmem_axil.ar_addr ),
//     .lsdom_lpmem_axil_ar_prot   (lsdom_lpmem_axil.ar_prot ),
//     .lsdom_lpmem_axil_ar_valid  (lsdom_lpmem_axil.ar_valid),
//     .lsdom_lpmem_axil_ar_ready  (lsdom_lpmem_axil.ar_ready),
//     .lsdom_lpmem_axil_r_data    (lsdom_lpmem_axil.r_data  ),
//     .lsdom_lpmem_axil_r_resp    (lsdom_lpmem_axil.r_resp  ),
//     .lsdom_lpmem_axil_r_valid   (lsdom_lpmem_axil.r_valid ),
//     .lsdom_lpmem_axil_r_ready   (lsdom_lpmem_axil.r_ready ),
//     .hsdom_seq_clk              (lsdom_seq.clk),
//     .hsdom_seq_rst              (lsdom_seq.rst),
//     .hsdom_mem_rst              (hsdom_mem_rst),
//     .hsdom_mem_pause_req        (hsdom_mem_pause_req),
//     .hsdom_mem_pause_ack        (hsdom_mem_pause_ack),
//     .hsdom_mem_axil_aw_addr     (hsdom_mem_axil_aw_addr ),
//     .hsdom_mem_axil_aw_prot     (hsdom_mem_axil_aw_prot ),
//     .hsdom_mem_axil_aw_valid    (hsdom_mem_axil_aw_valid),
//     .hsdom_mem_axil_aw_ready    (hsdom_mem_axil_aw_ready),
//     .hsdom_mem_axil_w_data      (hsdom_mem_axil_w_data  ),
//     .hsdom_mem_axil_w_strb      (hsdom_mem_axil_w_strb  ),
//     .hsdom_mem_axil_w_valid     (hsdom_mem_axil_w_valid ),
//     .hsdom_mem_axil_w_ready     (hsdom_mem_axil_w_ready ),
//     .hsdom_mem_axil_b_resp      (hsdom_mem_axil_b_resp  ),
//     .hsdom_mem_axil_b_valid     (hsdom_mem_axil_b_valid ),
//     .hsdom_mem_axil_b_ready     (hsdom_mem_axil_b_ready ),
//     .hsdom_mem_axil_ar_addr     (hsdom_mem_axil_ar_addr ),
//     .hsdom_mem_axil_ar_prot     (hsdom_mem_axil_ar_prot ),
//     .hsdom_mem_axil_ar_valid    (hsdom_mem_axil_ar_valid),
//     .hsdom_mem_axil_ar_ready    (hsdom_mem_axil_ar_ready),
//     .hsdom_mem_axil_r_data      (hsdom_mem_axil_r_data  ),
//     .hsdom_mem_axil_r_resp      (hsdom_mem_axil_r_resp  ),
//     .hsdom_mem_axil_r_valid     (hsdom_mem_axil_r_valid ),
//     .hsdom_mem_axil_r_ready     (hsdom_mem_axil_r_ready ),
//     .jtag_trst_n                (jtag.trst_n),
//     .jtag_tck                   (jtag.tck   ),
//     .jtag_tms                   (jtag.tms   ),
//     .jtag_tdi                   (jtag.tdi   ),
//     .jtag_tdo                   (jtag.tdo   ),
//     .lspa_gpio_io_i             (s_lspa_gpio_io_i    ),
//     .lspa_gpio_io_o             (s_lspa_gpio_io_o    ),
//     .lspa_gpio_io_mode          (s_lspa_gpio_io_mode ),
//     .lspa_gpio_io_otype         (s_lspa_gpio_io_otype),
//     .lspa_gpio_func             (lspa_gpio_func    ),
//     .lspa_spi_sclk_i            (s_lspa_spi_sclk_i    ),
//     .lspa_spi_sclk_o            (s_lspa_spi_sclk_o    ),
//     .lspa_spi_sclk_mode         (s_lspa_spi_sclk_mode ),
//     .lspa_spi_sclk_otype        (s_lspa_spi_sclk_otype),
//     .lspa_spi_mosi_i            (s_lspa_spi_mosi_i     ),
//     .lspa_spi_mosi_o            (s_lspa_spi_mosi_o     ),
//     .lspa_spi_mosi_mode         (s_lspa_spi_mosi_mode  ),
//     .lspa_spi_mosi_otype        (s_lspa_spi_mosi_otype ),
//     .lspa_spi_miso_i            (s_lspa_spi_miso_i     ),
//     .lspa_spi_miso_o            (s_lspa_spi_miso_o     ),
//     .lspa_spi_miso_mode         (s_lspa_spi_miso_mode  ),
//     .lspa_spi_miso_otype        (s_lspa_spi_miso_otype ),
//     .lspa_spi_ss_n_i            (s_lspa_spi_ss_n_i    ),
//     .lspa_spi_ss_n_o            (s_lspa_spi_ss_n_o    ),
//     .lspa_spi_ss_n_mode         (s_lspa_spi_ss_n_mode ),
//     .lspa_spi_ss_n_otype        (s_lspa_spi_ss_n_otype),
//     .lspa_uart_tx_i             (s_lspa_uart_tx_i    ),
//     .lspa_uart_tx_o             (s_lspa_uart_tx_o    ),
//     .lspa_uart_tx_mode          (s_lspa_uart_tx_mode ),
//     .lspa_uart_tx_otype         (s_lspa_uart_tx_otype),
//     .lspa_uart_rx_i             (s_lspa_uart_rx_i    ),
//     .lspa_uart_rx_o             (s_lspa_uart_rx_o    ),
//     .lspa_uart_rx_mode          (s_lspa_uart_rx_mode ),
//     .lspa_uart_rx_otype         (s_lspa_uart_rx_otype),
//     .lspb_gpio_io_i             (s_lspb_gpio_io_i    ),
//     .lspb_gpio_io_o             (s_lspb_gpio_io_o    ),
//     .lspb_gpio_io_mode          (s_lspb_gpio_io_mode ),
//     .lspb_gpio_io_otype         (s_lspb_gpio_io_otype),
//     .lspb_gpio_func             (lspb_gpio_func),
//     .lspb_spi_sclk_i            (s_lspb_spi_sclk_i    ),
//     .lspb_spi_sclk_o            (s_lspb_spi_sclk_o    ),
//     .lspb_spi_sclk_mode         (s_lspb_spi_sclk_mode ),
//     .lspb_spi_sclk_otype        (s_lspb_spi_sclk_otype),
//     .lspb_spi_mosi_i            (s_lspb_spi_mosi_i    ),
//     .lspb_spi_mosi_o            (s_lspb_spi_mosi_o    ),
//     .lspb_spi_mosi_mode         (s_lspb_spi_mosi_mode ),
//     .lspb_spi_mosi_otype        (s_lspb_spi_mosi_otype),
//     .lspb_spi_miso_i            (s_lspb_spi_miso_i    ),
//     .lspb_spi_miso_o            (s_lspb_spi_miso_o    ),
//     .lspb_spi_miso_mode         (s_lspb_spi_miso_mode ),
//     .lspb_spi_miso_otype        (s_lspb_spi_miso_otype),
//     .lspb_spi_ss_n_i            (s_lspb_spi_ss_n_i    ),
//     .lspb_spi_ss_n_o            (s_lspb_spi_ss_n_o    ),
//     .lspb_spi_ss_n_mode         (s_lspb_spi_ss_n_mode ),
//     .lspb_spi_ss_n_otype        (s_lspb_spi_ss_n_otype),
//     .lspb_uart_tx_i             (s_lspb_uart_tx_i    ),
//     .lspb_uart_tx_o             (s_lspb_uart_tx_o    ),
//     .lspb_uart_tx_mode          (s_lspb_uart_tx_mode ),
//     .lspb_uart_tx_otype         (s_lspb_uart_tx_otype),
//     .lspb_uart_rx_i             (s_lspb_uart_rx_i    ),
//     .lspb_uart_rx_o             (s_lspb_uart_rx_o    ),
//     .lspb_uart_rx_mode          (s_lspb_uart_rx_mode ),
//     .lspb_uart_rx_otype         (s_lspb_uart_rx_otype)
// );

// endmodule