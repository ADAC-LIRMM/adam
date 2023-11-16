`include "axi/assign.svh"

`define AXIL_I AXI_LITE #( \
    .AXI_ADDR_WIDTH (ADDR_WIDTH), \
    .AXI_DATA_WIDTH (DATA_WIDTH) \
)

module adam_fabric_hsdom #(
	parameter ADDR_WIDTH = 32,
	parameter DATA_WIDTH = 32,

    parameter MAX_TRANS = 7,

    parameter NO_CPUS = 2,
    parameter NO_DMAS = 2,
    parameter NO_MEMS = 2,
    parameter NO_HSIP = 2,

    parameter EN_DEBUG = 1,

    // Dependent parameters bellow, do not override.

    parameter STRB_WIDTH  = DATA_WIDTH/8,

    parameter type addr_t = logic [ADDR_WIDTH-1:0],
    parameter type data_t = logic [DATA_WIDTH-1:0],
    parameter type strb_t = logic [STRB_WIDTH-1:0]    
) (
    input logic clk,
	input logic rst,
 
	input  logic pause_req,
	output logic pause_ack,

    AXI_LITE.Slave cpus [2*NO_CPUS],
    AXI_LITE.Slave dmas [NO_DMAS],
    AXI_LITE.Slave debug_slv,
    AXI_LITE.Slave from_lsdom,

    AXI_LITE.Master mems [NO_MEMS],
    AXI_LITE.Master hsip [NO_HSIP],
    AXI_LITE.Master debug_mst,
    AXI_LITE.Master to_lsdom
);
    localparam NO_SLVS = NO_CPUS + NO_DMAS + EN_DEBUG + 1;
    localparam NO_MSTS = NO_MEMS + NO_HSIP + 1;

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
        localparam CPUS_S = 0;
		localparam CPUS_E = CPUS_S + 2*NO_CPUS;

        localparam DMAS_S = CPUS_E;
        localparam DMAS_E = DMAS_S + 2*NO_DMAS;

        localparam DEBUG_SLV_S = DMAS_E;
        localparam DEBUG_SLV_E = DEBUG_SLV_S + EN_DEBUG;

        localparam FROM_LSDOM_S = DEBUG_SLV_E;
        localparam FROM_LSDOM_E = FROM_LSDOM_S + 1;

        // Cores
		for (genvar i = CPUS_S; i < CPUS_E; i++) begin
			`AXI_LITE_ASSIGN(slvs[i], cpus[i-CPUS_S]);
		end

        // DMAs
        for (genvar i = DMAS_S; i < DMAS_E; i++) begin
			`AXI_LITE_ASSIGN(slvs[i], dmas[i-DMAS_S]);
		end

        // Debug
        for (genvar i = DEBUG_SLV_S; i < DEBUG_SLV_E; i++) begin
            `AXI_LITE_ASSIGN(slvs[i], debug_slv);
        end
        if (!EN_DEBUG) begin
            `AXI_LITE_SLAVE_TIE_OFF(debug_slv);
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

        localparam HSIP_S = MEMS_E;
        localparam HSIP_E = HSIP_S + NO_HSIP;

        localparam DEBUG_MST_S = HSIP_E;
        localparam DEBUG_MST_E = DEBUG_MST_S + EN_DEBUG;

        localparam TO_LSDOM_S = DEBUG_MST_E;
        localparam TO_LSDOM_E = TO_LSDOM_S + 1;

        // Memories
        for (genvar i = MEMS_S; i < MEMS_E; i++) begin
            assign addr_map[i] = '{
                idx: i,
                start_addr: 32'h0100_0000 + 32'h0100_0000*(i-MEMS_S),
                end_addr:   32'h0100_0000 + 32'h0100_0000*(i-MEMS_S+1)
            };
            `AXI_LITE_OFFSET(mems[i-MEMS_S], msts[i], addr_map[i]);
        end

        // High Speed Intermittent Peripherals (HSIP)
        for (genvar i = HSIP_S; i < HSIP_E; i++) begin
            assign addr_map[i] = '{
                idx: i,
                start_addr: 32'h0009_0000 + 32'h0000_0400*(i-HSIP_S),
                end_addr:   32'h0009_0000 + 32'h0000_0400*(i-HSIP_E+1)
            };
            `AXI_LITE_OFFSET(hsip[i-HSIP_S], msts[i], addr_map[i]);
        end

        // Debug
        for (genvar i = DEBUG_MST_S; i < DEBUG_MST_E; i++) begin
            assign addr_map[i] = '{
                idx: i,
                start_addr: 32'h0000_8000,
                end_addr:   32'h0000_8400
            };
            `AXI_LITE_OFFSET(debug_mst, msts[i], addr_map[i]);
        end
        if (!EN_DEBUG) begin
            `AXI_LITE_MASTER_TIE_OFF(debug_mst);
        end

        // To Low Speed Domain (LSDOM)
        for (genvar i = TO_LSDOM_S; i < TO_LSDOM_E; i++) begin
            assign addr_map[i] = '{
                idx: i,
                start_addr: 32'h0000_0000,
                end_addr:   32'h0008_0000
            };
            `AXI_LITE_OFFSET(to_lsdom, msts[i], addr_map[i]);
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

        .axil_slv (slvs),
        .axil_mst (msts),

        .addr_map (addr_map)
    );

endmodule