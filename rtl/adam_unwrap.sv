`include "adam/macros.svh"
`include "apb/assign.svh"
`include "axi/assign.svh"

module adam_unwrap #(
    `ADAM_CFG_PARAMS
) (
    // lsdom ===============================
    // Slave Seq Interface
    input   logic           lsdom_seq_clk,
    input   logic           lsdom_seq_rst,
    // Pause Slave Interface
    // input   logic           lsdom_pause_ext_req,
    // output  logic           lsdom_pause_ext_ack,

    // Pause Master Interface
    output  logic           lsdom_lpmem_pause_req,
    input   logic           lsdom_lpmem_pause_ack,

    output logic            lsdom_lpmem_req,
    output ADDR_T           lsdom_lpmem_addr,
    output logic            lsdom_lpmem_we,
    output STRB_T           lsdom_lpmem_be,
    output DATA_T           lsdom_lpmem_wdata,
    input  DATA_T           lsdom_lpmem_rdata,

    // hsdom ===============================
    // Slave Seq Interface
    input   logic           hsdom_seq_clk,
    input   logic           hsdom_seq_rst,

    // HSDOM Memory Interface
    output logic            hsdom_mem_req   [NO_MEMS+1],
    output ADDR_T           hsdom_mem_addr  [NO_MEMS+1],
    output logic            hsdom_mem_we    [NO_MEMS+1],
    output STRB_T           hsdom_mem_be    [NO_MEMS+1],
    output DATA_T           hsdom_mem_wdata [NO_MEMS+1],
    input  DATA_T           hsdom_mem_rdata [NO_MEMS+1],

    // jtag ================================
    input  logic            jtag_trst_n,
    input  logic            jtag_tck,
    input  logic            jtag_tms,
    input  logic            jtag_tdi,
    output logic            jtag_tdo,
    
    // async - lspa =========================
    // GPIO Interface
    input   logic           lspa_gpio_io_i      [NO_LSPA_GPIOS*GPIO_WIDTH+1],
    output  logic           lspa_gpio_io_o      [NO_LSPA_GPIOS*GPIO_WIDTH+1],
    output  logic           lspa_gpio_io_mode   [NO_LSPA_GPIOS*GPIO_WIDTH+1],
    output  logic           lspa_gpio_io_otype  [NO_LSPA_GPIOS*GPIO_WIDTH+1],
    output  logic   [1:0]   lspa_gpio_func      [NO_LSPA_GPIOS*GPIO_WIDTH+1],
    // SPI Interface
        // SCLK
    input   logic           lspa_spi_sclk_i      [NO_LSPA_SPIS+1],
    output  logic           lspa_spi_sclk_o      [NO_LSPA_SPIS+1],
    output  logic           lspa_spi_sclk_mode   [NO_LSPA_SPIS+1],
    output  logic           lspa_spi_sclk_otype  [NO_LSPA_SPIS+1],
        // MOSI
    input   logic           lspa_spi_mosi_i      [NO_LSPA_SPIS+1],
    output  logic           lspa_spi_mosi_o      [NO_LSPA_SPIS+1],
    output  logic           lspa_spi_mosi_mode   [NO_LSPA_SPIS+1],
    output  logic           lspa_spi_mosi_otype   [NO_LSPA_SPIS+1],
        // MISO
    input   logic           lspa_spi_miso_i      [NO_LSPA_SPIS+1],
    output  logic           lspa_spi_miso_o      [NO_LSPA_SPIS+1],
    output  logic           lspa_spi_miso_mode   [NO_LSPA_SPIS+1],
    output  logic           lspa_spi_miso_otype   [NO_LSPA_SPIS+1],
        // SS_n
    input   logic           lspa_spi_ss_n_i      [NO_LSPA_SPIS+1],
    output  logic           lspa_spi_ss_n_o      [NO_LSPA_SPIS+1],
    output  logic           lspa_spi_ss_n_mode   [NO_LSPA_SPIS+1],
    output  logic           lspa_spi_ss_n_otype   [NO_LSPA_SPIS+1],
    // UART Interface
        // TX
    input   logic           lspa_uart_tx_i       [NO_LSPA_UARTS+1],
    output  logic           lspa_uart_tx_o       [NO_LSPA_UARTS+1],
    output  logic           lspa_uart_tx_mode    [NO_LSPA_UARTS+1],
    output  logic           lspa_uart_tx_otype    [NO_LSPA_UARTS+1],
        // RX
    input   logic           lspa_uart_rx_i       [NO_LSPA_UARTS+1],
    output  logic           lspa_uart_rx_o       [NO_LSPA_UARTS+1],
    output  logic           lspa_uart_rx_mode    [NO_LSPA_UARTS+1],
    output  logic           lspa_uart_rx_otype    [NO_LSPA_UARTS+1],

    // async - lspb =========================
    // GPIO Interface
    input   logic           lspb_gpio_io_i      [NO_LSPB_GPIOS*GPIO_WIDTH+1],
    output  logic           lspb_gpio_io_o      [NO_LSPB_GPIOS*GPIO_WIDTH+1],
    output  logic           lspb_gpio_io_mode   [NO_LSPB_GPIOS*GPIO_WIDTH+1],
    output  logic           lspb_gpio_io_otype   [NO_LSPB_GPIOS*GPIO_WIDTH+1],
    output  logic   [1:0]   lspb_gpio_func      [NO_LSPB_GPIOS*GPIO_WIDTH+1],
    // SPI Interface
        // SCLK
    input   logic           lspb_spi_sclk_i      [NO_LSPB_SPIS+1],
    output  logic           lspb_spi_sclk_o      [NO_LSPB_SPIS+1],
    output  logic           lspb_spi_sclk_mode   [NO_LSPB_SPIS+1],
    output  logic           lspb_spi_sclk_otype   [NO_LSPB_SPIS+1],
        // MOSI
    input   logic           lspb_spi_mosi_i      [NO_LSPB_SPIS+1],
    output  logic           lspb_spi_mosi_o      [NO_LSPB_SPIS+1],
    output  logic           lspb_spi_mosi_mode   [NO_LSPB_SPIS+1],
    output  logic           lspb_spi_mosi_otype   [NO_LSPB_SPIS+1],
        // MISO
    input   logic           lspb_spi_miso_i      [NO_LSPB_SPIS+1],
    output  logic           lspb_spi_miso_o      [NO_LSPB_SPIS+1],
    output  logic           lspb_spi_miso_mode   [NO_LSPB_SPIS+1],
    output  logic           lspb_spi_miso_otype   [NO_LSPB_SPIS+1],
        // SS_n
    input   logic           lspb_spi_ss_n_i      [NO_LSPB_SPIS+1],
    output  logic           lspb_spi_ss_n_o      [NO_LSPB_SPIS+1],
    output  logic           lspb_spi_ss_n_mode   [NO_LSPB_SPIS+1],
    output  logic           lspb_spi_ss_n_otype   [NO_LSPB_SPIS+1],
    // UART Interface
        // TX
    input   logic           lspb_uart_tx_i       [NO_LSPB_UARTS+1],
    output  logic           lspb_uart_tx_o       [NO_LSPB_UARTS+1],
    output  logic           lspb_uart_tx_mode    [NO_LSPB_UARTS+1],
    output  logic           lspb_uart_tx_otype    [NO_LSPB_UARTS+1],
        // RX
    input   logic           lspb_uart_rx_i       [NO_LSPB_UARTS+1],
    output  logic           lspb_uart_rx_o       [NO_LSPB_UARTS+1],
    output  logic           lspb_uart_rx_mode    [NO_LSPB_UARTS+1],
    output  logic           lspb_uart_rx_otype    [NO_LSPB_UARTS+1]
);

    // Signals =============================
    // lsdom ===============================
    ADAM_SEQ    lsdom_seq ();
    ADAM_PAUSE  lsdom_pause_ext ();
    ADAM_PAUSE  lsdom_lpmem_pause ();
    `ADAM_AXIL_I  lsdom_lpmem_axil ();
    // Slave Seq Interface
    assign lsdom_seq.clk = lsdom_seq_clk;
    assign lsdom_seq.rst = lsdom_seq_rst;
    // Pause Slave Interface
    `ADAM_PAUSE_MST_TIE_ON(lsdom_pause_ext);
    // Pause Master Interface
    assign lsdom_lpmem_pause_req        =   lsdom_lpmem_pause.req;
    assign lsdom_lpmem_pause.ack        =   lsdom_lpmem_pause_ack;

    // hsdom ===============================
    // ADAM_SEQ    hsdom_seq ();
    ADAM_PAUSE  hsdom_mem_pause [NO_MEMS+1] ();
    `ADAM_AXIL_I  hsdom_mem_axil [NO_MEMS+1] ();
    
    // jtag ================================
    ADAM_JTAG   jtag ();
    assign jtag.trst_n  =   jtag_trst_n;
    assign jtag.tck     =   jtag_tck;
    assign jtag.tms     =   jtag_tms;
    assign jtag.tdi     =   jtag_tdi;
    assign jtag_tdo     =   jtag.tdo;

    // async - lspa =========================
    ADAM_IO   lspa_gpio [NO_LSPA_GPIOS*GPIO_WIDTH+1] ();
    ADAM_IO   lspa_spi_sclk  [NO_LSPA_SPIS+1] ();
    ADAM_IO   lspa_spi_mosi  [NO_LSPA_SPIS+1] ();
    ADAM_IO   lspa_spi_miso  [NO_LSPA_SPIS+1] ();
    ADAM_IO   lspa_spi_ss_n  [NO_LSPA_SPIS+1] ();
    ADAM_IO   lspa_uart_tx   [NO_LSPA_UARTS+1] ();
    ADAM_IO   lspa_uart_rx   [NO_LSPA_UARTS+1] ();
    
    genvar i;
    // GPIO Interface
    generate
    for (i=0; i<NO_LSPA_GPIOS*GPIO_WIDTH+1; i++) begin
        assign lspa_gpio[i].i      =   lspa_gpio_io_i[i];
        assign lspa_gpio_io_o[i]      =   lspa_gpio[i].o;
        assign lspa_gpio_io_mode[i]   =   lspa_gpio[i].mode;
        assign lspa_gpio_io_otype[i]   =   lspa_gpio[i].otype;
    end    
    endgenerate
    
    // SPI Interface
    generate
        for (i=0; i<NO_LSPA_SPIS+1; i++) begin
            assign lspa_spi_sclk[i].i      =   lspa_spi_sclk_i[i];
            assign lspa_spi_sclk_o[i]      =   lspa_spi_sclk[i].o;
            assign lspa_spi_sclk_mode[i]   =   lspa_spi_sclk[i].mode;
            assign lspa_spi_sclk_otype[i]   =   lspa_spi_sclk[i].otype;
            assign lspa_spi_mosi[i].i      =   lspa_spi_mosi_i[i];
            assign lspa_spi_mosi_o[i]      =   lspa_spi_mosi[i].o;
            assign lspa_spi_mosi_mode[i]   =   lspa_spi_mosi[i].mode;
            assign lspa_spi_mosi_otype[i]   =   lspa_spi_mosi[i].otype;
            assign lspa_spi_miso[i].i      =   lspa_spi_miso_i[i];
            assign lspa_spi_miso_o[i]      =   lspa_spi_miso[i].o;
            assign lspa_spi_miso_mode[i]   =   lspa_spi_miso[i].mode;
            assign lspa_spi_miso_otype[i]   =   lspa_spi_miso[i].otype;
            assign lspa_spi_ss_n[i].i      =   lspa_spi_ss_n_i[i];
            assign lspa_spi_ss_n_o[i]      =   lspa_spi_ss_n[i].o;
            assign lspa_spi_ss_n_mode[i]   =   lspa_spi_ss_n[i].mode;
            assign lspa_spi_ss_n_otype[i]   =   lspa_spi_ss_n[i].otype;
        end
    endgenerate
    
    // UART Interface
    generate
    for (i=0; i<NO_LSPA_UARTS+1; i++) begin
        assign lspa_uart_tx[i].i       =   lspa_uart_tx_i[i];
        assign lspa_uart_tx_o[i]       =   lspa_uart_tx[i].o;
        assign lspa_uart_tx_mode[i]    =   lspa_uart_tx[i].mode;
        assign lspa_uart_tx_otype[i]    =   lspa_uart_tx[i].otype;
        assign lspa_uart_rx[i].i       =   lspa_uart_rx_i[i];
        assign lspa_uart_rx_o[i]       =   lspa_uart_rx[i].o;
        assign lspa_uart_rx_mode[i]    =   lspa_uart_rx[i].mode;
        assign lspa_uart_rx_otype[i]    =   lspa_uart_rx[i].otype;
    end
    endgenerate
    
    // async - lspb =========================
    ADAM_IO   lspb_gpio [NO_LSPB_GPIOS*GPIO_WIDTH+1] ();
    ADAM_IO   lspb_spi_sclk  [NO_LSPB_SPIS+1] ();
    ADAM_IO   lspb_spi_mosi  [NO_LSPB_SPIS+1] ();
    ADAM_IO   lspb_spi_miso  [NO_LSPB_SPIS+1] ();
    ADAM_IO   lspb_spi_ss_n  [NO_LSPB_SPIS+1] ();

    ADAM_IO   lspb_uart_tx [NO_LSPB_UARTS+1] ();
    ADAM_IO   lspb_uart_rx [NO_LSPB_UARTS+1] ();
    // GPIO Interface
    generate
    for (i=0; i<NO_LSPB_GPIOS*GPIO_WIDTH+1; i++) begin
        assign lspb_gpio[i].i      =   lspb_gpio_io_i[i];
        assign lspb_gpio_io_o[i]      =   lspb_gpio[i].o;
        assign lspb_gpio_io_mode[i]   =   lspb_gpio[i].mode;
        assign lspb_gpio_io_otype[i]   =   lspb_gpio[i].otype;
    end    
    endgenerate
    
    // SPI Interface
    generate
    for (i=0; i<NO_LSPB_SPIS+1; i++) begin
        assign lspb_spi_sclk[i].i      =   lspb_spi_sclk_i[i];
        assign lspb_spi_sclk_o[i]      =   lspb_spi_sclk[i].o;
        assign lspb_spi_sclk_mode[i]   =   lspb_spi_sclk[i].mode;
        assign lspb_spi_sclk_otype[i]   =   lspb_spi_sclk[i].otype;
        assign lspb_spi_mosi[i].i      =   lspb_spi_mosi_i[i];
        assign lspb_spi_mosi_o[i]      =   lspb_spi_mosi[i].o;
        assign lspb_spi_mosi_mode[i]   =   lspb_spi_mosi[i].mode;
        assign lspb_spi_mosi_otype[i]   =   lspb_spi_mosi[i].otype;
        assign lspb_spi_miso[i].i      =   lspb_spi_miso_i[i];
        assign lspb_spi_miso_o[i]      =   lspb_spi_miso[i].o;
        assign lspb_spi_miso_mode[i]   =   lspb_spi_miso[i].mode;
        assign lspb_spi_miso_otype[i]   =   lspb_spi_miso[i].otype;
        assign lspb_spi_ss_n[i].i      =   lspb_spi_ss_n_i[i];
        assign lspb_spi_ss_n_o[i]      =   lspb_spi_ss_n[i].o;
        assign lspb_spi_ss_n_mode[i]   =   lspb_spi_ss_n[i].mode;
        assign lspb_spi_ss_n_otype[i]   =   lspb_spi_ss_n[i].otype;
    end
    endgenerate

    // UART Interface
    generate
    for (i=0; i<NO_LSPB_UARTS+1; i++) begin
        assign lspb_uart_tx[i].i       =   lspb_uart_tx_i[i];
        assign lspb_uart_tx_o[i]       =   lspb_uart_tx[i].o;
        assign lspb_uart_tx_mode[i]    =   lspb_uart_tx[i].mode;
        assign lspb_uart_tx_otype[i]    =   lspb_uart_tx[i].otype;
        assign lspb_uart_rx[i].i       =   lspb_uart_rx_i[i];
        assign lspb_uart_rx_o[i]       =   lspb_uart_rx[i].o;
        assign lspb_uart_rx_mode[i]    =   lspb_uart_rx[i].mode;
        assign lspb_uart_rx_otype[i]    =   lspb_uart_rx[i].otype;
    end
    endgenerate
    logic lsdom_lpmem_rst;
    ADAM_SEQ lsdom_lpmem_seq();

    assign lsdom_lpmem_seq.clk = lsdom_seq_clk;
    assign lsdom_lpmem_seq.rst = lsdom_seq.rst || lsdom_lpmem_rst;

    adam_axil_to_mem #(
            `ADAM_CFG_PARAMS_MAP
        )
         axil_to_lpmem (
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
    
    logic        hsdom_mem_rst   [NO_MEMS+1];
    ADAM_SEQ     hsdom_mem_seq   [NO_MEMS+1] ();

    // TIE OFF
    // assign hsdom_mem_rst    [NO_MEMS] = 'b1;
    // `ADAM_SEQ_TIE_OFF(hsdom_mem_seq[NO_MEMS]);
    // `ADAM_PAUSE_SLV_TIE_OFF(hsdom_mem_pause[NO_MEMS]);
    // `ADAM_AXIL_SLV_TIE_OFF(hsdom_mem_axil[NO_MEMS]);
    // assign hsdom_mem_req   [NO_MEMS] = 1'b0;
    // assign hsdom_mem_addr  [NO_MEMS] = 'b0;
    // assign hsdom_mem_we    [NO_MEMS] = 1'b0;
    // assign hsdom_mem_be    [NO_MEMS] = 'b0;
    // assign hsdom_mem_wdata [NO_MEMS] = 'b0;
    // assign hsdom_mem_rdata [NO_MEMS] = 'b0;

    generate
    for (i = 0; i<NO_MEMS+1; i++) begin
        assign hsdom_mem_seq[i].clk = lsdom_seq.clk;
        assign hsdom_mem_seq[i].rst = lsdom_seq.rst || hsdom_mem_rst[i];
        adam_axil_to_mem #(
            `ADAM_CFG_PARAMS_MAP
        )
         axil_to_hsmem (
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
    endgenerate
    
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

        .lspa_gpio_io   (lspa_gpio),
        .lspa_gpio_func (lspa_gpio_func),

        .lspa_spi_sclk (lspa_spi_sclk),
        .lspa_spi_mosi (lspa_spi_mosi),
        .lspa_spi_miso (lspa_spi_miso),
        .lspa_spi_ss_n (lspa_spi_ss_n),

        .lspa_uart_tx (lspa_uart_tx),
        .lspa_uart_rx (lspa_uart_rx),
        
        .lspb_gpio_io   (lspb_gpio),
        .lspb_gpio_func (lspb_gpio_func),

        .lspb_spi_sclk (lspb_spi_sclk),
        .lspb_spi_mosi (lspb_spi_mosi),
        .lspb_spi_miso (lspb_spi_miso),
        .lspb_spi_ss_n (lspb_spi_ss_n),

        .lspb_uart_tx (lspb_uart_tx),
        .lspb_uart_rx (lspb_uart_rx)
    );
    
endmodule


// `include "adam/macros.svh"
// `include "apb/assign.svh"
// `include "axi/assign.svh"

// module adam_unwrap #(
//     `ADAM_CFG_PARAMS
// ) (
//     // lsdom ===============================
//     // Slave Seq Interface
//     input   logic           lsdom_seq_clk,
//     input   logic           lsdom_seq_rst,
//     // Pause Slave Interface
//     input   logic           lsdom_pause_ext_req,
//     output  logic           lsdom_pause_ext_ack,

//     output  logic           lsdom_lpmem_rst,
//     // Pause Master Interface
//     output  logic           lsdom_lpmem_pause_req,
//     input   logic           lsdom_lpmem_pause_ack,
//     // LPMEM AXILite Master Interface
//     // AW channel
//     output logic[31:0]      lsdom_lpmem_axil_aw_addr,
//     output axi_pkg::prot_t  lsdom_lpmem_axil_aw_prot,
//     output logic            lsdom_lpmem_axil_aw_valid,
//     input  logic            lsdom_lpmem_axil_aw_ready,
//     // W channel
//     output logic[31:0]      lsdom_lpmem_axil_w_data,
//     output logic[3:0]       lsdom_lpmem_axil_w_strb,
//     output logic            lsdom_lpmem_axil_w_valid,
//     input  logic            lsdom_lpmem_axil_w_ready,
//     // B channel
//     input  axi_pkg::resp_t  lsdom_lpmem_axil_b_resp,
//     input  logic            lsdom_lpmem_axil_b_valid,
//     output logic            lsdom_lpmem_axil_b_ready,
//     // AR channel
//     output logic[31:0]           lsdom_lpmem_axil_ar_addr,
//     output axi_pkg::prot_t  lsdom_lpmem_axil_ar_prot,
//     output logic            lsdom_lpmem_axil_ar_valid,
//     input  logic            lsdom_lpmem_axil_ar_ready,
//     // R channel
//     input  logic[31:0]           lsdom_lpmem_axil_r_data,
//     input  axi_pkg::resp_t  lsdom_lpmem_axil_r_resp,
//     input  logic            lsdom_lpmem_axil_r_valid,
//     output logic            lsdom_lpmem_axil_r_ready,

//     // hsdom ===============================
//     // Slave Seq Interface
//     input   logic           hsdom_seq_clk,
//     input   logic           hsdom_seq_rst,

//     output  logic           hsdom_mem_rst         [NO_MEMS+1],
//     // Memory pause interface
//     output  logic           hsdom_mem_pause_req   [NO_MEMS+1],
//     input   logic           hsdom_mem_pause_ack   [NO_MEMS+1],
//     // HSDOM MEM AXILite Master Interface
//     // AW channel
//     output logic[31:0]           hsdom_mem_axil_aw_addr [NO_MEMS+1],
//     output axi_pkg::prot_t  hsdom_mem_axil_aw_prot [NO_MEMS+1],
//     output logic            hsdom_mem_axil_aw_valid [NO_MEMS+1],
//     input  logic            hsdom_mem_axil_aw_ready [NO_MEMS+1],
//     // W channel
//     output logic[31:0]           hsdom_mem_axil_w_data [NO_MEMS+1],
//     output logic[3:0]           hsdom_mem_axil_w_strb [NO_MEMS+1],
//     output logic            hsdom_mem_axil_w_valid [NO_MEMS+1],
//     input  logic            hsdom_mem_axil_w_ready [NO_MEMS+1],
//     // B channel
//     input  axi_pkg::resp_t  hsdom_mem_axil_b_resp [NO_MEMS+1],
//     input  logic            hsdom_mem_axil_b_valid [NO_MEMS+1],
//     output logic            hsdom_mem_axil_b_ready [NO_MEMS+1],
//     // AR channel
//     output logic[31:0]           hsdom_mem_axil_ar_addr [NO_MEMS+1],
//     output axi_pkg::prot_t  hsdom_mem_axil_ar_prot [NO_MEMS+1],
//     output logic            hsdom_mem_axil_ar_valid [NO_MEMS+1],
//     input  logic            hsdom_mem_axil_ar_ready [NO_MEMS+1],
//     // R channel
//     input  logic[31:0]           hsdom_mem_axil_r_data [NO_MEMS+1],
//     input  axi_pkg::resp_t  hsdom_mem_axil_r_resp [NO_MEMS+1],
//     input  logic            hsdom_mem_axil_r_valid [NO_MEMS+1],
//     output logic            hsdom_mem_axil_r_ready [NO_MEMS+1],

//     // jtag ================================
//     input  logic            jtag_trst_n,
//     input  logic            jtag_tck,
//     input  logic            jtag_tms,
//     input  logic            jtag_tdi,
//     output logic            jtag_tdo,
    
//     // async - lspa =========================
//     // GPIO Interface
//     input   logic           lspa_gpio_io_i      [NO_LSPA_GPIOS*GPIO_WIDTH+1],
//     output  logic           lspa_gpio_io_o      [NO_LSPA_GPIOS*GPIO_WIDTH+1],
//     output  logic           lspa_gpio_io_mode   [NO_LSPA_GPIOS*GPIO_WIDTH+1],
//     output  logic           lspa_gpio_io_otype  [NO_LSPA_GPIOS*GPIO_WIDTH+1],
//     output  logic   [1:0]   lspa_gpio_func      [NO_LSPA_GPIOS*GPIO_WIDTH+1],
//     // SPI Interface
//         // SCLK
//     input   logic           lspa_spi_sclk_i      [NO_LSPA_SPIS+1],
//     output  logic           lspa_spi_sclk_o      [NO_LSPA_SPIS+1],
//     output  logic           lspa_spi_sclk_mode   [NO_LSPA_SPIS+1],
//     output  logic           lspa_spi_sclk_otype  [NO_LSPA_SPIS+1],
//         // MOSI
//     input   logic           lspa_spi_mosi_i      [NO_LSPA_SPIS+1],
//     output  logic           lspa_spi_mosi_o      [NO_LSPA_SPIS+1],
//     output  logic           lspa_spi_mosi_mode   [NO_LSPA_SPIS+1],
//     output  logic           lspa_spi_mosi_otype   [NO_LSPA_SPIS+1],
//         // MISO
//     input   logic           lspa_spi_miso_i      [NO_LSPA_SPIS+1],
//     output  logic           lspa_spi_miso_o      [NO_LSPA_SPIS+1],
//     output  logic           lspa_spi_miso_mode   [NO_LSPA_SPIS+1],
//     output  logic            lspa_spi_miso_otype   [NO_LSPA_SPIS+1],
//         // SS_n
//     input   logic           lspa_spi_ss_n_i      [NO_LSPA_SPIS+1],
//     output  logic           lspa_spi_ss_n_o      [NO_LSPA_SPIS+1],
//     output  logic           lspa_spi_ss_n_mode   [NO_LSPA_SPIS+1],
//     output  logic           lspa_spi_ss_n_otype   [NO_LSPA_SPIS+1],
//     // UART Interface
//         // TX
//     input   logic           lspa_uart_tx_i       [NO_LSPA_UARTS+1],
//     output  logic           lspa_uart_tx_o       [NO_LSPA_UARTS+1],
//     output  logic           lspa_uart_tx_mode    [NO_LSPA_UARTS+1],
//     output  logic           lspa_uart_tx_otype    [NO_LSPA_UARTS+1],
//         // RX
//     input   logic           lspa_uart_rx_i       [NO_LSPA_UARTS+1],
//     output  logic           lspa_uart_rx_o       [NO_LSPA_UARTS+1],
//     output  logic           lspa_uart_rx_mode    [NO_LSPA_UARTS+1],
//     output  logic           lspa_uart_rx_otype    [NO_LSPA_UARTS+1],

//     // async - lspb =========================
//     // GPIO Interface
//     input   logic           lspb_gpio_io_i      [NO_LSPB_GPIOS*GPIO_WIDTH+1],
//     output  logic           lspb_gpio_io_o      [NO_LSPB_GPIOS*GPIO_WIDTH+1],
//     output  logic           lspb_gpio_io_mode   [NO_LSPB_GPIOS*GPIO_WIDTH+1],
//     output  logic           lspb_gpio_io_otype   [NO_LSPB_GPIOS*GPIO_WIDTH+1],
//     output  logic   [1:0]   lspb_gpio_func      [NO_LSPB_GPIOS*GPIO_WIDTH+1],
//     // SPI Interface
//         // SCLK
//     input   logic           lspb_spi_sclk_i      [NO_LSPB_SPIS+1],
//     output  logic           lspb_spi_sclk_o      [NO_LSPB_SPIS+1],
//     output  logic           lspb_spi_sclk_mode   [NO_LSPB_SPIS+1],
//     output  logic           lspb_spi_sclk_otype   [NO_LSPB_SPIS+1],
//         // MOSI
//     input   logic           lspb_spi_mosi_i      [NO_LSPB_SPIS+1],
//     output  logic           lspb_spi_mosi_o      [NO_LSPB_SPIS+1],
//     output  logic           lspb_spi_mosi_mode   [NO_LSPB_SPIS+1],
//     output  logic           lspb_spi_mosi_otype   [NO_LSPB_SPIS+1],
//         // MISO
//     input   logic           lspb_spi_miso_i      [NO_LSPB_SPIS+1],
//     output  logic           lspb_spi_miso_o      [NO_LSPB_SPIS+1],
//     output  logic           lspb_spi_miso_mode   [NO_LSPB_SPIS+1],
//     output  logic           lspb_spi_miso_otype   [NO_LSPB_SPIS+1],
//         // SS_n
//     input   logic           lspb_spi_ss_n_i      [NO_LSPB_SPIS+1],
//     output  logic           lspb_spi_ss_n_o      [NO_LSPB_SPIS+1],
//     output  logic           lspb_spi_ss_n_mode   [NO_LSPB_SPIS+1],
//     output  logic           lspb_spi_ss_n_otype   [NO_LSPB_SPIS+1],
//     // UART Interface
//         // TX
//     input   logic           lspb_uart_tx_i       [NO_LSPB_UARTS+1],
//     output  logic           lspb_uart_tx_o       [NO_LSPB_UARTS+1],
//     output  logic           lspb_uart_tx_mode    [NO_LSPB_UARTS+1],
//     output  logic           lspb_uart_tx_otype    [NO_LSPB_UARTS+1],
//         // RX
//     input   logic           lspb_uart_rx_i       [NO_LSPB_UARTS+1],
//     output  logic           lspb_uart_rx_o       [NO_LSPB_UARTS+1],
//     output  logic           lspb_uart_rx_mode    [NO_LSPB_UARTS+1],
//     output  logic           lspb_uart_rx_otype    [NO_LSPB_UARTS+1]
// );


//     // Signals =============================
//     // lsdom ===============================
//     ADAM_SEQ    lsdom_seq ();
//     ADAM_PAUSE  lsdom_pause_ext ();
//     ADAM_PAUSE  lsdom_lpmem_pause ();
//     `ADAM_AXIL_I  lsdom_lpmem_axil ();
//     // Slave Seq Interface
//     assign lsdom_seq.clk = lsdom_seq_clk;
//     assign lsdom_seq.rst = lsdom_seq_rst;
//     // Pause Slave Interface
//     assign lsdom_pause_ext.req          =   lsdom_pause_ext_req;
//     assign lsdom_pause_ext_ack          = lsdom_pause_ext.ack;
//     // Pause Master Interface
//     assign lsdom_lpmem_pause_req        =   lsdom_lpmem_pause.req;
//     assign lsdom_lpmem_pause.ack        =   lsdom_lpmem_pause_ack;
//     // LPMEM AXILite Master Interface
//     // AW channel
//     assign lsdom_lpmem_axil_aw_addr     =   lsdom_lpmem_axil.aw_addr;
//     assign lsdom_lpmem_axil_aw_prot     =   lsdom_lpmem_axil.aw_prot;
//     assign lsdom_lpmem_axil_aw_valid    =   lsdom_lpmem_axil.aw_valid;
//     assign lsdom_lpmem_axil.aw_ready    =   lsdom_lpmem_axil_aw_ready;
//     // W channel
//     assign lsdom_lpmem_axil_w_data      =   lsdom_lpmem_axil.w_data;
//     assign lsdom_lpmem_axil_w_strb      =   lsdom_lpmem_axil.w_strb;
//     assign lsdom_lpmem_axil_w_valid     =   lsdom_lpmem_axil.w_valid;
//     assign lsdom_lpmem_axil.w_ready     =   lsdom_lpmem_axil_w_ready;
//     // B channel
//     assign lsdom_lpmem_axil.b_resp      =   lsdom_lpmem_axil_b_resp;
//     assign lsdom_lpmem_axil.b_valid     =   lsdom_lpmem_axil_b_valid;
//     assign lsdom_lpmem_axil_b_ready     =   lsdom_lpmem_axil.b_ready;
//     // AR channel
//     assign lsdom_lpmem_axil_ar_addr     =   lsdom_lpmem_axil.ar_addr;
//     assign lsdom_lpmem_axil_ar_prot     =   lsdom_lpmem_axil.ar_prot;
//     assign lsdom_lpmem_axil_ar_valid    =   lsdom_lpmem_axil.ar_valid;
//     assign lsdom_lpmem_axil.ar_ready    =   lsdom_lpmem_axil_ar_ready;
//     // R channel
//     assign lsdom_lpmem_axil.r_data      =   lsdom_lpmem_axil_r_data;
//     assign lsdom_lpmem_axil.r_resp      =   lsdom_lpmem_axil_r_resp;
//     assign lsdom_lpmem_axil.r_valid     =   lsdom_lpmem_axil_r_valid;
//     assign lsdom_lpmem_axil_r_ready     =   lsdom_lpmem_axil.r_ready;

//     // hsdom ===============================
//     // ADAM_SEQ    hsdom_seq ();
//     ADAM_PAUSE  hsdom_mem_pause [NO_MEMS+1] ();
//     `ADAM_AXIL_I  hsdom_mem_axil [NO_MEMS+1] ();
//     // Slave Seq Interface
//     // assign hsdom_seq.clk = hsdom_seq_clk;
//     // assign hsdom_seq.rst = hsdom_seq_rst;
//     // Memory pause interface
//     genvar i;
//     generate
//     for (i=0; i<NO_MEMS+1; i++) begin
//         assign hsdom_mem_pause_req[i] = hsdom_mem_pause[i].req;
//         assign hsdom_mem_pause[i].ack = hsdom_mem_pause_ack[i] ;
//         end
//     endgenerate
    
//     // LPMEM AXILite Master Interface
//     // AW channel
//     generate
//     for (i=0; i<NO_MEMS+1; i++) begin
//         assign  hsdom_mem_axil_aw_addr[i]   =   hsdom_mem_axil[i].aw_addr;
//         assign  hsdom_mem_axil_aw_prot[i]   =   hsdom_mem_axil[i].aw_prot;
//         assign  hsdom_mem_axil_aw_valid[i]  =   hsdom_mem_axil[i].aw_valid;
//         assign  hsdom_mem_axil[i].aw_ready  =   hsdom_mem_axil_aw_ready[i];
//     end    
//     endgenerate
    
//     // W channel
//     generate
//     for (i=0; i<NO_MEMS+1; i++) begin
//         assign  hsdom_mem_axil_w_data[i]    =   hsdom_mem_axil[i].w_data;
//         assign  hsdom_mem_axil_w_strb[i]    =   hsdom_mem_axil[i].w_strb;
//         assign  hsdom_mem_axil_w_valid[i]   =   hsdom_mem_axil[i].w_valid;
//         assign  hsdom_mem_axil[i].w_ready   =   hsdom_mem_axil_w_ready[i];
//     end    
//     endgenerate
    
//     // B channel
//     generate
//     for (i=0; i<NO_MEMS+1; i++) begin
//         assign  hsdom_mem_axil[i].b_resp    =   hsdom_mem_axil_b_resp[i];
//         assign  hsdom_mem_axil[i].b_valid   =   hsdom_mem_axil_b_valid[i]; 
//         assign  hsdom_mem_axil_b_ready[i]   =   hsdom_mem_axil[i].b_ready;
//     end    
//     endgenerate
    
//     // AR channel
//     generate
//     for (i=0; i<NO_MEMS+1; i++) begin
//         assign  hsdom_mem_axil_ar_addr[i]  =   hsdom_mem_axil[i].ar_addr;
//         assign  hsdom_mem_axil_ar_prot[i]  =   hsdom_mem_axil[i].ar_prot;
//         assign  hsdom_mem_axil_ar_valid[i] =   hsdom_mem_axil[i].ar_valid;
//         assign  hsdom_mem_axil[i].ar_ready   =   hsdom_mem_axil_ar_ready[i];
//     end    
//     endgenerate
    
//     // R channel
//     generate
//     for (i=0; i<NO_MEMS+1; i++) begin
//         assign  hsdom_mem_axil[i].r_data    =   hsdom_mem_axil_r_data[i];
//         assign  hsdom_mem_axil[i].r_resp    =   hsdom_mem_axil_r_resp[i];
//         assign  hsdom_mem_axil[i].r_valid   =   hsdom_mem_axil_r_valid[i];
//         assign  hsdom_mem_axil_r_ready[i]   =   hsdom_mem_axil[i].r_ready;
//     end    
//     endgenerate
    
//     // jtag ================================
//     ADAM_JTAG   jtag ();
//     assign jtag.trst_n  =   jtag_trst_n;
//     assign jtag.tck     =   jtag_tck;
//     assign jtag.tms     =   jtag_tms;
//     assign jtag.tdi     =   jtag_tdi;
//     assign jtag_tdo     =   jtag.tdo;

//     // async - lspa =========================
//     ADAM_IO   lspa_gpio [NO_LSPA_GPIOS*GPIO_WIDTH+1] ();
//     ADAM_IO   lspa_spi_sclk  [NO_LSPA_SPIS+1] ();
//     ADAM_IO   lspa_spi_mosi  [NO_LSPA_SPIS+1] ();
//     ADAM_IO   lspa_spi_miso  [NO_LSPA_SPIS+1] ();
//     ADAM_IO   lspa_spi_ss_n  [NO_LSPA_SPIS+1] ();
//     ADAM_IO   lspa_uart_tx   [NO_LSPA_UARTS+1] ();
//     ADAM_IO   lspa_uart_rx   [NO_LSPA_UARTS+1] ();

//     // GPIO Interface
//     generate
//     for (i=0; i<NO_LSPA_GPIOS*GPIO_WIDTH+1; i++) begin
//         assign lspa_gpio[i].i      =   lspa_gpio_io_i[i];
//         assign lspa_gpio_io_o[i]      =   lspa_gpio[i].o;
//         assign lspa_gpio_io_mode[i]   =   lspa_gpio[i].mode;
//         assign lspa_gpio_io_otype[i]   =   lspa_gpio[i].otype;
//     end    
//     endgenerate
    
//     // SPI Interface
//     generate
//         for (i=0; i<NO_LSPA_SPIS+1; i++) begin
//             assign lspa_spi_sclk[i].i      =   lspa_spi_sclk_i[i];
//             assign lspa_spi_sclk_o[i]      =   lspa_spi_sclk[i].o;
//             assign lspa_spi_sclk_mode[i]   =   lspa_spi_sclk[i].mode;
//             assign lspa_spi_sclk_otype[i]   =   lspa_spi_sclk[i].otype;
//             assign lspa_spi_mosi[i].i      =   lspa_spi_mosi_i[i];
//             assign lspa_spi_mosi_o[i]      =   lspa_spi_mosi[i].o;
//             assign lspa_spi_mosi_mode[i]   =   lspa_spi_mosi[i].mode;
//             assign lspa_spi_mosi_otype[i]   =   lspa_spi_mosi[i].otype;
//             assign lspa_spi_miso[i].i      =   lspa_spi_miso_i[i];
//             assign lspa_spi_miso_o[i]      =   lspa_spi_miso[i].o;
//             assign lspa_spi_miso_mode[i]   =   lspa_spi_miso[i].mode;
//             assign lspa_spi_miso_otype[i]   =   lspa_spi_miso[i].otype;
//             assign lspa_spi_ss_n[i].i      =   lspa_spi_ss_n_i[i];
//             assign lspa_spi_ss_n_o[i]      =   lspa_spi_ss_n[i].o;
//             assign lspa_spi_ss_n_mode[i]   =   lspa_spi_ss_n[i].mode;
//             assign lspa_spi_ss_n_otype[i]   =   lspa_spi_ss_n[i].otype;
//         end
//     endgenerate
    
    
//     // UART Interface
//     generate
//     for (i=0; i<NO_LSPA_UARTS+1; i++) begin
//         assign lspa_uart_tx[i].i       =   lspa_uart_tx_i[i];
//         assign lspa_uart_tx_o[i]       =   lspa_uart_tx[i].o;
//         assign lspa_uart_tx_mode[i]    =   lspa_uart_tx[i].mode;
//         assign lspa_uart_tx_otype[i]    =   lspa_uart_tx[i].otype;
//         assign lspa_uart_rx[i].i       =   lspa_uart_rx_i[i];
//         assign lspa_uart_rx_o[i]       =   lspa_uart_rx[i].o;
//         assign lspa_uart_rx_mode[i]    =   lspa_uart_rx[i].mode;
//         assign lspa_uart_rx_otype[i]    =   lspa_uart_rx[i].otype;
//     end
//     endgenerate
    
//     // async - lspb =========================
//     ADAM_IO   lspb_gpio [NO_LSPB_GPIOS*GPIO_WIDTH+1] ();
//     ADAM_IO   lspb_spi_sclk  [NO_LSPB_SPIS+1] ();
//     ADAM_IO   lspb_spi_mosi  [NO_LSPB_SPIS+1] ();
//     ADAM_IO   lspb_spi_miso  [NO_LSPB_SPIS+1] ();
//     ADAM_IO   lspb_spi_ss_n  [NO_LSPB_SPIS+1] ();

//     ADAM_IO   lspb_uart_tx [NO_LSPB_UARTS+1] ();
//     ADAM_IO   lspb_uart_rx [NO_LSPB_UARTS+1] ();
//     // GPIO Interface
//     generate
//     for (i=0; i<NO_LSPB_GPIOS*GPIO_WIDTH+1; i++) begin
//         assign lspb_gpio[i].i      =   lspb_gpio_io_i[i];
//         assign lspb_gpio_io_o[i]      =   lspb_gpio[i].o;
//         assign lspb_gpio_io_mode[i]   =   lspb_gpio[i].mode;
//         assign lspb_gpio_io_otype[i]   =   lspb_gpio[i].otype;
//     end    
//     endgenerate
    
//     // SPI Interface
//     generate
//     for (i=0; i<NO_LSPB_SPIS+1; i++) begin
//         assign lspb_spi_sclk[i].i      =   lspb_spi_sclk_i[i];
//         assign lspb_spi_sclk_o[i]      =   lspb_spi_sclk[i].o;
//         assign lspb_spi_sclk_mode[i]   =   lspb_spi_sclk[i].mode;
//         assign lspb_spi_sclk_otype[i]   =   lspb_spi_sclk[i].otype;
//         assign lspb_spi_mosi[i].i      =   lspb_spi_mosi_i[i];
//         assign lspb_spi_mosi_o[i]      =   lspb_spi_mosi[i].o;
//         assign lspb_spi_mosi_mode[i]   =   lspb_spi_mosi[i].mode;
//         assign lspb_spi_mosi_otype[i]   =   lspb_spi_mosi[i].otype;
//         assign lspb_spi_miso[i].i      =   lspb_spi_miso_i[i];
//         assign lspb_spi_miso_o[i]      =   lspb_spi_miso[i].o;
//         assign lspb_spi_miso_mode[i]   =   lspb_spi_miso[i].mode;
//         assign lspb_spi_miso_otype[i]   =   lspb_spi_miso[i].otype;
//         assign lspb_spi_ss_n[i].i      =   lspb_spi_ss_n_i[i];
//         assign lspb_spi_ss_n_o[i]      =   lspb_spi_ss_n[i].o;
//         assign lspb_spi_ss_n_mode[i]   =   lspb_spi_ss_n[i].mode;
//         assign lspb_spi_ss_n_otype[i]   =   lspb_spi_ss_n[i].otype;
//     end
//     endgenerate

//     // UART Interface
//     generate
//     for (i=0; i<NO_LSPB_UARTS+1; i++) begin
//         assign lspb_uart_tx[i].i       =   lspb_uart_tx_i[i];
//         assign lspb_uart_tx_o[i]       =   lspb_uart_tx[i].o;
//         assign lspb_uart_tx_mode[i]    =   lspb_uart_tx[i].mode;
//         assign lspb_uart_tx_otype[i]    =   lspb_uart_tx[i].otype;
//         assign lspb_uart_rx[i].i       =   lspb_uart_rx_i[i];
//         assign lspb_uart_rx_o[i]       =   lspb_uart_rx[i].o;
//         assign lspb_uart_rx_mode[i]    =   lspb_uart_rx[i].mode;
//         assign lspb_uart_rx_otype[i]    =   lspb_uart_rx[i].otype;
//     end
//     endgenerate
    
//     adam #(
//         `ADAM_CFG_PARAMS_MAP
//     ) adam (
//         .lsdom_seq (lsdom_seq),

//         .lsdom_pause_ext  (lsdom_pause_ext),

//         .lsdom_lpmem_rst   (lsdom_lpmem_rst),
//         .lsdom_lpmem_pause (lsdom_lpmem_pause),
//         .lsdom_lpmem_axil  (lsdom_lpmem_axil),

//         .hsdom_seq (lsdom_seq),

//         .hsdom_mem_rst   (hsdom_mem_rst),
//         .hsdom_mem_pause (hsdom_mem_pause),
//         .hsdom_mem_axil  (hsdom_mem_axil),
        
//         .jtag (jtag),

//         .lspa_gpio_io   (lspa_gpio),
//         .lspa_gpio_func (lspa_gpio_func),

//         .lspa_spi_sclk (lspa_spi_sclk),
//         .lspa_spi_mosi (lspa_spi_mosi),
//         .lspa_spi_miso (lspa_spi_miso),
//         .lspa_spi_ss_n (lspa_spi_ss_n),

//         .lspa_uart_tx (lspa_uart_tx),
//         .lspa_uart_rx (lspa_uart_rx),
        
//         .lspb_gpio_io   (lspb_gpio),
//         .lspb_gpio_func (lspb_gpio_func),

//         .lspb_spi_sclk (lspb_spi_sclk),
//         .lspb_spi_mosi (lspb_spi_mosi),
//         .lspb_spi_miso (lspb_spi_miso),
//         .lspb_spi_ss_n (lspb_spi_ss_n),

//         .lspb_uart_tx (lspb_uart_tx),
//         .lspb_uart_rx (lspb_uart_rx)
//     );
    

    
// endmodule
