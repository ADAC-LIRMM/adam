`include "adam/macros.svh"

module adam_hawkeye #(
    parameter int DinWidth = 32,
    parameter int DoutWidth = 32
) (
    input  logic clk_i,
    input  logic rst_i,

    output logic uart_tx_o,

    // DIN
    input  din_t din_i,
    input  logic din_valid_i,
    output logic din_ready_o,

    // DOUT
    output dout_t dout_o,
    output logic  dout_valid_o,
    input  logic  dout_ready_i,
);

    `ADAM_CFG_LOCALPARAMS;

    logic [NO_LSPA_UARTS+1:0] lspa_uart_tx_o;

    assign uart_tx_o = lspa_uart_tx_o[0];

    adam_top #(
        `ADAM_CFG_PARAMS_MAP
    ) i_adam_top (
        .clk_i (clk),
        .rst_i (!rstn),

        .hsdom_din_i       (din_i),
        .hsdom_din_valid_i (din_valid_i),
        .hsdom_din_ready_o (din_ready_o),

        .hsdom_dout_o       (dout_o),
        .hsdom_dout_valid_o (dout_valid_o),
        .hsdom_dout_ready_i (dout_ready_i),

        .jtag_tck_i ('0),
        .jtag_tms_i ('0),
        .jtag_tdi_i ('0),
        .jtag_tdo_o (),

        .lspa_gpio_io_i       ('0),
        .lspa_gpio_io_o       (),
        .lspa_gpio_io_mode_o  (),
        .lspa_gpio_io_otype_o (),
        .lspa_gpio_func_o     (),

        .lspa_spi_sclk_o (),
        .lspa_spi_mosi_o (),
        .lspa_spi_miso_i ('0),
        .lspa_spi_ss_n_o (),

        .lspa_uart_tx_o (lspa_uart_tx_o),
        .lspa_uart_rx_i ('0),

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

    adam_hawkeye_periph #(
        `ADAM_CFG_PARAMS_MAP,
        .DinWidth (DinWidth),
        .DoutWidth (DoutWidth)
    ) i_adam_hawkeye_periph (
        .clk_i (clk),
        .rst_i (!rstn),

        .req_i    (),
        .gnt_o    (),
        .addr_i   (),
        .we_i     (),
        .be_i     (),
        .wdata_i  (),
        .rvalid_o (),
        .rready_i (),
        .rdata_o  (),

        .din_i       (din_i),
        .din_valid_i (din_valid_i),
        .din_ready_o (din_ready_o),

        .dout_o       (dout_o),
        .dout_valid_o (dout_valid_o),
        .dout_ready_i (dout_ready_i)
    );

endmodule
