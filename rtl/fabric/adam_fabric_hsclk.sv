`include "axi/assign.svh"

`define AXIL_I AXI_LITE #( \
    .AXI_ADDR_WIDTH (ADDR_WIDTH), \
    .AXI_DATA_WIDTH (DATA_WIDTH) \
)

module adam_fabric_hsclk #(
	parameter ADDR_WIDTH = 32,
	parameter DATA_WIDTH = 32,

    parameter NO_CPUS    = 2,
    parameter NO_DMAS    = 2,
    parameter NO_MEMS    = 2,

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

    AXI_LITE.Slave cpus    [2*NO_CORES],
    AXI_LITE.Slave dmas    [NO_DMAS],
    AXI_LITE.Slave dbg_slv,
    AXI_LITE.Slave from_lsclk

    AXI_LITE.Master to_lsclk,
    AXI_LITE.Master dbg_mst,
    AXI_LITE.Master mems    [NO_MEMS],
    AXI_LITE.Master hsip
);

    localparam MAX_TRANS = 7;

    localparam NO_BASE_SLVS = NO_DMAS + 2;
    localparam NO_BASE_MSTS = 5;

    localparam NO_INTM_SLVS = (NO_CORES-1) + 1;
    localparam NO_INTM_MSTS = (NO_MEMS-1) + 1;

    typedef struct packed {
        int unsigned idx;
        addr_t start_addr;
        addr_t end_addr;
    } rule_t;

    `AXIL_I base_slvs [NO_BASE_SLVS] ();
    `AXIL_I base_msts [NO_BASE_MSTS] ();

    `AXIL_I base_to_intm ();
    `AXIL_I intm_to_base ();
    
    rule_t [NO_BASE_MSTS-1:0] base_map;
    rule_t [NO_INTM_MSTS-1:0] intm_map;
    
    // Base Slave Mapping
    generate 
        localparam BSM_CORE0_S = 0;
		localparam BSM_CORE0_E = BSM_CORE0_S + 2;

        localparam BSM_DMA_S = BSM_CORE0_E;
        localparam BSM_DMA_E = BSM_DMA_S + 2;

        localparam BSM_INTM_S = BSM_DMA_E;
        localparam BSM_INTM_E = BSM_INTM_S + 1;

        // Core 0 (LPU)
		for (genvar i = BSM_CORE0_S; i < BSM_CORE0_E; i++) begin
			`AXI_LITE_ASSIGN(base_slvs[i], cores[i - BSM_CORE0_S]);
		end

        // DMAs
        for (genvar i = BSM_DMA_S; i < BSM_DMA_E; i++) begin
			`AXI_LITE_ASSIGN(base_slvs[i], dmas[i - BSM_DMA_S]);
		end

        // Intm.
        for (genvar i = BSM_INTM_S; i < BSM_INTM_E; i++) begin
			`AXI_LITE_ASSIGN(base_slvs[i], intm_to_base);
		end
    endgenerate

    // Base Master Mapping
    generate		
        // Debug Interface
        assign base_map[0] = '{
            idx: 0,
            start_addr: 32'h0000_0000,
            end_addr:   32'h0000_4000
        };
        `AXI_LITE_OFFSET(dbg_mst, base_msts[0], base_map[0]);

        // Memory 0
        assign base_map[1] = '{
            idx: 1,
            start_addr: 32'h0000_4000,
            end_addr:   32'h0000_8000
        };
        `AXI_LITE_OFFSET(mems[0], base_msts[1], base_map[1]);

        // SYSCFG
        assign base_map[2] = '{
            idx: 2,
            start_addr: 32'h0000_8000,
            end_addr:   32'h0000_8400
        };
        `AXI_LITE_OFFSET(syscfg, base_msts[2], base_map[2]);

        // Low Speed Base Peripherals (LSBP)
        assign base_map[3] = '{
            idx: 3,
            start_addr: 32'h0001_0000,
            end_addr:   32'h0001_8000
        };
        `AXI_LITE_OFFSET(lsbp, base_msts[3], base_map[3]);

        // Intm.
        assign base_map[4] = '{
            idx: 4,
            start_addr: 32'h0002_0000,
            end_addr:   '0 // unbounded
        };
        `AXI_LITE_OFFSET(base_to_intm, base_msts[4], base_map[4]);
    endgenerate

    // Intm. Slave Mapping
    generate
        localparam ISM_CORE0_S = 0;
		localparam ISM_CORE0_E = ISM_CORE0_S + 2*(NO_CORES-1);
		
        localparam ISM_BASE_S = ISM_CORE0_E;
        localparam ISM_BASE_E = ISM_BASE_S + 1;

        for (genvar i = ISM_CORE0_S; i < ISM_CORE0_E; i++) begin
			`AXI_LITE_ASSIGN(intm_slvs[i], cores[i-ISM_CORE0_S+1]);
        end

		for (genvar i = ISM_BASE_S; i < ISM_BASE_E; i++) begin
			`AXI_LITE_ASSIGN(intm_slvs[i], intm_to_base);
		end
    endgenerate

    // Intm. Master Mapping
    generate
        localparam IMM_MEMS_S = 0;
        localparam IMM_MEMS_E = IMM_MEMS_S + (NO_MEMS-1);

        localparam IMM_BASE_S = IMM_MEMS_E;
        localparam IMM_BASE_E = IMM_BASE_S + 1;

        for (genvar i = IMM_MEMS_S; i < IMM_MEMS_E; i++) begin
            assign intm_map[i] = '{
                idx: i,
                start_addr: 32'h0100_0000 + 32'h0100_0000*(i-IMM_MEMS_S),
                end_addr:   32'h0100_0000 + 32'h0100_0000*(i-IMM_MEMS_S+1)
            };
            `AXI_LITE_OFFSET(mems[i-IMM_MEMS_S+1], intm_msts[i], intm_map[i]);
        end

        for (genvar i = IMM_BASE_S; i < IMM_BASE_E; i++) begin
            assign intm_map[i] = '{
                idx: i,
                start_addr: 32'h0000_0000,
                end_addr:   32'h0002_0000
            };
            `AXI_LITE_OFFSET(intm_to_base, intm_msts[i], intm_map[i]);
        end
    endgenerate

    adam_axil_xbar #(
        .ADDR_WIDTH (ADDR_WIDTH),
        .DATA_WIDTH (DATA_WIDTH),

        .NO_SLVS  (NO_BASE_SLVS),
        .NO_MSTS (NO_BASE_MSTS),
        
        .MAX_TRANS (MAX_TRANS),

        .rule_t (rule_t)
    ) adam_axil_xbar (
        .clk  (clk),
        .rst  (rst),
        
        .pause_req (base_pause_req),
		.pause_ack (base_pause_ack),

        .axil_slv (base_slvs),
        .axil_mst (base_msts),

        .addr_map (base_map)
    );

endmodule