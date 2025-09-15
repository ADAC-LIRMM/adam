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

`timescale 1ns/1ps
`include "adam/macros_bhv.svh"
`include "adam/macros.svh"
// `include "vunit_defines.svh"

module adam_zybo_tb;
    import adam_jtag_mst_bhv::*;

    `ADAM_BHV_CFG_LOCALPARAMS;
    localparam integer LPMEM_SIZE = 1024;

    localparam integer MEM_SIZE [NO_MEMS+1] = 
        '{8192, 8192, 0};

    logic clk;
    logic rstn;
    logic uart_tx;
    logic uart_rx;
    logic gpio_io[7:0];
    logic spi_miso;
    logic spi_ss;
    logic spi_sck;
    logic spi_mosi;

    localparam integer ZYBO_CLOCK_PERIOD = 8;
adam_zybo dut (
    .clk            (clk     ),
    .rstn           (rstn    ),
    .uart_tx        (uart_tx ),
    .uart_rx        (uart_rx ),
    .gpio_io        (gpio_io ),
    .spi_miso       (spi_miso),
    .spi_ss         (spi_ss  ),
    .spi_sck        (spi_sck ),
    .spi_mosi       (spi_mosi)
);

initial begin
        clk <= 1;
        forever #(ZYBO_CLOCK_PERIOD/2) clk <= ~clk;
end
initial begin
        rstn <= 0;
        #(ZYBO_CLOCK_PERIOD*5);
        rstn <= 1;
end
endmodule