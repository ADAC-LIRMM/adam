`include "adam/macros.svh"
`include "axi/assign.svh"

module adam_fabric_hsdom #(
    `ADAM_CFG_PARAMS
) (
    ADAM_SEQ.Slave   seq,
    ADAM_PAUSE.Slave pause,

    AXI_LITE.Slave cpu [2*NO_CPUS+1],
    AXI_LITE.Slave dma [NO_DMAS+1],
    AXI_LITE.Slave debug_slv,
    AXI_LITE.Slave from_lsdom,

    AXI_LITE.Master mem [NO_MEMS+1],
    AXI_LITE.Master hsp [NO_HSPS+1],
    AXI_LITE.Master debug_mst,
    AXI_LITE.Master to_lsdom
);

    localparam NO_SLVS = 2*NO_CPUS + NO_DMAS + EN_DEBUG + 1;
    localparam NO_MSTS = NO_MEMS + NO_HSPS + EN_DEBUG + 1;

    localparam type RULE_T = adam_cfg_pkg::MMAP_T;

    `ADAM_AXIL_I slvs [NO_SLVS+1] ();
    `ADAM_AXIL_I msts [NO_MSTS+1] ();
    
    RULE_T addr_map [NO_MSTS+1];
    
    // Slave Mapping
    generate 
        localparam CPUS_S = 0;
        localparam CPUS_E = CPUS_S + 2*NO_CPUS;

        localparam DMAS_S = CPUS_E;
        localparam DMAS_E = DMAS_S + NO_DMAS;

        localparam DEBUG_SLV_S = DMAS_E;
        localparam DEBUG_SLV_E = DEBUG_SLV_S + EN_DEBUG;

        localparam FROM_LSDOM_S = DEBUG_SLV_E;
        localparam FROM_LSDOM_E = FROM_LSDOM_S + 1;

        // Cores
        for (genvar i = CPUS_S; i < CPUS_E; i++) begin
            `AXI_LITE_ASSIGN(slvs[i], cpu[i-CPUS_S]);
        end

        // DMAs
        for (genvar i = DMAS_S; i < DMAS_E; i++) begin
            `AXI_LITE_ASSIGN(slvs[i], dma[i-DMAS_S]);
        end

        // Debug
        for (genvar i = DEBUG_SLV_S; i < DEBUG_SLV_E; i++) begin
            `AXI_LITE_ASSIGN(slvs[i], debug_slv);
        end
        if (!EN_DEBUG) begin
            `ADAM_AXIL_SLV_TIE_OFF(debug_slv);
        end

        // From Low Speed Domain (LSDOM)
        for (genvar i = FROM_LSDOM_S; i < FROM_LSDOM_E; i++) begin
            `AXI_LITE_ASSIGN(slvs[i], from_lsdom);
        end
    endgenerate

    // Master Mapping
    generate
        localparam MEMS_S = 0;
        localparam MEMS_E = MEMS_S + NO_MEMS;

        localparam HSP_S = MEMS_E;
        localparam HSP_E = HSP_S + NO_HSPS;

        localparam DEBUG_MST_S = HSP_E;
        localparam DEBUG_MST_E = DEBUG_MST_S + EN_DEBUG;

        localparam TO_LSDOM_S = DEBUG_MST_E;
        localparam TO_LSDOM_E = TO_LSDOM_S + 1;

        // Memories
        for (genvar i = MEMS_S; i < MEMS_E; i++) begin
            assign addr_map[i] = '{
                start: MMAP_MEM.start + MMAP_MEM.inc*(i-MEMS_S),
                end_:  MMAP_MEM.start + MMAP_MEM.inc*(i-MEMS_S+1)
            };
            `ADAM_AXIL_OFFSET(mem[i-MEMS_S], msts[i], addr_map[i].start);
        end

        // High Speed Intermittent Peripherals (HSP)
        for (genvar i = HSP_S; i < HSP_E; i++) begin
            assign addr_map[i] = '{
                start: MMAP_HSP.start + MMAP_HSP.inc*(i-HSP_S),
                end_:  MMAP_HSP.start + MMAP_HSP.inc*(i-HSP_S+1)
            };
            `ADAM_AXIL_OFFSET(hsp[i-HSP_S], msts[i], addr_map[i].start);
        end

        // Debug
        for (genvar i = DEBUG_MST_S; i < DEBUG_MST_E; i++) begin
            assign addr_map[i] = MMAP_DEBUG;
            `ADAM_AXIL_OFFSET(debug_mst, msts[i], addr_map[i].start);
        end
        if (!EN_DEBUG) begin
            `ADAM_AXIL_MST_TIE_OFF(debug_mst);
        end

        // To Low Speed Domain (LSDOM)
        for (genvar i = TO_LSDOM_S; i < TO_LSDOM_E; i++) begin
            assign addr_map[i] = '{
                start: '0,
                end_:  ADDR_BOUNDRY
            };
            `AXI_LITE_ASSIGN(to_lsdom, msts[i]);
        end
    endgenerate

    adam_axil_xbar #(
        `ADAM_CFG_PARAMS_MAP,

        .NO_SLVS (NO_SLVS),
        .NO_MSTS (NO_MSTS),
        
        .MAX_TRANS (FAB_MAX_TRANS),

        .RULE_T (RULE_T)
    ) adam_axil_xbar (
        .seq   (seq),
        .pause (pause),

        .slv (slvs),
        .mst (msts),

        .addr_map (addr_map)
    );

endmodule