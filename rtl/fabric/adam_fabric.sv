`include "adam/macros.svh"
`include "axi/assign.svh"

`define AXIL_I AXI_LITE #( \
    .AXI_ADDR_WIDTH (ADDR_WIDTH), \
    .AXI_DATA_WIDTH (DATA_WIDTH) \
)

module adam_fabric #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32,

    parameter MAX_TRANS = 7,

    parameter NO_CPUS = 2,
    parameter NO_DMAS = 2,
    parameter NO_MEMS = 2,
    parameter NO_HSP = 2,
    parameter NO_LSPA = 2,
    parameter NO_LSPB = 2,

    parameter EN_LPCPU = 1,
    parameter EN_LPMEM = 1,
    parameter EN_DEBUG = 1,

    // Dependent parameters bellow, do not override.

    parameter STRB_WIDTH  = DATA_WIDTH/8,

    parameter type addr_t = logic [ADDR_WIDTH-1:0],
    parameter type data_t = logic [DATA_WIDTH-1:0],
    parameter type strb_t = logic [STRB_WIDTH-1:0]
) (
    // lsdom ==================================================================
    
    ADAM_SEQ.Slave   lsdom_seq,
    ADAM_PAUSE.Slave lsdom_pause,
    ADAM_PAUSE.Slave lsdom_pause_lspa,
    ADAM_PAUSE.Slave lsdom_pause_lspb,

    AXI_LITE.Slave lsdom_lpcpu [2],

    AXI_LITE.Master lsdom_lpmem,
    AXI_LITE.Master lsdom_syscfg,
    AXI_LITE.Master lsdom_lspa [NO_LSPA],
    AXI_LITE.Master lsdom_lspb [NO_LSPB],

    // hsdom ==================================================================
    
    ADAM_SEQ.Slave   hsdom_seq,
    ADAM_PAUSE.Slave hsdom_pause,

    AXI_LITE.Slave hsdom_cpus [2*NO_CPUS],
    AXI_LITE.Slave hsdom_dmas [NO_DMAS],
    AXI_LITE.Slave hsdom_debug_slv,

    AXI_LITE.Master hsdom_mems [NO_MEMS],
    AXI_LITE.Master hsdom_hsp [NO_HSP],
    AXI_LITE.Master hsdom_debug_mst
);

    // lsdom ==================================================================

    `AXIL_I lsdom_from_hsdom ();
    `AXIL_I lsdom_to_hsdom ();

    `AXIL_I lsdom_to_lspa ();
    `AXIL_I lsdom_to_lspb ();
    
    adam_fabric_lsdom #(
        .ADDR_WIDTH (ADDR_WIDTH),
        .DATA_WIDTH (DATA_WIDTH),

        .MAX_TRANS  (MAX_TRANS),

        .EN_LPCPU (EN_LPCPU),
        .EN_LPMEM (EN_LPMEM),
        .EN_LSPA  (NO_LSPA > 0),
        .EN_LSPB  (NO_LSPB > 0)
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
        if (NO_LSPA > 0) begin
            adam_fabric_lspx #(
                .ADDR_WIDTH (ADDR_WIDTH),
                .DATA_WIDTH (DATA_WIDTH),

                .NO_MSTS (NO_LSPA)
            ) adam_fabric_lspa (
                .seq   (lsdom_seq),
                .pause (lsdom_pause_lspa),

                .slv  (lsdom_to_lspa),
                .msts (lsdom_lspa)
            );
        end
        else begin
            `ADAM_PAUSE_SLV_TIE_OFF(lsdom_pause_lspa);
            `ADAM_AXIL_SLV_TIE_OFF(lsdom_to_lspa);
        end

        if (NO_LSPB > 0) begin
            adam_fabric_lspx #(
                .ADDR_WIDTH (ADDR_WIDTH),
                .DATA_WIDTH (DATA_WIDTH),

                .NO_MSTS (NO_LSPB)
            ) adam_fabric_lspb (
                .seq   (lsdom_seq),
                .pause (lsdom_pause_lspb),

                .slv  (lsdom_to_lspb),
                .msts (lsdom_lspb)
            );
        end
        else begin
            `ADAM_PAUSE_SLV_TIE_OFF(lsdom_pause_lspb);
            `ADAM_AXIL_SLV_TIE_OFF(lsdom_to_lspb);
        end
    endgenerate

    // hsdom ==================================================================

    `AXIL_I hsdom_from_lsdom ();
    `AXIL_I hsdom_to_lsdom ();

    adam_fabric_hsdom #(
        .ADDR_WIDTH (ADDR_WIDTH),
        .DATA_WIDTH (DATA_WIDTH),
        
        .MAX_TRANS (MAX_TRANS),

        .NO_CPUS (NO_CPUS),
        .NO_DMAS (NO_DMAS),
        .NO_MEMS (NO_MEMS),
        .NO_HSP (NO_HSP),

        .EN_DEBUG (EN_DEBUG)
    ) adam_fabric_hsdom (
        .seq   (hsdom_seq),
        .pause (hsdom_pause),

        .cpus       (hsdom_cpus),
        .dmas       (hsdom_dmas),
        .debug_slv  (hsdom_debug_slv),
        .from_lsdom (hsdom_from_lsdom),

        .mems      (hsdom_mems),
        .hsp      (hsdom_hsp),
        .debug_mst (hsdom_debug_mst),
        .to_lsdom  (hsdom_to_lsdom)
    );

    // cdc ====================================================================

    // placeholder
    `AXI_LITE_ASSIGN (lsdom_from_hsdom, hsdom_to_lsdom);
    `AXI_LITE_ASSIGN (hsdom_from_lsdom, lsdom_to_hsdom);

endmodule
