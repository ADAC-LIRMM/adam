`include "adam/macros.svh"

module adam_periph_syscfg #(
    `ADAM_CFG_PARAMS
) (
    ADAM_SEQ.Slave   seq,
    ADAM_PAUSE.Slave pause,

    AXI_LITE.Master slv,

    input  logic irq_vec,
    output logic irq,

    output logic      lsdom_rst,
    ADAM_PAUSE.Master lsdom_pause,
    
    output logic      hsdom_rst,
    ADAM_PAUSE.Master hsdom_pause,
    
    output logic      fab_lsdom_rst,
    ADAM_PAUSE.Master fab_lsdom_pause,
    
    output logic      fab_hsdom_rst,
    ADAM_PAUSE.Master fab_hsdom_pause,
    
    output logic      fab_lsbp_rst,
    ADAM_PAUSE.Master fab_lsbp_pause,
    
    output logic      fab_lsip_rst,
    ADAM_PAUSE.Master fab_lsip_pause,
    
    output logic      fab_hsbp_rst,
    ADAM_PAUSE.Master fab_hsbp_pause,
    
    output logic      fab_hsip_rst,
    ADAM_PAUSE.Master fab_hsip_pause,

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

    output logic      lsbp_rst   [NO_LSBPS+1],
    ADAM_PAUSE.Master lsbp_pause [NO_LSBPS+1],
    input  logic      lsbp_irq   [NO_LSBPS+1],

    output logic      lsip_rst   [NO_LSIPS+1],
    ADAM_PAUSE.Master lsip_pause [NO_LSIPS+1],
    input  logic      lsip_irq   [NO_LSIPS+1]
);

    localparam NO_TGTS = 4 + EN_LSBP + EN_LSIP + EN_HSBP +
        EN_HSIP + EN_LPCPU + EN_LPMEM + NO_CPUS + NO_DMAS + NO_MEMS +
        NO_LSBPS + NO_LSIPS;
    
    // Pause ==================================================================

    ADAM_PAUSE apb_pause ();
    ADAM_PAUSE tgt_demux_pause ();
    ADAM_PAUSE tgt_pause [NO_TGTS+1] ();

    adam_pause_demux #(
        .NO_MSTS  (2),
        .PARALLEL (0)
    ) top_pause_demux (
        .seq (seq),

        .slv  ('{apb_pause, tgt_demux_pause}),
        .msts (tgt_pause)
    );

    adam_pause_demux #(
        .NO_MSTS  (NO_TGTS),
        .PARALLEL (1)
    ) tgt_pause_demux (
        .seq (seq),

        .slv  (tgt_demux_pause),
        .msts (tgt_pause)
    );
    
    // Interconnect ===========================================================
    
    typedef struct packed {
        ADDR_T start_addr;
        ADDR_T end_addr;
    } rule_t;

    `ADAM_APB_I tgt_apb [NO_TGTS+1] ();
    
    rule_t tgt_addr_map [NO_TGTS+1];

    generate
        for (genvar i = 0; i < NO_TGTS; i++) begin
            assign tgt_addr_map[i] = '{
                start_addr: 4*i,
                end_addr: 4*(i+1)
            };
        end
    endgenerate

    adam_axil_apb_bridge #(
        `ADAM_CFG_PARAMS_MAP,

        .NO_APBS (NO_TGTS),
    
        .RULE_T (rule_t)
    ) dut (
        .seq   (seq),
        .pause (apb_pause),

        .axil (slv),
        
        .apb (tgt_apb),

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

        localparam FAB_LSBP_S = FAB_HSDOM_E;
        localparam FAB_LSBP_E = FAB_LSBP_S + EN_LSBP;

        localparam FAB_LSIP_S = FAB_LSBP_E;
        localparam FAB_LSIP_E = FAB_LSIP_S + EN_LSIP;

        localparam FAB_HSBP_S = FAB_LSIP_E;
        localparam FAB_HSBP_E = FAB_HSBP_S + EN_HSBP;

        localparam FAB_HSIP_S = FAB_HSBP_E;
        localparam FAB_HSIP_E = FAB_HSIP_S + EN_HSIP;

        localparam LPCPU_S = FAB_HSIP_E;
        localparam LPCPU_E = LPCPU_S + EN_LPCPU;

        localparam LPMEM_S = LPCPU_E;
        localparam LPMEM_E = LPMEM_S + EN_LPMEM;

        localparam CPU_S = LPMEM_E;
        localparam CPU_E = CPU_S + NO_CPUS;

        localparam DMA_S = CPU_E;
        localparam DMA_E = DMA_S + NO_DMAS;

        localparam MEM_S = DMA_E;
        localparam MEM_E = MEM_S + NO_MEMS;

        localparam LSBP_S = MEM_E;
        localparam LSBP_E = LSBP_S + NO_LSBPS;

        localparam LSIP_S = LSBP_E;
        localparam LSIP_E = LSIP_S + NO_LSIPS;

        if (LSDOM_E > LSDOM_S) begin
            adam_periph_syscfg_tgt #(
                `ADAM_CFG_PARAMS_MAP,

                .EN_BOOTSTRAP (0),
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

                .EN_BOOTSTRAP (0),
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

                .EN_BOOTSTRAP (0),
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

                .EN_BOOTSTRAP (0),
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

        if (FAB_LSBP_E > FAB_LSBP_S) begin
            adam_periph_syscfg_tgt #(
                `ADAM_CFG_PARAMS_MAP,

                .EN_BOOTSTRAP (0),
                .EN_BOOT_ADDR (0),
                .EN_IRQ       (0)
            ) tgt_fab_lsbp (
                .seq   (seq),
                .pause (tgt_pause[FAB_LSBP_S]),

                .slv (tgt_apb[FAB_LSBP_S]),

                .irq_vec (irq_vec),

                .tgt_rst       (fab_lsbp_rst),        
                .tgt_pause     (fab_lsbp_pause),
                .tgt_boot_addr (),
                .tgt_irq       ()
            ); 
        end 
        else begin
            assign fab_lsbp_rst = '1;
            `ADAM_PAUSE_MST_TIE_OFF(fab_lsbp_pause);
        end

        if (FAB_LSIP_E > FAB_LSIP_S) begin
            adam_periph_syscfg_tgt #(
                `ADAM_CFG_PARAMS_MAP,

                .EN_BOOTSTRAP (0),
                .EN_BOOT_ADDR (0),
                .EN_IRQ       (0)
            ) tgt_fab_lsip (
                .seq   (seq),
                .pause (tgt_pause[FAB_LSIP_S]),

                .slv (tgt_apb[FAB_LSIP_S]),

                .irq_vec (irq_vec),

                .tgt_rst       (fab_lsip_rst),        
                .tgt_pause     (fab_lsip_pause),
                .tgt_boot_addr (),
                .tgt_irq       ()
            );
        end
        else begin
            assign fab_lsip_rst = '1;
            `ADAM_PAUSE_MST_TIE_OFF(fab_lsip_pause);
        end

        if (FAB_HSBP_E > FAB_HSBP_S) begin
            adam_periph_syscfg_tgt #(
                `ADAM_CFG_PARAMS_MAP,

                .EN_BOOTSTRAP (0),
                .EN_BOOT_ADDR (0),
                .EN_IRQ       (0)
            ) tgt_fab_hsbp (
                .seq   (seq),
                .pause (tgt_pause[FAB_HSBP_S]),

                .slv (tgt_apb[FAB_HSBP_S]),

                .irq_vec (irq_vec),

                .tgt_rst       (fab_hsbp_rst),        
                .tgt_pause     (fab_hsbp_pause),
                .tgt_boot_addr (),
                .tgt_irq       ()
            );
        end
        else begin
            assign fab_hsbp_rst = '1;
            `ADAM_PAUSE_MST_TIE_OFF(fab_hsbp_pause);
        end

        if (FAB_HSIP_E > FAB_HSIP_S) begin
            adam_periph_syscfg_tgt #(
                `ADAM_CFG_PARAMS_MAP,

                .EN_BOOTSTRAP (0),
                .EN_BOOT_ADDR (0),
                .EN_IRQ       (0)
            ) tgt_fab_hsip (
                .seq   (seq),
                .pause (tgt_pause[FAB_HSIP_S]),

                .slv (tgt_apb[FAB_HSIP_S]),

                .irq_vec (irq_vec),

                .tgt_rst       (fab_hsip_rst),        
                .tgt_pause     (fab_hsip_pause),
                .tgt_boot_addr (),
                .tgt_irq       ()
            );
        end
        else begin
            assign fab_hsip_rst = '1;
            `ADAM_PAUSE_MST_TIE_OFF(fab_hsip_pause);
        end

        if (LPCPU_E > LPCPU_S) begin
            adam_periph_syscfg_tgt #(
                `ADAM_CFG_PARAMS_MAP,

                .EN_BOOTSTRAP (0),
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

                .EN_BOOTSTRAP (0),
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

                .EN_BOOTSTRAP (0),
                .EN_BOOT_ADDR (0),
                .EN_IRQ       (0)
            ) tgt_cpu (
                .seq   (seq),
                .pause (tgt_pause[i]),

                .slv (tgt_apb[i]),

                .irq_vec (irq_vec),

                .tgt_rst       (cpu_rst[i]),        
                .tgt_pause     (cpu_pause[i]),
                .tgt_boot_addr (cpu_boot_addr[i]),
                .tgt_irq       (cpu_irq[i])
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

                .tgt_rst       (dma_rst[i]),        
                .tgt_pause     (dma_pause[i]),
                .tgt_boot_addr (),
                .tgt_irq       (dma_irq[i])
            );
        end

        for (genvar i = MEM_S; i < MEM_E; i++) begin
            adam_periph_syscfg_tgt #(
                `ADAM_CFG_PARAMS_MAP,

                .EN_BOOTSTRAP (0),
                .EN_BOOT_ADDR (0),
                .EN_IRQ       (0)
            ) tgt_mem (
                .seq   (seq),
                .pause (tgt_mem_syscfg_pause),

                .slv (tgt_apb[i]),

                .irq_vec (irq_vec),

                .tgt_rst       (mem_rst[i]),        
                .tgt_pause     (mem_pause[i]),
                .tgt_boot_addr (),
                .tgt_irq       ()
            );
        end

        for (genvar i = LSBP_S; i < LSBP_E; i++) begin
            adam_periph_syscfg_tgt #(
                `ADAM_CFG_PARAMS_MAP,

                .EN_BOOTSTRAP (0),
                .EN_BOOT_ADDR (0),
                .EN_IRQ       (0)
            ) tgt_lsbp (
                .seq   (seq),
                .pause (tgt_pause[i]),

                .slv (tgt_apb[i]),

                .irq_vec (irq_vec),

                .tgt_rst       (lsbp_rst[i]),        
                .tgt_pause     (lsbp_pause[i]),
                .tgt_boot_addr (),
                .tgt_irq       ()
            );
        end

        for (genvar i = LSIP_S; i < LSIP_E; i++) begin
            adam_periph_syscfg_tgt #(
                `ADAM_CFG_PARAMS_MAP,

                .EN_BOOTSTRAP (0),
                .EN_BOOT_ADDR (0),
                .EN_IRQ       (0)
            ) tgt_lsip (
                .seq   (seq),
                .pause (tgt_pause[i]),

                .slv (tgt_apb[i]),

                .irq_vec (irq_vec),

                .tgt_rst       (lsip_rst[i]),        
                .tgt_pause     (lsip_pause[i]),
                .tgt_boot_addr (),
                .tgt_irq       ()
            );
        end

    endgenerate

endmodule