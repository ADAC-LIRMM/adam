`include "adam/macros.svh"
`include "apb/assign.svh"
`include "axi/assign.svh"

module adam #(
    `ADAM_CFG_PARAMS
) (
    // lsdom ==================================================================

    ADAM_SEQ.Slave lsdom_seq,

    ADAM_PAUSE.Slave lsdom_pause_ext,

    output logic      lsdom_lpmem_rst,
    ADAM_PAUSE.Master lsdom_lpmem_pause,
    AXI_LITE.Master   lsdom_lpmem_axil,

    // hsdom ==================================================================

    ADAM_SEQ.Slave hsdom_seq,

    output logic      hsdom_mem_rst   [NO_MEMS+1],
    ADAM_PAUSE.Master hsdom_mem_pause [NO_MEMS+1],
    AXI_LITE.Master   hsdom_mem_axil  [NO_MEMS+1],

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

    // signals ================================================================
    
    ADAM_PAUSE lsdom_pause ();
    ADAM_PAUSE hsdom_pause ();

    // ADAM_PAUSE lsdom_fab_pause ();
    // ADAM_PAUSE hsdom_fab_pause ();

    ADAM_PAUSE fab_lsdom_pause ();
    ADAM_PAUSE fab_hsdom_pause ();

    ADAM_PAUSE fab_lspa_pause ();
    ADAM_PAUSE fab_lspb_pause ();

    ADAM_SEQ    lsdom_lpcpu_seq ();
    logic       lsdom_lpcpu_rst;
    ADAM_PAUSE  lsdom_lpcpu_pause ();
    ADDR_T      lsdom_lpcpu_boot_addr;
    logic       lsdom_lpcpu_irq;

    logic       lsdom_lspa_rst   [NO_LSPAS+1];
    ADAM_PAUSE  lsdom_lspa_pause [NO_LSPAS+1] ();
    `ADAM_APB_I lsdom_lspa_apb   [NO_LSPAS+1] ();
    logic       lsdom_lspa_irq   [NO_LSPAS+1];

    logic       lsdom_lspb_rst   [NO_LSPBS+1];
    ADAM_PAUSE  lsdom_lspb_pause [NO_LSPBS+1] ();
    `ADAM_APB_I lsdom_lspb_apb   [NO_LSPBS+1] ();
    logic       lsdom_lspb_irq   [NO_LSPBS+1];

    ADAM_SEQ     hsdom_cpu_seq       [NO_CPUS+1] ();
    logic        hsdom_cpu_rst       [NO_CPUS+1];
    ADAM_PAUSE   hsdom_cpu_pause     [NO_CPUS+1] ();
    ADDR_T       hsdom_cpu_boot_addr [NO_CPUS+1];
    logic        hsdom_cpu_irq       [NO_CPUS+1];

    `ADAM_AXIL_I hsdom_cpu_axil [2*NO_CPUS+1] ();

    logic        hsdom_dma_rst   [NO_DMAS+1];
    ADAM_PAUSE   hsdom_dma_pause [NO_DMAS+1] ();
    `ADAM_AXIL_I hsdom_dma_axil  [NO_DMAS+1] ();
    logic        hsdom_dma_irq   [NO_DMAS+1];

    logic        hsdom_hsp_rst   [NO_HSPS+1];
    ADAM_PAUSE   hsdom_hsp_pause [NO_HSPS+1] ();
    `ADAM_AXIL_I hsdom_hsp_axil  [NO_HSPS+1] ();
    logic        hsdom_hsp_irq   [NO_HSPS+1];

    ADAM_PAUSE   lsdom_syscfg_pause ();
    `ADAM_AXIL_I lsdom_syscfg_axil ();

    ADAM_PAUSE   hsdom_debug_pause ();
    `ADAM_AXIL_I hsdom_debug_mst_axil ();
    `ADAM_AXIL_I hsdom_debug_slv_axil ();
    logic        hsdom_debug_req     [NO_CPUS+2];
    logic        hsdom_debug_unavail [NO_CPUS+2];

    // lsdom - lpcpu ==========================================================

    `ADAM_AXIL_I lsdom_lpcpu_axil [2] ();

    assign lsdom_lpcpu_seq.clk = lsdom_seq.clk;
    assign lsdom_lpcpu_seq.rst = lsdom_seq.rst || lsdom_lpcpu_rst; 
    
    if (EN_LPCPU) begin
        `ADAM_CORE_LPCPU lsdom_lpcpu (
            .seq   (lsdom_lpcpu_seq),
            .pause (lsdom_lpcpu_pause),

            .boot_addr (lsdom_lpcpu_boot_addr),
            .hart_id   ('0),

            .axil_inst (lsdom_lpcpu_axil[0]),
            .axil_data (lsdom_lpcpu_axil[1]),

            .irq (lsdom_lpcpu_irq),

            .debug_req     ('0),
            .debug_unavail ()
        );
    end
    else begin
        // TODO: tie off
    end

    assign hsdom_debug_unavail[0] = '1; // LPCPU doesn't support debug

    // lsdom - lspa ===========================================================

    if (EN_LSPA) begin
        adam_periph #(
            `ADAM_CFG_PARAMS_MAP,

            .NO_GPIOS  (NO_LSPA_GPIOS),
            .NO_SPIS   (NO_LSPA_SPIS),
            .NO_TIMERS (NO_LSPA_TIMERS),
            .NO_UARTS  (NO_LSPA_UARTS)
        ) adam_periph_lspa (
            .seq   (lsdom_seq),
            
            .periph_rst   (lsdom_lspa_rst),
            .periph_pause (lsdom_lspa_pause),
            .periph_apb   (lsdom_lspa_apb),
            .periph_irq   (lsdom_lspa_irq),
            
            .gpio_io   (lspa_gpio_io),
            .gpio_func (lspa_gpio_func),

            .spi_sclk (lspa_spi_sclk),
            .spi_mosi (lspa_spi_mosi),
            .spi_miso (lspa_spi_miso),
            .spi_ss_n (lspa_spi_ss_n),

            .uart_tx (lspa_uart_tx),
            .uart_rx (lspa_uart_rx)
        );
    end
    else begin
        // TODO: tie off
    end

    // lsdom - lspb ===========================================================

    if (EN_LSPB) begin
        adam_periph #(
            `ADAM_CFG_PARAMS_MAP,

            .NO_GPIOS  (NO_LSPB_GPIOS),
            .NO_SPIS   (NO_LSPB_SPIS),
            .NO_TIMERS (NO_LSPB_TIMERS),
            .NO_UARTS  (NO_LSPB_UARTS)
        ) adam_periph_lspb (
            .seq   (lsdom_seq),
            .pause (lsdom_lspb_pause),
            
            .periph_rst   (lsdom_lspb_rst),
            .periph_pause (lsdom_lspb_pause),
            .periph_apb   (lsdom_lspb_apb),
            .periph_irq   (lsdom_lspb_irq),

            .gpio_io   (lspb_gpio_io),
            .gpio_func (lspb_gpio_func),

            .spi_sclk (lspb_spi_sclk),
            .spi_mosi (lspb_spi_mosi),
            .spi_miso (lspb_spi_miso),
            .spi_ss_n (lspb_spi_ss_n),

            .uart_tx (lspb_uart_tx),
            .uart_rx (lspb_uart_rx)
        );
    end
    else begin
        // TODO: tie off
    end

    // hsdom - cpu ============================================================

    for (genvar i = 0; i < NO_CPUS; i++) begin

        assign hsdom_cpu_seq[i].clk = hsdom_seq.clk;
        assign hsdom_cpu_seq[i].rst = hsdom_seq.rst || hsdom_cpu_rst[i]; 

        `ADAM_CORE_CPU #(
            `ADAM_CFG_PARAMS_MAP
        ) hsdom_cpu (
            .seq   (hsdom_seq),
            .pause (hsdom_cpu_pause[i]),

            .boot_addr (hsdom_cpu_boot_addr[i]),
            .hart_id   (i+1), // +1 because LPCPU is 0

            .axil_inst (hsdom_cpu_axil[2*i + 0]),
            .axil_data (hsdom_cpu_axil[2*i + 1]),

            .irq       (hsdom_cpu_irq[i]),
            
            .debug_req     (hsdom_debug_req[i+1]),
            .debug_unavail (hsdom_debug_unavail[i+1])
        );
    end

    // hsdom - dma ============================================================

    for (genvar i = 0; i < NO_DMAS; i++) begin
        `ADAM_PAUSE_SLV_TIE_OFF(hsdom_dma_pause[i]);
        `ADAM_AXIL_MST_TIE_OFF (hsdom_dma_axil [i]);
    end

    // hsdom - hsp ===========================================================

    for (genvar i = 0; i < NO_HSPS; i++) begin
        `ADAM_PAUSE_SLV_TIE_OFF(hsdom_hsp_pause[i]);
        `ADAM_AXIL_SLV_TIE_OFF (hsdom_hsp_axil [i]);
    end

    // hsdom - debug ==========================================================

    `ADAM_PAUSE_MST_TIE_ON(hsdom_debug_pause);

    if (EN_DEBUG) begin
        adam_debug #(
            `ADAM_CFG_PARAMS_MAP
        ) adam_debug (
            .seq   (hsdom_seq),
            .pause (hsdom_debug_pause),

            .req     (hsdom_debug_req),
            .unavail (hsdom_debug_unavail),

            .axil_slv (hsdom_debug_mst_axil),
            .axil_mst (hsdom_debug_slv_axil),

            .jtag (jtag)
        );
    end
    else begin
        `ADAM_AXIL_SLV_TIE_OFF(hsdom_debug_mst_axil);
        `ADAM_AXIL_MST_TIE_OFF(hsdom_debug_slv_axil);
    end

    // lsdom - syscfg =========================================================

    `ADAM_PAUSE_MST_TIE_ON(lsdom_syscfg_pause);
    
    adam_syscfg #(
        `ADAM_CFG_PARAMS_MAP
    ) adam_syscfg (
        .seq   (lsdom_seq),
        .pause (lsdom_syscfg_pause),

        .slv (lsdom_syscfg_axil),

        .lsdom_rst   (lsdom_rst),
        .lsdom_pause (lsdom_pause),

        .hsdom_rst   (hsdom_rst), 
        .hsdom_pause (hsdom_pause), 

        .fab_lsdom_rst   (fab_lsdom_rst),
        .fab_lsdom_pause (fab_lsdom_pause),

        .fab_hsdom_rst   (fab_hsdom_rst),
        .fab_hsdom_pause (fab_hsdom_pause),
    
        .fab_lspa_rst   (fab_lspa_rst),
        .fab_lspa_pause (fab_lspa_pause),
    
        .fab_lspb_rst   (fab_lspb_rst),
        .fab_lspb_pause (fab_lspb_pause),
    
        .lpcpu_rst       (lsdom_lpcpu_rst),
        .lpcpu_pause     (lsdom_lpcpu_pause),
        .lpcpu_boot_addr (lsdom_lpcpu_boot_addr),
        .lpcpu_irq       (lsdom_lpcpu_irq),

        .lpmem_rst   (lsdom_lpmem_rst),
        .lpmem_pause (lsdom_lpmem_pause),

        .cpu_rst       (hsdom_cpu_rst), 
        .cpu_pause     (hsdom_cpu_pause), 
        .cpu_boot_addr (hsdom_cpu_boot_addr), 
        .cpu_irq       (hsdom_cpu_irq), 

        .dma_rst   (hsdom_dma_rst), 
        .dma_pause (hsdom_dma_pause), 
        .dma_irq   (hsdom_dma_irq), 

        .mem_rst   (hsdom_mem_rst), 
        .mem_pause (hsdom_mem_pause), 

        .lspa_rst   (lsdom_lspa_rst), 
        .lspa_pause (lsdom_lspa_pause),
        .lspa_irq   (lsdom_lspa_irq),

        .lspb_rst   (lsdom_lspb_rst),
        .lspb_pause (lsdom_lspb_pause),
        .lspb_irq   (lsdom_lspb_irq),

        .hsp_rst   (hsdom_hsp_rst), 
        .hsp_pause (hsdom_hsp_pause), 
        .hsp_irq   (hsdom_hsp_irq) 
    );

    // adam_fabric ============================================================

    adam_fabric #(
        `ADAM_CFG_PARAMS_MAP
    ) adam_fabric (
        .lsdom_seq        (lsdom_seq),
        .lsdom_pause      (fab_lsdom_pause),
        .lsdom_pause_lspa (fab_lspa_pause),
        .lsdom_pause_lspb (fab_lspb_pause),
        
        .lsdom_lpcpu (lsdom_lpcpu_axil),

        .lsdom_lpmem  (lsdom_lpmem_axil),
        .lsdom_syscfg (lsdom_syscfg_axil),
        .lsdom_lspa   (lsdom_lspa_apb),
        .lsdom_lspb   (lsdom_lspb_apb),

        .hsdom_seq   (hsdom_seq),
        .hsdom_pause (fab_hsdom_pause),

        .hsdom_cpu       (hsdom_cpu_axil),
        .hsdom_dma       (hsdom_dma_axil),
        .hsdom_debug_slv (hsdom_debug_slv_axil),

        .hsdom_mem       (hsdom_mem_axil),
        .hsdom_hsp       (hsdom_hsp_axil),
        .hsdom_debug_mst (hsdom_debug_mst_axil)
    );

    // pause ==================================================================

    `ADAM_PAUSE_SLV_TIE_ON(lsdom_pause_ext);

    `ADAM_PAUSE_SLV_TIE_ON(lsdom_pause);
    `ADAM_PAUSE_SLV_TIE_ON(hsdom_pause);

endmodule