`include "adam/macros.svh"

module adam_periph_syscfg #(
    `ADAM_CFG_PARAMS
) (
    ADAM_SEQ.Slave   seq,
    ADAM_PAUSE.Slave pause,

    AXI_LITE.Master slv,

    output logic  irq,

    output logic      lsdom_rst,
    ADAM_PAUSE.Master lsdom_pause,
    
    output logic      hsdom_rst,
    ADAM_PAUSE.Master hsdom_pause,
    
    output logic      fab_lsdom_rst,
    ADAM_PAUSE.Master fab_lsdom_pause,
    
    output logic      fab_hsdom_rst,
    ADAM_PAUSE.Master fab_hsdom_pause,
    
    output logic      fab_lspa_rst,
    ADAM_PAUSE.Master fab_lspa_pause,
    
    output logic      fab_lspb_rst,
    ADAM_PAUSE.Master fab_lspb_pause,
    
    output logic      fab_hsbp_rst,
    ADAM_PAUSE.Master fab_hsbp_pause,
    
    output logic      fab_hsp_rst,
    ADAM_PAUSE.Master fab_hsp_pause,

    output logic      lpcpu_rst,
    ADAM_PAUSE.Master lpcpu_pause,
    output ADDR_T     lpcpu_boot_addr,
    output logic      lpcpu_irq,

    output logic      lpmem_rst,
    ADAM_PAUSE.Master lpmem_pause,

    output logic      cpu_rst       [NO_CPUS+1],
    ADAM_PAUSE.Master cpu_pause     [NO_CPUS+1],
    output ADDR_T     cpu_boot_addr [NO_CPUS+1],
    output logic      cpu_irq       [NO_CPUS+1],

    output logic      dma_rst       [NO_DMAS+1],
    ADAM_PAUSE.Master dma_pause     [NO_DMAS+1],
    output logic      dma_irq       [NO_DMAS+1],

    output logic      mem_rst   [NO_MEMS+1],
    ADAM_PAUSE.Master mem_pause [NO_MEMS+1],

    output logic      lspa_rst   [NO_LSPAS+1],
    ADAM_PAUSE.Master lspa_pause [NO_LSPAS+1],
    input  logic      lspa_irq   [NO_LSPAS+1],

    output logic      lspb_rst   [NO_LSPBS+1],
    ADAM_PAUSE.Master lspb_pause [NO_LSPBS+1],
    input  logic      lspb_irq   [NO_LSPBS+1],

    output logic      hsp_rst   [NO_HSPS+1],
    ADAM_PAUSE.Master hsp_pause [NO_HSPS+1],
    input  logic      hsp_irq   [NO_HSPS+1]
);

    localparam NO_TGTS = 4 + EN_LSPA + EN_LSPB + EN_HSP + EN_LPCPU + EN_LPMEM +
        NO_CPUS + NO_DMAS + NO_MEMS + NO_LSPAS + NO_LSPBS;
    
    DATA_T irq_vec;

    // Pause ==================================================================

    ADAM_PAUSE apb_pause ();
    ADAM_PAUSE tgt_demux_pause ();
    ADAM_PAUSE tgt_pause [NO_TGTS+1] ();
    ADAM_PAUSE pause_null ();

    adam_pause_demux #(
        .NO_MSTS  (2),
        .PARALLEL (0)
    ) top_pause_demux (
        .seq (seq),

        .slv (pause),
        .mst ('{apb_pause, tgt_demux_pause, pause_null})
    );

    adam_pause_demux #(
        .NO_MSTS  (NO_TGTS),
        .PARALLEL (1)
    ) tgt_pause_demux (
        .seq (seq),

        .slv (tgt_demux_pause),
        .mst (tgt_pause)
    );
    
    // Interconnect ===========================================================
    
    localparam type RULE_T = adam_cfg_pkg::MMAP_T;

    `ADAM_APB_I tgt_apb [NO_TGTS+1] ();
    
    RULE_T tgt_addr_map [NO_TGTS+1];

    generate
        for (genvar i = 0; i < NO_TGTS; i++) begin
            assign tgt_addr_map[i] = '{
                start : 4*i,
                end_  : 4*(i+1)
            };
        end
    endgenerate

    adam_axil_apb_bridge #(
        `ADAM_CFG_PARAMS_MAP,

        .NO_MSTS (NO_TGTS),
    
        .RULE_T (RULE_T)
    ) adam_axil_apb_bridge (
        .seq   (seq),
        .pause (apb_pause),

        .slv (slv),
        .mst (tgt_apb),

        .addr_map (tgt_addr_map)
    );
    
    // Mapping ================================================================

    generate
        localparam LSDOM_S = 0;
        localparam LSDOM_E = LSDOM_S + 1;

        localparam HSDOM_S = LSDOM_E;
        localparam HSDOM_E = HSDOM_S + 1;

        localparam FAB_LSDOM_S = HSDOM_E;
        localparam FAB_LSDOM_E = FAB_LSDOM_S + 1;

        localparam FAB_HSDOM_S = FAB_LSDOM_E;
        localparam FAB_HSDOM_E = FAB_HSDOM_S + 1;

        localparam FAB_LSPA_S = FAB_HSDOM_E;
        localparam FAB_LSPA_E = FAB_LSPA_S + EN_LSPA;

        localparam FAB_LSPB_S = FAB_LSPA_E;
        localparam FAB_LSPB_E = FAB_LSPB_S + EN_LSPB;

        localparam FAB_HSP_S = FAB_LSPB_E;
        localparam FAB_HSP_E = FAB_HSP_S + EN_HSP;

        localparam LPCPU_S = FAB_HSP_E;
        localparam LPCPU_E = LPCPU_S + EN_LPCPU;

        localparam LPMEM_S = LPCPU_E;
        localparam LPMEM_E = LPMEM_S + EN_LPMEM;

        localparam CPU_S = LPMEM_E;
        localparam CPU_E = CPU_S + NO_CPUS;

        localparam DMA_S = CPU_E;
        localparam DMA_E = DMA_S + NO_DMAS;

        localparam MEM_S = DMA_E;
        localparam MEM_E = MEM_S + NO_MEMS;

        localparam LSPA_S = MEM_E;
        localparam LSPA_E = LSPA_S + NO_LSPAS;

        localparam LSPB_S = LSPA_E;
        localparam LSPB_E = LSPB_S + NO_LSPBS;

        localparam HSP_S = LSPB_E;
        localparam HSP_E = HSP_S + NO_HSPS;

        if (LSDOM_E > LSDOM_S) begin
            adam_periph_syscfg_tgt #(
                `ADAM_CFG_PARAMS_MAP,

                .EN_BOOTSTRAP (1),
                .EN_BOOT_ADDR (0),
                .EN_IRQ       (0)
            ) tgt_lsdom (
                .seq   (seq),
                .pause (tgt_pause[LSDOM_S]),

                .slv (tgt_apb[LSDOM_S]),

                .irq_vec (irq_vec),

                .tgt_rst       (lsdom_rst),        
                .tgt_pause     (lsdom_pause),
                .tgt_boot_addr (),
                .tgt_irq       ()
            );
        end

        if (HSDOM_E > HSDOM_S) begin
            adam_periph_syscfg_tgt #(
                `ADAM_CFG_PARAMS_MAP,

                .EN_BOOTSTRAP (1),
                .EN_BOOT_ADDR (0),
                .EN_IRQ       (0)
            ) tgt_hsdom (
                .seq   (seq),
                .pause (tgt_pause[HSDOM_S]),

                .slv (tgt_apb[HSDOM_S]),

                .irq_vec (irq_vec),

                .tgt_rst       (hsdom_rst),        
                .tgt_pause     (hsdom_pause),
                .tgt_boot_addr (),
                .tgt_irq       ()
            );
        end

        if (FAB_LSDOM_E > FAB_LSDOM_S) begin
            adam_periph_syscfg_tgt #(
                `ADAM_CFG_PARAMS_MAP,

                .EN_BOOTSTRAP (1),
                .EN_BOOT_ADDR (0),
                .EN_IRQ       (0)
            ) tgt_fab_lsdom (
                .seq   (seq),
                .pause (tgt_pause[FAB_LSDOM_S]),

                .slv (tgt_apb[FAB_LSDOM_S]),

                .irq_vec (irq_vec),

                .tgt_rst       (fab_lsdom_rst),        
                .tgt_pause     (fab_lsdom_pause),
                .tgt_boot_addr (),
                .tgt_irq       ()
            );
        end

        if (FAB_HSDOM_E > FAB_HSDOM_S) begin
            adam_periph_syscfg_tgt #(
                `ADAM_CFG_PARAMS_MAP,

                .EN_BOOTSTRAP (1),
                .EN_BOOT_ADDR (0),
                .EN_IRQ       (0)
            ) tgt_fab_hsdom (
                .seq   (seq),
                .pause (tgt_pause[FAB_HSDOM_S]),

                .slv (tgt_apb[FAB_HSDOM_S]),

                .irq_vec (irq_vec),

                .tgt_rst       (fab_hsdom_rst),        
                .tgt_pause     (fab_hsdom_pause),
                .tgt_boot_addr (),
                .tgt_irq       ()
            );
        end

        if (FAB_LSPA_E > FAB_LSPA_S) begin
            adam_periph_syscfg_tgt #(
                `ADAM_CFG_PARAMS_MAP,

                .EN_BOOTSTRAP (1),
                .EN_BOOT_ADDR (0),
                .EN_IRQ       (0)
            ) tgt_fab_lspa (
                .seq   (seq),
                .pause (tgt_pause[FAB_LSPA_S]),

                .slv (tgt_apb[FAB_LSPA_S]),

                .irq_vec (irq_vec),

                .tgt_rst       (fab_lspa_rst),        
                .tgt_pause     (fab_lspa_pause),
                .tgt_boot_addr (),
                .tgt_irq       ()
            ); 
        end 
        else begin
            assign fab_lspa_rst = '1;
            `ADAM_PAUSE_MST_TIE_OFF(fab_lspa_pause);
        end

        if (FAB_LSPB_E > FAB_LSPB_S) begin
            adam_periph_syscfg_tgt #(
                `ADAM_CFG_PARAMS_MAP,

                .EN_BOOTSTRAP (0),
                .EN_BOOT_ADDR (0),
                .EN_IRQ       (0)
            ) tgt_fab_lspb (
                .seq   (seq),
                .pause (tgt_pause[FAB_LSPB_S]),

                .slv (tgt_apb[FAB_LSPB_S]),

                .irq_vec (irq_vec),

                .tgt_rst       (fab_lspb_rst),        
                .tgt_pause     (fab_lspb_pause),
                .tgt_boot_addr (),
                .tgt_irq       ()
            );
        end
        else begin
            assign fab_lspb_rst = '1;
            `ADAM_PAUSE_MST_TIE_OFF(fab_lspb_pause);
        end

        if (FAB_HSP_E > FAB_HSP_S) begin
            adam_periph_syscfg_tgt #(
                `ADAM_CFG_PARAMS_MAP,

                .EN_BOOTSTRAP (1),
                .EN_BOOT_ADDR (0),
                .EN_IRQ       (0)
            ) tgt_fab_hsp (
                .seq   (seq),
                .pause (tgt_pause[FAB_HSP_S]),

                .slv (tgt_apb[FAB_HSP_S]),

                .irq_vec (irq_vec),

                .tgt_rst       (fab_hsp_rst),        
                .tgt_pause     (fab_hsp_pause),
                .tgt_boot_addr (),
                .tgt_irq       ()
            );
        end
        else begin
            assign fab_hsp_rst = '1;
            `ADAM_PAUSE_MST_TIE_OFF(fab_hsp_pause);
        end

        if (LPCPU_E > LPCPU_S) begin
            adam_periph_syscfg_tgt #(
                `ADAM_CFG_PARAMS_MAP,

                .EN_BOOTSTRAP (EN_BOOTSTRAP_LPCPU),
                .EN_BOOT_ADDR (1),
                .EN_IRQ       (1)
            ) tgt_lpcpu (
                .seq   (seq),
                .pause (tgt_pause[LPCPU_S]),

                .slv (tgt_apb[LPCPU_S]),

                .irq_vec (irq_vec),

                .tgt_rst       (lpcpu_rst),        
                .tgt_pause     (lpcpu_pause),
                .tgt_boot_addr (lpcpu_boot_addr),
                .tgt_irq       (lpcpu_irq)
            );
        end
        else begin
            assign lpcpu_rst = '1;
            `ADAM_PAUSE_MST_TIE_OFF(lpcpu_pause);
        end

        if (LPMEM_E > LPMEM_S) begin
            adam_periph_syscfg_tgt #(
                `ADAM_CFG_PARAMS_MAP,

                .EN_BOOTSTRAP (EN_BOOTSTRAP_LPMEM),
                .EN_BOOT_ADDR (0),
                .EN_IRQ       (0)
            ) tgt_lpmem (
                .seq   (seq),
                .pause (tgt_pause[LPMEM_S]),

                .slv (tgt_apb[LPMEM_S]),

                .irq_vec (irq_vec),

                .tgt_rst       (lpmem_rst),        
                .tgt_pause     (lpmem_pause),
                .tgt_boot_addr (),
                .tgt_irq       ()
            );
        end
        else begin
            assign lpmem_rst = '1;
            `ADAM_PAUSE_MST_TIE_OFF(lpmem_pause);
        end

        for (genvar i = CPU_S; i < CPU_E; i++) begin
            adam_periph_syscfg_tgt #(
                `ADAM_CFG_PARAMS_MAP,

                .EN_BOOTSTRAP ((i == 0) ? EN_BOOTSTRAP_CPU0 : 0),
                .EN_BOOT_ADDR (0),
                .EN_IRQ       (0)
            ) tgt_cpu (
                .seq   (seq),
                .pause (tgt_pause[i]),

                .slv (tgt_apb[i]),

                .irq_vec (irq_vec),

                .tgt_rst       (cpu_rst      [i - CPU_S]),        
                .tgt_pause     (cpu_pause    [i - CPU_S]),
                .tgt_boot_addr (cpu_boot_addr[i - CPU_S]),
                .tgt_irq       (cpu_irq      [i - CPU_S])
            );
        end

        for (genvar i = DMA_S; i < DMA_E; i++) begin
            adam_periph_syscfg_tgt #(
                `ADAM_CFG_PARAMS_MAP,

                .EN_BOOTSTRAP (0),
                .EN_BOOT_ADDR (0),
                .EN_IRQ       (1)
            ) tgt_dma (
                .seq   (seq),
                .pause (tgt_pause[i]),

                .slv (tgt_apb[i]),

                .irq_vec (irq_vec),

                .tgt_rst       (dma_rst  [i - DMA_S]),        
                .tgt_pause     (dma_pause[i - DMA_S]),
                .tgt_boot_addr (),
                .tgt_irq       (dma_irq  [i - DMA_S])
            );
        end

        for (genvar i = MEM_S; i < MEM_E; i++) begin
            adam_periph_syscfg_tgt #(
                `ADAM_CFG_PARAMS_MAP,

                .EN_BOOTSTRAP ((i == 0) ? EN_BOOTSTRAP_MEM0 : 0),
                .EN_BOOT_ADDR (0),
                .EN_IRQ       (0)
            ) tgt_mem (
                .seq   (seq),
                .pause (tgt_pause[i]),

                .slv (tgt_apb[i]),

                .irq_vec (irq_vec),

                .tgt_rst       (mem_rst  [i - MEM_S]),        
                .tgt_pause     (mem_pause[i - MEM_S]),
                .tgt_boot_addr (),
                .tgt_irq       ()
            );
        end

        for (genvar i = LSPA_S; i < LSPA_E; i++) begin
            adam_periph_syscfg_tgt #(
                `ADAM_CFG_PARAMS_MAP,

                .EN_BOOTSTRAP (0),
                .EN_BOOT_ADDR (0),
                .EN_IRQ       (0)
            ) tgt_lspa (
                .seq   (seq),
                .pause (tgt_pause[i]),

                .slv (tgt_apb[i]),

                .irq_vec (irq_vec),

                .tgt_rst       (lspa_rst  [i - LSPA_S]),        
                .tgt_pause     (lspa_pause[i - LSPA_S]),
                .tgt_boot_addr (),
                .tgt_irq       ()
            );
        end

        for (genvar i = LSPB_S; i < LSPB_E; i++) begin
            adam_periph_syscfg_tgt #(
                `ADAM_CFG_PARAMS_MAP,

                .EN_BOOTSTRAP (0),
                .EN_BOOT_ADDR (0),
                .EN_IRQ       (0)
            ) tgt_lspb (
                .seq   (seq),
                .pause (tgt_pause[i]),

                .slv (tgt_apb[i]),

                .irq_vec (irq_vec),

                .tgt_rst       (lspb_rst  [i - LSPB_S]),        
                .tgt_pause     (lspb_pause[i - LSPB_S]),
                .tgt_boot_addr (),
                .tgt_irq       ()
            );
        end

        for (genvar i = HSP_S; i < HSP_E; i++) begin
            adam_periph_syscfg_tgt #(
                `ADAM_CFG_PARAMS_MAP,

                .EN_BOOTSTRAP (0),
                .EN_BOOT_ADDR (0),
                .EN_IRQ       (0)
            ) tgt_hsp (
                .seq   (seq),
                .pause (tgt_pause[i]),

                .slv (tgt_apb[i]),

                .irq_vec (irq_vec),

                .tgt_rst       (hsp_rst  [i - HSP_S]),        
                .tgt_pause     (hsp_pause[i - HSP_S]),
                .tgt_boot_addr (),
                .tgt_irq       ()
            );
        end

    endgenerate

endmodule