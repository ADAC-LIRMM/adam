`include "adam/macros.svh"
`include "axi/assign.svh"

module adam_fabric #(
    `ADAM_CFG_PARAMS
) (
    // lsdom ==================================================================
    
    ADAM_SEQ.Slave   lsdom_seq,
    ADAM_PAUSE.Slave lsdom_pause,
    ADAM_PAUSE.Slave lsdom_pause_lspa,
    ADAM_PAUSE.Slave lsdom_pause_lspb,

    AXI_LITE.Slave lsdom_lpcpu [2],

    AXI_LITE.Master lsdom_lpmem,
    AXI_LITE.Master lsdom_syscfg,
    APB.Master      lsdom_lspa [NO_LSPAS+1],
    APB.Master      lsdom_lspb [NO_LSPBS+1],

    // hsdom ==================================================================
    
    ADAM_SEQ.Slave   hsdom_seq,
    ADAM_PAUSE.Slave hsdom_pause,

    AXI_LITE.Slave hsdom_cpu [2*NO_CPUS+1],
    AXI_LITE.Slave hsdom_dma [NO_DMAS+1],
    AXI_LITE.Slave hsdom_debug_slv,

    AXI_LITE.Master hsdom_mem [NO_MEMS+1],
    AXI_LITE.Master hsdom_hsp [NO_HSPS+1],
    AXI_LITE.Master hsdom_debug_mst
);

    // lsdom ==================================================================

    `ADAM_AXIL_I lsdom_from_hsdom ();
    `ADAM_AXIL_I lsdom_to_hsdom ();

    `ADAM_AXIL_I lsdom_to_lspa ();
    `ADAM_AXIL_I lsdom_to_lspb ();
    
    adam_fabric_lsdom #(
        `ADAM_CFG_PARAMS_MAP
    ) adam_fabric_lsdom (
        .seq   (lsdom_seq),
        .pause (lsdom_pause),

        .lpcpu      (lsdom_lpcpu),
        .from_hsdom (lsdom_from_hsdom),

        .lpmem    (lsdom_lpmem),
        .syscfg   (lsdom_syscfg),
        .lspa     (lsdom_to_lspa),
        .lspb     (lsdom_to_lspb),
        .to_hsdom (lsdom_to_hsdom)
    );

    generate
        if (EN_LSPA) begin
            adam_fabric_lspx #(
                `ADAM_CFG_PARAMS_MAP,

                .NO_MSTS (NO_LSPAS),
                .INC     (MMAP_LSPA.inc)
            ) adam_fabric_lspa (
                .seq   (lsdom_seq),
                .pause (lsdom_pause_lspa),

                .slv (lsdom_to_lspa),
                .mst (lsdom_lspa)
            );
        end
        else begin
            `ADAM_PAUSE_SLV_TIE_OFF(lsdom_pause_lspa);
            `ADAM_AXIL_SLV_TIE_OFF(lsdom_to_lspa);
        end

        if (EN_LSPB) begin
            adam_fabric_lspx #(
                `ADAM_CFG_PARAMS_MAP,

                .NO_MSTS (NO_LSPBS),
                .INC     (MMAP_LSPB.inc)
            ) adam_fabric_lspb (
                .seq   (lsdom_seq),
                .pause (lsdom_pause_lspb),

                .slv (lsdom_to_lspb),
                .mst (lsdom_lspb)
            );
        end
        else begin
            `ADAM_PAUSE_SLV_TIE_OFF(lsdom_pause_lspb);
            `ADAM_AXIL_SLV_TIE_OFF(lsdom_to_lspb);
        end
    endgenerate

    // hsdom ==================================================================

    `ADAM_AXIL_I hsdom_from_lsdom ();
    `ADAM_AXIL_I hsdom_to_lsdom ();

    adam_fabric_hsdom #(
        `ADAM_CFG_PARAMS_MAP
    ) adam_fabric_hsdom (
        .seq   (hsdom_seq),
        .pause (hsdom_pause),

        .cpu        (hsdom_cpu),
        .dma        (hsdom_dma),
        .debug_slv  (hsdom_debug_slv),
        .from_lsdom (hsdom_from_lsdom),

        .mem       (hsdom_mem),
        .hsp       (hsdom_hsp),
        .debug_mst (hsdom_debug_mst),
        .to_lsdom  (hsdom_to_lsdom)
    );

    // cdc ====================================================================

    // placeholder
    `AXI_LITE_ASSIGN (lsdom_from_hsdom, hsdom_to_lsdom);
    `AXI_LITE_ASSIGN (hsdom_from_lsdom, lsdom_to_hsdom);

endmodule
