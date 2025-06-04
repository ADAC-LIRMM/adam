`include "adam/macros.svh"

module adam_top #(
    `ADAM_CFG_PARAMS,
    parameter type func_t = logic [1:0]
) (

    input  logic clk_i,
    input  logic rst_i,

    input  din_t hsdom_din_i,
    input  logic hsdom_din_valid_i,
    output logic hsdom_din_ready_o,

    output dout_t hsdom_dout_o,
    output logic  hsdom_dout_valid_o,
    input  logic  hsdom_dout_ready_i,

    // jtag ===================================================================

    input  logic jtag_tck_i,
    input  logic jtag_tms_i,
    input  logic jtag_tdi_i,
    output logic jtag_tdo_o,

    // async - lspa ===========================================================

    input  logic  [NO_LSPA_GPIOS*GPIO_WIDTH+1:0] lspa_gpio_io_i,
    output logic  [NO_LSPA_GPIOS*GPIO_WIDTH+1:0] lspa_gpio_io_o,
    output logic  [NO_LSPA_GPIOS*GPIO_WIDTH+1:0] lspa_gpio_io_mode_o,
    output logic  [NO_LSPA_GPIOS*GPIO_WIDTH+1:0] lspa_gpio_io_otype_o,
    output func_t [NO_LSPA_GPIOS*GPIO_WIDTH+1:0] lspa_gpio_func_o,

    output logic [NO_LSPA_SPIS+1:0] lspa_spi_sclk_o,
    output logic [NO_LSPA_SPIS+1:0] lspa_spi_mosi_o,
    input  logic [NO_LSPA_SPIS+1:0] lspa_spi_miso_i,
    output logic [NO_LSPA_SPIS+1:0] lspa_spi_ss_n_o,

    output logic [NO_LSPA_UARTS+1:0] lspa_uart_tx_o,
    input  logic [NO_LSPA_UARTS+1:0] lspa_uart_rx_i,

    // async - lspb ===========================================================

    input  logic  [NO_LSPB_GPIOS*GPIO_WIDTH+1:0] lspb_gpio_io_i,
    output logic  [NO_LSPB_GPIOS*GPIO_WIDTH+1:0] lspb_gpio_io_o,
    output logic  [NO_LSPB_GPIOS*GPIO_WIDTH+1:0] lspb_gpio_io_mode_o,
    output logic  [NO_LSPB_GPIOS*GPIO_WIDTH+1:0] lspb_gpio_io_otype_o,
    output func_t [NO_LSPB_GPIOS*GPIO_WIDTH+1:0] lspb_gpio_func_o,

    output logic [NO_LSPB_SPIS+1:0] lspb_spi_sclk_o,
    output logic [NO_LSPB_SPIS+1:0] lspb_spi_mosi_o,
    input  logic [NO_LSPB_SPIS+1:0] lspb_spi_miso_i,
    output logic [NO_LSPB_SPIS+1:0] lspb_spi_ss_n_o,

    output logic [NO_LSPB_UARTS+1:0] lspb_uart_tx_o,
    input  logic [NO_LSPB_UARTS+1:0] lspb_uart_rx_i
);

    // rst ====================================================================

    logic rst;
    logic [3:0] counter;

    always_ff @(posedge clk_i) begin
        if (rst_i) begin
            counter <= 0;
            rst <= 1;
        end
        else begin
            if (counter == 4'b1111) begin
                rst <= 0;
            end
            else begin
                counter <= counter + 1;
            end
        end
    end

    // seq ====================================================================

    ADAM_SEQ src_seq   ();
    ADAM_SEQ lsdom_seq ();
    // ADAM_SEQ hsdom_seq ();

    assign src_seq.clk = clk_i;
    assign src_seq.rst = rst;

    adam_clk_div #(
        .WIDTH (1)
    ) lsdom_clk_div (
        .slv (src_seq),
        .mst (lsdom_seq)
    );

    // adam_clk_div #(
    //     .WIDTH (1)
    // ) hsdom_clk_div (
    //     .slv (src_seq),
    //     .mst (hsdom_seq)
    // );

    // lspa io ================================================================

    ADAM_IO     lspa_gpio_io   [NO_LSPA_GPIOS*GPIO_WIDTH+1] ();
    logic [1:0] lspa_gpio_func [NO_LSPA_GPIOS*GPIO_WIDTH+1];

    ADAM_IO lspa_spi_sclk [NO_LSPA_SPIS+1] ();
    ADAM_IO lspa_spi_mosi [NO_LSPA_SPIS+1] ();
    ADAM_IO lspa_spi_miso [NO_LSPA_SPIS+1] ();
    ADAM_IO lspa_spi_ss_n [NO_LSPA_SPIS+1] ();

    ADAM_IO lspa_uart_tx [NO_LSPA_UARTS+1] ();
    ADAM_IO lspa_uart_rx [NO_LSPA_UARTS+1] ();

    for (genvar i = 1; i < NO_LSPA_GPIOS*GPIO_WIDTH; i++) begin
        `ADAM_IO_SLV_TIE_OFF(lspa_gpio_io[i]);
    end

    for (genvar i = 0; i < NO_LSPA_SPIS; i++) begin
        assign lspa_spi_sclk[i].i = 0;
        assign lspa_spi_sclk_o[i] = lspa_spi_sclk[i].o;

        assign lspa_spi_mosi[i].i = 0;
        assign lspa_spi_mosi_o[i] = lspa_spi_mosi[i].o;

        assign lspa_spi_miso[i].i = lspa_spi_miso_i;

        assign lspa_spi_ss_n[i].i = 0;
        assign lspa_spi_ss_n_o[i] = lspa_spi_ss_n[i].o;
    end

    for (genvar i = 0; i < NO_LSPA_UARTS; i++) begin
        assign lspa_uart_tx[i].i = 0;
        assign lspa_uart_tx_o    = lspa_uart_tx[i].o;
        assign lspa_uart_rx[i].i = lspa_uart_rx_i;
    end

    for (genvar i = 0; i < NO_LSPA_GPIOS*GPIO_WIDTH; i++) begin
        assign lspa_gpio_io        [i].i = lspa_gpio_io_o[i];
        assign lspa_gpio_io_o      [i]   = lspa_gpio_io  [i].o;
        assign lspa_gpio_io_mode_o [i]   = lspa_gpio_io  [i].mode;
        assign lspa_gpio_io_otype_o[i]   = lspa_gpio_io  [i].otype;
        assign lspa_gpio_func_o    [i]   = lspa_gpio_func[i];
    end

    // lspb io ================================================================

    ADAM_IO     lspb_gpio_io   [NO_LSPB_GPIOS*GPIO_WIDTH+1] ();
    logic [1:0] lspb_gpio_func [NO_LSPB_GPIOS*GPIO_WIDTH+1];

    ADAM_IO lspb_spi_sclk [NO_LSPB_SPIS+1] ();
    ADAM_IO lspb_spi_mosi [NO_LSPB_SPIS+1] ();
    ADAM_IO lspb_spi_miso [NO_LSPB_SPIS+1] ();
    ADAM_IO lspb_spi_ss_n [NO_LSPB_SPIS+1] ();

    ADAM_IO lspb_uart_tx [NO_LSPB_UARTS+1] ();
    ADAM_IO lspb_uart_rx [NO_LSPB_UARTS+1] ();

    for (genvar i = 1; i < NO_LSPB_GPIOS*GPIO_WIDTH; i++) begin
        `ADAM_IO_SLV_TIE_OFF(lspb_gpio_io[i]);
    end

    for (genvar i = 1; i < NO_LSPB_SPIS; i++) begin
        assign lspb_spi_sclk[i].i = 0;
        assign lspb_spi_sclk_o[i] = lspb_spi_sclk[i].o;

        assign lspb_spi_mosi[i].i = 0;
        assign lspb_spi_mosi_o[i] = lspb_spi_mosi[i].o;

        assign lspb_spi_miso[i].i = lspb_spi_miso_i;

        assign lspb_spi_ss_n[i].i = 0;
        assign lspb_spi_ss_n_o[i] = lspb_spi_ss_n[i].o;
    end

    for (genvar i = 0; i < NO_LSPB_UARTS; i++) begin
        assign lspb_uart_tx[i].i = 0;
        assign lspb_uart_tx_o    = lspb_uart_tx[i].o;
        assign lspb_uart_rx[i].i = lspb_uart_rx_i;
    end

    for (genvar i = 0; i < NO_LSPB_GPIOS*GPIO_WIDTH; i++) begin
        assign lspb_gpio_io        [i].i = lspb_gpio_io_o[i];
        assign lspb_gpio_io_o      [i]   = lspb_gpio_io  [i].o;
        assign lspb_gpio_io_mode_o [i]   = lspb_gpio_io  [i].mode;
        assign lspb_gpio_io_otype_o[i]   = lspb_gpio_io  [i].otype;
        assign lspb_gpio_func_o    [i]   = lspb_gpio_func[i];
    end

    // debug ==================================================================

    ADAM_JTAG jtag ();

    assign jtag.trst_n = !rst;

    assign jtag.tck   = jtag_tck_i;
    assign jtag.tms   = jtag_tms_i;
    assign jtag.tdi   = jtag_tdi_i;
    assign jtag_tdo_o = jtag.tdo;

    // pause ext ==============================================================

    ADAM_PAUSE lsdom_pause_ext ();

    `ADAM_PAUSE_MST_TIE_ON(lsdom_pause_ext);

    // adam ===================================================================

    adam #(
        `ADAM_CFG_PARAMS_MAP
    ) adam (
        .lsdom_seq        (lsdom_seq),
        .lsdom_pause_ext  (lsdom_pause_ext),

        .hsdom_seq (lsdom_seq),

        .hsdom_din_i       (hsdom_din_i),
        .hsdom_din_valid_i (hsdom_din_valid_i),
        .hsdom_din_ready_o (hsdom_din_ready_o),

        .hsdom_dout_o       (hsdom_dout_o),
        .hsdom_dout_valid_o (hsdom_dout_valid_o),
        .hsdom_dout_ready_i (hsdom_dout_ready_i),

        .jtag (jtag),

        .lspa_gpio_io   (lspa_gpio_io),
        .lspa_gpio_func (lspa_gpio_func),

        .lspa_spi_sclk (lspa_spi_sclk),
        .lspa_spi_mosi (lspa_spi_mosi),
        .lspa_spi_miso (lspa_spi_miso),
        .lspa_spi_ss_n (lspa_spi_ss_n),

        .lspa_uart_tx (lspa_uart_tx),
        .lspa_uart_rx (lspa_uart_rx),

        .lspb_gpio_io   (lspb_gpio_io),
        .lspb_gpio_func (lspb_gpio_func),

        .lspb_spi_sclk (lspb_spi_sclk),
        .lspb_spi_mosi (lspb_spi_mosi),
        .lspb_spi_miso (lspb_spi_miso),
        .lspb_spi_ss_n (lspb_spi_ss_n),

        .lspb_uart_tx (lspb_uart_tx),
        .lspb_uart_rx (lspb_uart_rx)
    );

endmodule
