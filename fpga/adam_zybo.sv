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

module adam_zybo (
    input  logic clk,
    input  logic rstn,

    output logic uart_tx,
    input  logic uart_rx,

    output logic gpio_io[7:0],

    input  logic spi_miso,
    output logic spi_ss,
    output logic spi_sck,
    output logic spi_mosi

//    input  logic jtag_tck,
//    input  logic jtag_tms,
//    input  logic jtag_tdi,
//    output logic jtag_tdo
);
    `ADAM_CFG_LOCALPARAMS;

    logic [NO_LSPA_GPIOS*GPIO_WIDTH+1:0] lspa_gpio_io_o;

    adam_top #(
        `ADAM_CFG_PARAMS_MAP
    ) i_adam_top (
        .clk_i (clk),
        .rst_i (!rstn),

        .jtag_tck_i ('0),
        .jtag_tms_i ('0),
        .jtag_tdi_i ('0),
        .jtag_tdo_o (),

        .lspa_gpio_io_i       ('0),
        .lspa_gpio_io_o       (lspa_gpio_io_o),
        .lspa_gpio_io_mode_o  (),
        .lspa_gpio_io_otype_o (),
        .lspa_gpio_func_o     (),

        .lspa_spi_sclk_o (spi_sck),
        .lspa_spi_mosi_o (spi_mosi),
        .lspa_spi_miso_i (spi_miso),
        .lspa_spi_ss_n_o (spi_ss),

        .lspa_uart_tx_o (uart_tx),
        .lspa_uart_rx_i (uart_rx),

        .lspb_gpio_io_i       ('0),
        .lspb_gpio_io_o       (),
        .lspb_gpio_io_mode_o  (),
        .lspb_gpio_io_otype_o (),
        .lspb_gpio_func_o     (),

        .lspb_spi_sclk_o (),
        .lspb_spi_mosi_o (),
        .lspb_spi_miso_i ('0),
        .lspb_spi_ss_n_o (),

        .lspb_uart_tx_o (),
        .lspb_uart_rx_i ('0)
    );

    for (genvar i = 0; i < 8; i++) begin
        assign gpio_io[i] = lspa_gpio_io_o[i];
    end
endmodule
