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