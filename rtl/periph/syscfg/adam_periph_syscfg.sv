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
    localparam NO_APBS = 4 + EN_LSBP + EN_LSIP + EN_HSBP +
        EN_HSIP + EN_LPCPU + EN_LPMEM + NO_CPUS + NO_DMAS + NO_MEMS +
        NO_LSBPS + NO_LSIPS;
    
    `ADAM_APB_I apbs [NO_APBS] ();

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
            ) lsdom_syscfg (
                .seq   (seq),
                .pause (pause),

                .slv (apbs[LSDOM_S]),

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
            ) hsdom_syscfg (
                .seq   (seq),
                .pause (pause),

                .slv (apbs[HSDOM_S]),

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
            ) fab_lsdom_syscfg (
                .seq   (seq),
                .pause (pause),

                .slv (apbs[FAB_LSDOM_S]),

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
            ) fab_hsdom_syscfg (
                .seq   (seq),
                .pause (pause),

                .slv (apbs[FAB_HSDOM_S]),

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
            ) fab_lsbp_syscfg (
                .seq   (seq),
                .pause (pause),

                .slv (apbs[FAB_LSBP_S]),

                .irq_vec (irq_vec),

                .tgt_rst       (fab_lsbp_rst),        
                .tgt_pause     (fab_lsbp_pause),
                .tgt_boot_addr (),
                .tgt_irq       ()
            ); 
        end 

        if (FAB_LSIP_E > FAB_LSIP_S) begin
            adam_periph_syscfg_tgt #(
                `ADAM_CFG_PARAMS_MAP,

                .EN_BOOTSTRAP (0),
                .EN_BOOT_ADDR (0),
                .EN_IRQ       (0)
            ) fab_lsip_syscfg (
                .seq   (seq),
                .pause (pause),

                .slv (apbs[FAB_LSIP_S]),

                .irq_vec (irq_vec),

                .tgt_rst       (fab_lsip_rst),        
                .tgt_pause     (fab_lsip_pause),
                .tgt_boot_addr (),
                .tgt_irq       ()
            );
        end

        if (FAB_HSBP_E > FAB_HSBP_S) begin
            adam_periph_syscfg_tgt #(
                `ADAM_CFG_PARAMS_MAP,

                .EN_BOOTSTRAP (0),
                .EN_BOOT_ADDR (0),
                .EN_IRQ       (0)
            ) fab_hsbp_syscfg (
                .seq   (seq),
                .pause (pause),

                .slv (apbs[FAB_HSBP_S]),

                .irq_vec (irq_vec),

                .tgt_rst       (fab_hsbp_rst),        
                .tgt_pause     (fab_hsbp_pause),
                .tgt_boot_addr (),
                .tgt_irq       ()
            );
        end

        if (FAB_HSIP_E > FAB_HSIP_S) begin
            adam_periph_syscfg_tgt #(
                `ADAM_CFG_PARAMS_MAP,

                .EN_BOOTSTRAP (0),
                .EN_BOOT_ADDR (0),
                .EN_IRQ       (0)
            ) fab_hsip_syscfg (
                .seq   (seq),
                .pause (pause),

                .slv (apbs[FAB_HSIP_S]),

                .irq_vec (irq_vec),

                .tgt_rst       (fab_hsip_rst),        
                .tgt_pause     (fab_hsip_pause),
                .tgt_boot_addr (),
                .tgt_irq       ()
            );
        end

        if (LPCPU_E > LPCPU_S) begin
            adam_periph_syscfg_tgt #(
                `ADAM_CFG_PARAMS_MAP,

                .EN_BOOTSTRAP (0),
                .EN_BOOT_ADDR (1),
                .EN_IRQ       (1)
            ) lpcpu_syscfg (
                .seq   (seq),
                .pause (pause),

                .slv (apbs[LPCPU_S]),

                .irq_vec (irq_vec),

                .tgt_rst       (lpcpu_rst),        
                .tgt_pause     (lpcpu_pause),
                .tgt_boot_addr (lpcpu_boot_addr),
                .tgt_irq       (lpcpu_irq)
            );
        end

        if (LPMEM_E > LPMEM_S) begin
            adam_periph_syscfg_tgt #(
                `ADAM_CFG_PARAMS_MAP,

                .EN_BOOTSTRAP (0),
                .EN_BOOT_ADDR (0),
                .EN_IRQ       (0)
            ) lpmem_syscfg (
                .seq   (seq),
                .pause (pause),

                .slv (apbs[LPMEM_S]),

                .irq_vec (irq_vec),

                .tgt_rst       (lpmem_rst),        
                .tgt_pause     (lpmem_pause),
                .tgt_boot_addr (),
                .tgt_irq       ()
            );
        end

        for (genvar i = CPU_S; i < CPU_E; i++) begin
            adam_periph_syscfg_tgt #(
                `ADAM_CFG_PARAMS_MAP,

                .EN_BOOTSTRAP (0),
                .EN_BOOT_ADDR (0),
                .EN_IRQ       (0)
            ) cpu_syscfg (
                .seq   (seq),
                .pause (pause),

                .slv (apbs[i]),

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
            ) dma_syscfg (
                .seq   (seq),
                .pause (pause),

                .slv (apbs[i]),

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
            ) mem_syscfg (
                .seq   (seq),
                .pause (pause),

                .slv (apbs[i]),

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
            ) lsbp_syscfg (
                .seq   (seq),
                .pause (pause),

                .slv (apbs[i]),

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
            ) lsip_syscfg (
                .seq   (seq),
                .pause (pause),

                .slv (apbs[i]),

                .irq_vec (irq_vec),

                .tgt_rst       (lsip_rst[i]),        
                .tgt_pause     (lsip_pause[i]),
                .tgt_boot_addr (),
                .tgt_irq       ()
            );
        end

    endgenerate

endmodule