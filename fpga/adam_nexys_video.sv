`include "adam/macros.svh"

module adam_nexys_video (
    input  logic clk,
    input  logic rstn,

    input  logic tck,
    input  logic tms,
    input  logic tdi,
    output logic tdo
);
    
    `ADAM_CFG_LOCALPARAMS;
    
    localparam integer LPMEM_SIZE = 1024;

    localparam integer MEM_SIZE [NO_MEMS+1] = 
        '{32768, 32768, 32768, 0};

    // rst ====================================================================

    logic rst;
    logic [3:0] counter;

    always_ff @(posedge clk) begin
        if (!rstn) begin
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

    assign src_seq.clk = clk;
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

    // lpmem ==================================================================

    logic        lsdom_lpmem_rst;
    ADAM_SEQ     lsdom_lpmem_seq ();
    ADAM_PAUSE   lsdom_lpmem_pause ();
    `ADAM_AXIL_I lsdom_lpmem_axil ();

    assign lsdom_lpmem_seq.clk = lsdom_seq.clk;
    assign lsdom_lpmem_seq.rst = lsdom_seq.rst || lsdom_lpmem_rst;

    adam_axil_ram #(
        `ADAM_CFG_PARAMS_MAP,

        .SIZE (LPMEM_SIZE)
    ) adam_axil_ram (
        .seq   (lsdom_lpmem_seq),
        .pause (lsdom_lpmem_pause),

        .slv (lsdom_lpmem_axil)
    );

    // mem ====================================================================

    logic        hsdom_mem_rst   [NO_MEMS+1];
    ADAM_SEQ     hsdom_mem_seq   [NO_MEMS+1] ();
    ADAM_PAUSE   hsdom_mem_pause [NO_MEMS+1] ();
    `ADAM_AXIL_I hsdom_mem_axil  [NO_MEMS+1] ();

    for (genvar i = 0; i < NO_MEMS; i++) begin
        assign hsdom_mem_seq[i].clk = lsdom_seq.clk;
        assign hsdom_mem_seq[i].rst = lsdom_seq.rst || hsdom_mem_rst[i];
    end

    for (genvar i = 0; i < NO_MEMS; i++) begin
        adam_axil_ram #(
            `ADAM_CFG_PARAMS_MAP,

            .SIZE (MEM_SIZE[i])
        ) adam_axil_ram (
            .seq   (hsdom_mem_seq[i]),
            .pause (hsdom_mem_pause[i]),

            .slv (hsdom_mem_axil[i])
        );
    end

    // lspa io ================================================================

    ADAM_IO     lspa_gpio_io   [NO_LSPA_GPIOS*GPIO_WIDTH+1] ();
    logic [1:0] lspa_gpio_func [NO_LSPA_GPIOS*GPIO_WIDTH+1];

    ADAM_IO lspa_spi_sclk [NO_LSPA_SPIS+1] ();
    ADAM_IO lspa_spi_mosi [NO_LSPA_SPIS+1] ();
    ADAM_IO lspa_spi_miso [NO_LSPA_SPIS+1] ();
    ADAM_IO lspa_spi_ss_n [NO_LSPA_SPIS+1] ();

    ADAM_IO lspa_uart_tx [NO_LSPA_UARTS+1] ();
    ADAM_IO lspa_uart_rx [NO_LSPA_UARTS+1] ();

    for (genvar i = 0; i < NO_LSPA_GPIOS; i++) begin
        `ADAM_IO_SLV_TIE_OFF(lspa_gpio_io[i]);
    end
    for (genvar i = 0; i < NO_LSPA_SPIS; i++) begin
        `ADAM_IO_SLV_TIE_OFF(lspa_spi_sclk[i]);
        `ADAM_IO_SLV_TIE_OFF(lspa_spi_mosi[i]);
        `ADAM_IO_SLV_TIE_OFF(lspa_spi_miso[i]);
        `ADAM_IO_SLV_TIE_OFF(lspa_spi_ss_n[i]);
    end
    for (genvar i = 0; i < NO_LSPA_UARTS; i++) begin
        `ADAM_IO_SLV_TIE_OFF(lspa_uart_tx[i]);
        `ADAM_IO_SLV_TIE_OFF(lspa_uart_rx[i]);
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

    for (genvar i = 0; i < NO_LSPB_GPIOS; i++) begin
        `ADAM_IO_SLV_TIE_OFF(lspb_gpio_io[i]);
    end
    for (genvar i = 0; i < NO_LSPB_SPIS; i++) begin
        `ADAM_IO_SLV_TIE_OFF(lspb_spi_sclk[i]);
        `ADAM_IO_SLV_TIE_OFF(lspb_spi_mosi[i]);
        `ADAM_IO_SLV_TIE_OFF(lspb_spi_miso[i]);
        `ADAM_IO_SLV_TIE_OFF(lspb_spi_ss_n[i]);
    end
    for (genvar i = 0; i < NO_LSPB_UARTS; i++) begin
        `ADAM_IO_SLV_TIE_OFF(lspb_uart_tx[i]);
        `ADAM_IO_SLV_TIE_OFF(lspb_uart_rx[i]);
    end

    // debug ==================================================================

    ADAM_JTAG jtag ();

    assign jtag.trst_n = !rst;
    
    assign jtag.tck = tck;
    assign jtag.tms = tms;
    assign jtag.tdi = tdi;
    assign tdo = jtag.tdo;

    // pause ext ==============================================================

    ADAM_PAUSE lsdom_pause_ext ();

    `ADAM_PAUSE_MST_TIE_ON(lsdom_pause_ext);

    // adam ===================================================================

    adam #(
        `ADAM_CFG_PARAMS_MAP
    ) adam (
        .lsdom_seq (lsdom_seq),

        .lsdom_pause_ext  (lsdom_pause_ext),

        .lsdom_lpmem_rst   (lsdom_lpmem_rst),
        .lsdom_lpmem_pause (lsdom_lpmem_pause),
        .lsdom_lpmem_axil  (lsdom_lpmem_axil),

        .hsdom_seq (lsdom_seq),

        .hsdom_mem_rst   (hsdom_mem_rst),
        .hsdom_mem_pause (hsdom_mem_pause),
        .hsdom_mem_axil  (hsdom_mem_axil),
        
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