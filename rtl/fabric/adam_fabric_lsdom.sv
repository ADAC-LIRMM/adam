`include "adam/macros.svh"
`include "axi/assign.svh"

module adam_fabric_lsdom #(
    `ADAM_CFG_PARAMS  
) (
    ADAM_SEQ.Slave   seq,
    ADAM_PAUSE.Slave pause,

    AXI_LITE.Slave lpcpu [2],
    AXI_LITE.Slave from_hsdom,

    AXI_LITE.Master lpmem,
    AXI_LITE.Master syscfg,
    AXI_LITE.Master lspa,
    AXI_LITE.Master lspb,
    AXI_LITE.Master to_hsdom
);

    localparam NO_SLVS = 2*EN_LPCPU + 1;
    localparam NO_MSTS = EN_LPMEM + EN_LSPA + EN_LSPB + 2;

    localparam type RULE_T = adam_cfg_pkg::MMAP_T;

    `ADAM_AXIL_I slv [NO_SLVS+1] ();
    `ADAM_AXIL_I mst [NO_MSTS+1] ();
    
    RULE_T addr_map [NO_MSTS+1] ;
    
    // Slave Mapping
    generate 
        localparam LPCPU_S = 0;
        localparam LPCPU_E = LPCPU_S + 2*EN_LPCPU;

        localparam FROM_HSDOM_S = LPCPU_E;
        localparam FROM_HSDOM_E = FROM_HSDOM_S + 1;

        // LPCPUs
        for (genvar i = LPCPU_S; i < LPCPU_E; i++) begin
            `AXI_LITE_ASSIGN(slv[i], lpcpu[i-LPCPU_S]);
        end
        if (!EN_LPCPU) begin
            `ADAM_AXIL_SLV_TIE_OFF(lpcpu[0]);
            `ADAM_AXIL_SLV_TIE_OFF(lpcpu[1]);
        end

        // From High Speed Domain (HSDOM)
        for (genvar i = FROM_HSDOM_S; i < FROM_HSDOM_E; i++) begin
            `AXI_LITE_ASSIGN(slv[i], from_hsdom);
        end
    endgenerate

    // Master Mapping
    generate
        localparam LPMEM_S = 0;
        localparam LPMEM_E = LPMEM_S + EN_LPMEM;

        localparam SYSCFG_S = LPMEM_E;
        localparam SYSCFG_E = SYSCFG_S + 1;

        localparam LSPA_S = SYSCFG_E;
        localparam LSPA_E = LSPA_S + EN_LSPA;

        localparam LSPB_S = LSPA_E;
        localparam LSPB_E = LSPB_S + EN_LSPB;

        localparam TO_HSDOM_S = LSPB_E;
        localparam TO_HSDOM_E = TO_HSDOM_S + 1;

        // Memory
        for (genvar i = LPMEM_S; i < LPMEM_E; i++) begin
            assign addr_map[i] = '{
                start : MMAP_LPMEM.start,
                end_  : MMAP_LPMEM.end_
            };
            `ADAM_AXIL_OFFSET(lpmem, mst[i], addr_map[i].start);
        end
        if (!EN_LPMEM) begin
            `ADAM_AXIL_MST_TIE_OFF(lpmem);
        end

        // SYSCFG
        for (genvar i = SYSCFG_S; i < SYSCFG_E; i++) begin
            assign addr_map[i] = '{
                start : MMAP_SYSCFG.start,
                end_  : MMAP_SYSCFG.end_
            };
            `ADAM_AXIL_OFFSET(syscfg, mst[i], addr_map[i].start);
        end

        // Low Speed Base Peripherals (LSPA)
        for (genvar i = LSPA_S; i < LSPA_E; i++) begin
            assign addr_map[i] = '{
                start : MMAP_LSPA.start,
                end_  : MMAP_LSPA.end_
            };
            `ADAM_AXIL_OFFSET(lspa, mst[i], addr_map[i].start);
        end
        if (!EN_LSPA) begin
            `ADAM_AXIL_MST_TIE_OFF(lspa);
        end

        // Low Speed Intermittent Peripherals (LSPB)
        for (genvar i = LSPB_S; i < LSPB_E; i++) begin
            assign addr_map[i] = '{
                start : MMAP_LSPB.start,
                end_  : MMAP_LSPB.end_
            };
            `ADAM_AXIL_OFFSET(lspb, mst[i], addr_map[i].start);
        end
        if (!EN_LSPB) begin
            `ADAM_AXIL_MST_TIE_OFF(lspb);
        end

        // To High Speed Domain (HSDOM)
        for (genvar i = TO_HSDOM_S; i < TO_HSDOM_E; i++) begin
            assign addr_map[i] = '{
                start : ADDR_BOUNDRY,
                end_  : '0 // unbounded
            };
            `AXI_LITE_ASSIGN(to_hsdom, mst[i]);
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

        .slv (slv),
        .mst (mst),

        .addr_map (addr_map)
    );

endmodule
