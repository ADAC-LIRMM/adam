`include "adam/macros.svh"
`include "axi/assign.svh"

`define AXIL_I AXI_LITE #( \
    .AXI_ADDR_WIDTH (ADDR_WIDTH), \
    .AXI_DATA_WIDTH (DATA_WIDTH) \
)

module adam_fabric_lsdom #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32,

    parameter MAX_TRANS = 7,

    parameter EN_LPCPU  = 1,
    parameter EN_LPMEM  = 1,
    parameter EN_LSBP   = 1,
    parameter EN_LSIP   = 1,

    // Dependent parameters below, do not override.

    parameter STRB_WIDTH  = DATA_WIDTH/8,

    parameter type addr_t = logic [ADDR_WIDTH-1:0],
    parameter type data_t = logic [DATA_WIDTH-1:0],
    parameter type strb_t = logic [STRB_WIDTH-1:0]    
) (
    ADAM_SEQ.Slave   seq,
    ADAM_PAUSE.Slave pause,

    AXI_LITE.Slave lpcpu [2],
    AXI_LITE.Slave from_hsdom,

    AXI_LITE.Master lpmem,
    AXI_LITE.Master syscfg,
    AXI_LITE.Master lsbp,
    AXI_LITE.Master lsip,
    AXI_LITE.Master to_hsdom
);

    localparam NO_SLVS = 2*EN_LPCPU + 1;
    localparam NO_MSTS = EN_LPMEM + EN_LSBP + EN_LSIP + 2;

    typedef struct packed {
        int unsigned idx;
        addr_t start_addr;
        addr_t end_addr;
    } rule_t;

    `AXIL_I slvs [NO_SLVS] ();
    `AXIL_I msts [NO_MSTS] ();
    
    rule_t [NO_MSTS-1:0] addr_map;
    
    // Slave Mapping
    generate 
        localparam LPCPU_S = 0;
        localparam LPCPU_E = LPCPU_S + 2*EN_LPCPU;

        localparam FROM_HSDOM_S = LPCPU_E;
        localparam FROM_HSDOM_E = FROM_HSDOM_S + 1;

        // LPCPUs
        for (genvar i = LPCPU_S; i < LPCPU_E; i++) begin
            `AXI_LITE_ASSIGN(slvs[i], lpcpu[i-LPCPU_S]);
        end
        if (!EN_LPCPU) begin
            `ADAM_AXIL_SLV_TIE_OFF(slvs[0]);
            `ADAM_AXIL_SLV_TIE_OFF(slvs[1]);
        end

        // From High Speed Domain (HSDOM)
        for (genvar i = FROM_HSDOM_S; i < FROM_HSDOM_E; i++) begin
            `AXI_LITE_ASSIGN(slvs[i], from_hsdom);
        end
    endgenerate

    // Master Mapping
    generate
        localparam MEM_S = 0;
        localparam MEM_E = MEM_S + EN_LPMEM;

        localparam SYSCFG_S = MEM_E;
        localparam SYSCFG_E = SYSCFG_S + 1;

        localparam LSBP_S = SYSCFG_E;
        localparam LSBP_E = LSBP_S + EN_LSBP;

        localparam LSIP_S = LSBP_E;
        localparam LSIP_E = LSIP_S + EN_LSIP;

        localparam TO_HSDOM_S = LSIP_E;
        localparam TO_HSDOM_E = TO_HSDOM_S + 1;

        // Memory
        for (genvar i = MEM_S; i < MEM_E; i++) begin
            assign addr_map[i] = '{
                idx: i,
                start_addr: 32'h0000_0000,
                end_addr:   32'h0000_8000
            };
            `ADAM_AXIL_OFFSET(lpmem, msts[i], addr_map[i].start_addr);
        end
        if (!EN_LPMEM) begin
            `ADAM_AXIL_MST_TIE_OFF(lpmem);
        end

        // SYSCFG
        for (genvar i = SYSCFG_S; i < SYSCFG_E; i++) begin
            assign addr_map[i] = '{
                idx: i,
                start_addr: 32'h0000_8000,
                end_addr:   32'h0000_8400
            };
            `ADAM_AXIL_OFFSET(syscfg, msts[i], addr_map[i].start_addr);
        end

        // Low Speed Base Peripherals (LSBP)
        for (genvar i = LSBP_S; i < LSBP_E; i++) begin
            assign addr_map[i] = '{
                idx: i,
                start_addr: 32'h0001_0000,
                end_addr:   32'h0001_8000
            };
            `ADAM_AXIL_OFFSET(lsbp, msts[i], addr_map[i].start_addr);
        end
        if (!EN_LSBP) begin
            `ADAM_AXIL_MST_TIE_OFF(lsbp);
        end

        // Low Speed Intermittent Peripherals (LSIP)
        for (genvar i = LSIP_S; i < LSIP_E; i++) begin
            assign addr_map[i] = '{
                idx: i,
                start_addr: 32'h0001_8000,
                end_addr:   32'h0002_0000
            };
            `ADAM_AXIL_OFFSET(lsip, msts[i], addr_map[i].start_addr);
        end
        if (!EN_LSIP) begin
            `ADAM_AXIL_MST_TIE_OFF(lsip);
        end

        // To High Speed Domain (HSDOM)
        for (genvar i = TO_HSDOM_S; i < TO_HSDOM_E; i++) begin
            assign addr_map[i] = '{
                idx: i,
                start_addr: 32'h0008_0000,
                end_addr:   '0 // unbounded
            };
            `AXI_LITE_ASSIGN(to_hsdom, msts[i]);
        end
    endgenerate

    adam_axil_xbar #(
        .ADDR_WIDTH (ADDR_WIDTH),
        .DATA_WIDTH (DATA_WIDTH),

        .NO_SLVS (NO_SLVS),
        .NO_MSTS (NO_MSTS),
        
        .MAX_TRANS (MAX_TRANS),

        .rule_t (rule_t)
    ) adam_axil_xbar (
        .seq   (seq),
        .pause (pause),

        .axil_slvs (slvs),
        .axil_msts (msts),

        .addr_map (addr_map)
    );

endmodule
