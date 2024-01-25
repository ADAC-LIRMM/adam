`include "adam/macros.svh"

module adam_nexys_video (
    input  logic clk,
    input  logic rstn,

    output logic uart_tx,
    input  logic uart_rx,

    input  logic jtag_tck,
    input  logic jtag_tms,
    input  logic jtag_tdi,
    output logic jtag_tdo
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

    logic  lsdom_lpmem_req;
    ADDR_T lsdom_lpmem_addr;
    logic  lsdom_lpmem_we;
    STRB_T lsdom_lpmem_be;
    DATA_T lsdom_lpmem_wdata;
    DATA_T lsdom_lpmem_rdata;

    assign lsdom_lpmem_seq.clk = lsdom_seq.clk;
    assign lsdom_lpmem_seq.rst = lsdom_seq.rst || lsdom_lpmem_rst;

    if (EN_LPMEM) begin
        adam_axil_to_mem #(
            `ADAM_CFG_PARAMS_MAP
        ) adam_axil_to_mem (
            .seq   (lsdom_lpmem_seq),
            .pause (lsdom_lpmem_pause),

            .axil (lsdom_lpmem_axil),

            .mem_req   (lsdom_lpmem_req),
            .mem_addr  (lsdom_lpmem_addr),
            .mem_we    (lsdom_lpmem_we),
            .mem_be    (lsdom_lpmem_be),
            .mem_wdata (lsdom_lpmem_wdata),
            .mem_rdata (lsdom_lpmem_rdata)
        );

        adam_mem #(
            `ADAM_CFG_PARAMS_MAP,

            .SIZE (LPMEM_SIZE)
        ) adam_mem (
            .seq (lsdom_lpmem_seq),

            .req   (lsdom_lpmem_req),
            .addr  (lsdom_lpmem_addr),
            .we    (lsdom_lpmem_we),
            .be    (lsdom_lpmem_be),
            .wdata (lsdom_lpmem_wdata),
            .rdata (lsdom_lpmem_rdata)
        );
    end
    else begin
        // TODO: tie off
    end

    // mem ====================================================================
    
    logic        hsdom_mem_rst   [NO_MEMS+1];
    ADAM_SEQ     hsdom_mem_seq   [NO_MEMS+1] ();
    ADAM_PAUSE   hsdom_mem_pause [NO_MEMS+1] ();
    `ADAM_AXIL_I hsdom_mem_axil  [NO_MEMS+1] ();
    
    logic  hsdom_mem_req   [NO_MEMS+1];
    ADDR_T hsdom_mem_addr  [NO_MEMS+1];
    logic  hsdom_mem_we    [NO_MEMS+1];
    STRB_T hsdom_mem_be    [NO_MEMS+1];
    DATA_T hsdom_mem_wdata [NO_MEMS+1];
    DATA_T hsdom_mem_rdata [NO_MEMS+1];

    for (genvar i = 0; i < NO_MEMS; i++) begin
        assign hsdom_mem_seq[i].clk = lsdom_seq.clk;
        assign hsdom_mem_seq[i].rst = lsdom_seq.rst || hsdom_mem_rst[i];

        adam_axil_to_mem #(
            `ADAM_CFG_PARAMS_MAP
        ) adam_axil_to_mem (
            .seq   (hsdom_mem_seq[i]),
            .pause (hsdom_mem_pause[i]),

            .axil (hsdom_mem_axil[i]),

            .mem_req   (hsdom_mem_req[i]),
            .mem_addr  (hsdom_mem_addr[i]),
            .mem_we    (hsdom_mem_we[i]),
            .mem_be    (hsdom_mem_be[i]),
            .mem_wdata (hsdom_mem_wdata[i]),
            .mem_rdata (hsdom_mem_rdata[i])
        );
    end

    // sensemark #(
    //     `ADAM_CFG_PARAMS_MAP
    // ) sensemark (
    //     .seq (hsdom_mem_seq[0]),

    //     .req   (hsdom_mem_req[0]),
    //     .addr  (hsdom_mem_addr[0]),
    //     .we    (hsdom_mem_we[0]),
    //     .be    (hsdom_mem_be[0]),
    //     .wdata (hsdom_mem_wdata[0]),
    //     .rdata (hsdom_mem_rdata[0])
    // );

    for (genvar i = 0; i < NO_MEMS; i++) begin
        adam_mem #(
            `ADAM_CFG_PARAMS_MAP,

            .SIZE (MEM_SIZE[i])
        ) adam_mem (
            .seq (hsdom_mem_seq[i]),

            .req   (hsdom_mem_req[i]),
            .addr  (hsdom_mem_addr[i]),
            .we    (hsdom_mem_we[i]),
            .be    (hsdom_mem_be[i]),
            .wdata (hsdom_mem_wdata[i]),
            .rdata (hsdom_mem_rdata[i])
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

    assign lspa_uart_tx[0].i = 0;
    assign uart_tx = lspa_uart_tx[0].o;

    assign lspa_uart_rx[0].i = uart_rx;

    for (genvar i = 1; i < NO_LSPA_UARTS; i++) begin
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
    
    assign jtag.tck = jtag_tck;
    assign jtag.tms = jtag_tms;
    assign jtag.tdi = jtag_tdi;
    assign jtag_tdo = jtag.tdo;

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