`include "axi/assign.svh"

`define AXIL_I AXI_LITE #( \
    .AXI_ADDR_WIDTH (ADDR_WIDTH), \
    .AXI_DATA_WIDTH (DATA_WIDTH) \
)

module adam_fabric_lsdom #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32,

    parameter MAX_TRANS = 7,

    parameter EN_LPU  = 1,
    parameter EN_MEM  = 1,
    parameter EN_LSBP = 1,
    parameter EN_LSIP = 1,

    // Dependent parameters below, do not override.

    parameter STRB_WIDTH  = DATA_WIDTH/8,

    parameter type addr_t = logic [ADDR_WIDTH-1:0],
    parameter type data_t = logic [DATA_WIDTH-1:0],
    parameter type strb_t = logic [STRB_WIDTH-1:0]    
) (
    input logic clk,
    input logic rst,
 
    input  logic pause_req,
    output logic pause_ack,

    AXI_LITE.Slave lpu [2],
    AXI_LITE.Slave from_hsdom,

    AXI_LITE.Master mem,
    AXI_LITE.Master syscfg,
    AXI_LITE.Master lsbp,
    AXI_LITE.Master lsip,
    AXI_LITE.Master to_hsdom
);

    localparam NO_SLVS = 2*EN_LPU + 1;
    localparam NO_MSTS = EN_MEM + EN_LSBP + EN_LSIP + 2;

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
        localparam LPU_S = 0;
        localparam LPU_E = LPU_S + 2*EN_LPU;

        localparam FROM_HSDOM_S = LPU_E;
        localparam FROM_HSDOM_E = FROM_HSDOM_S + 1;

        // LPUs
        for (genvar i = LPU_S; i < LPU_E; i++) begin
            `AXI_LITE_ASSIGN(slvs[i], lpu[i-LPU_S]);
        end
        if (!EN_LPU) begin
            `AXI_LITE_SLAVE_TIE_OFF(slvs[0]);
            `AXI_LITE_SLAVE_TIE_OFF(slvs[1]);
        end

        // From High Speed Domain (HSDOM)
        for (genvar i = FROM_HSDOM_S; i < FROM_HSDOM_E; i++) begin
            `AXI_LITE_ASSIGN(slvs[i], from_hsdom);
        end
    endgenerate

    // Master Mapping
    generate
        localparam MEM_S = 0;
        localparam MEM_E = MEM_S + EN_MEM;

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
            `AXI_LITE_OFFSET(mem, msts[i], addr_map[i].start_addr);
        end
        if (!EN_MEM) begin
            `AXI_LITE_MASTER_TIE_OFF(mem);
        end

        // SYSCFG
        for (genvar i = SYSCFG_S; i < SYSCFG_E; i++) begin
            assign addr_map[i] = '{
                idx: i,
                start_addr: 32'h0000_8000,
                end_addr:   32'h0000_8400
            };
            `AXI_LITE_OFFSET(syscfg, msts[i], addr_map[i].start_addr);
        end

        // Low Speed Base Peripherals (LSBP)
        for (genvar i = LSBP_S; i < LSBP_E; i++) begin
            assign addr_map[i] = '{
                idx: i,
                start_addr: 32'h0001_0000,
                end_addr:   32'h0001_8000
            };
            `AXI_LITE_OFFSET(lsbp, msts[i], addr_map[i].start_addr);
        end
        if (!EN_LSBP) begin
            `AXI_LITE_MASTER_TIE_OFF(lsbp);
        end

        // Low Speed Intermittent Peripherals (LSIP)
        for (genvar i = LSIP_S; i < LSIP_E; i++) begin
            assign addr_map[i] = '{
                idx: i,
                start_addr: 32'h0001_8000,
                end_addr:   32'h0002_0000
            };
            `AXI_LITE_OFFSET(lsip, msts[i], addr_map[i].start_addr);
        end
        if (!EN_LSIP) begin
            `AXI_LITE_MASTER_TIE_OFF(lsip);
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
        .clk  (clk),
        .rst  (rst),
        
        .pause_req (pause_req),
		.pause_ack (pause_ack),

        .axil_slvs (slvs),
        .axil_msts (msts),

        .addr_map (addr_map)
    );

endmodule
