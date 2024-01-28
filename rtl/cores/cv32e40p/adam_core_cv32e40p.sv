`include "adam/macros.svh"

module adam_core_cv32e40p #(
    `ADAM_CFG_PARAMS
) (
    ADAM_SEQ.Slave   seq,
    ADAM_PAUSE.Slave pause,

    input ADDR_T boot_addr,
    input DATA_T hart_id,

    AXI_LITE.Master axil_inst,
    AXI_LITE.Master axil_data,

    input logic irq,
    
    input  logic debug_req,
    output logic debug_unavail
);

    ADAM_PAUSE pause_inst ();
    ADAM_PAUSE pause_data ();

    logic  inst_req;
    logic  inst_gnt;
    logic  inst_rvalid;
    logic  inst_rready;
    ADDR_T inst_addr;
    STRB_T inst_be;
    DATA_T inst_wdata;
    logic  inst_we;
    DATA_T inst_rdata;

    logic  data_req;
    logic  data_gnt;
    logic  data_rvalid;
    logic  data_rready;
    ADDR_T data_addr;
    STRB_T data_be;
    DATA_T data_wdata;
    logic  data_we;
    DATA_T data_rdata;
    
    assign inst_rready = 1;
    assign inst_be     = 0;
    assign inst_wdata  = 0;
    assign inst_we     = 0;

    assign data_rready = 1;

    assign debug_unavail = pause.req || pause.ack;

    cv32e40p_top #(
        .FPU              (1),
        .FPU_ADDMUL_LAT   (2),
        .FPU_OTHERS_LAT   (2),
        .ZFINX            (0),
        .COREV_PULP       (0),
        .COREV_CLUSTER    (0),
        .NUM_MHPMCOUNTERS (1)
    ) cv32e40p_top (
        // Clock and reset
        .rst_ni       (!seq.rst),
        .clk_i        (seq.clk),
        .scan_cg_en_i ('0),

        // Special control signals
        .fetch_enable_i  ('1),
        .core_sleep_o    (),
        .pulp_clock_en_i ('0),

        // Configuration
        .boot_addr_i         (boot_addr),
        .mtvec_addr_i        (boot_addr),
        .dm_halt_addr_i      (DEBUG_ADDR_HALT),
        .dm_exception_addr_i (DEBUG_ADDR_EXCEPTION),
        .hart_id_i           (hart_id),

        // Instruction memory interface
        .instr_req_o    (inst_req),
        .instr_gnt_i    (inst_gnt),
        .instr_rvalid_i (inst_rvalid),
        .instr_addr_o   (inst_addr),
        .instr_rdata_i  (inst_rdata),

        // Data memory interface
        .data_req_o    (data_req),
        .data_gnt_i    (data_gnt),
        .data_rvalid_i (data_rvalid),
        .data_addr_o   (data_addr),
        .data_be_o     (data_be),
        .data_wdata_o  (data_wdata),
        .data_we_o     (data_we),
        .data_rdata_i  (data_rdata),

        // Interrupt interface
        .irq_i     ({20'b0, irq, 11'b0}),
        .irq_ack_o (),
        .irq_id_o  (),

        // Debug interface
        .debug_req_i       (debug_req),
        .debug_havereset_o (),
        .debug_running_o   (),
        .debug_halted_o    ()
    );

    adam_obi_to_axil #(
        `ADAM_CFG_PARAMS_MAP
    ) instr_adam_obi_to_axil (
        .seq   (seq),
        .pause (pause_inst),

        .axil (axil_inst),

        .req    (inst_req),
        .gnt    (inst_gnt),
        .addr   (inst_addr),
        .we     ('0),
        .be     ('0),
        .wdata  ('0),
        .rvalid (inst_rvalid),
        .rready (inst_rready),
        .rdata  (inst_rdata) 
    );

    adam_obi_to_axil #(
        `ADAM_CFG_PARAMS_MAP
    ) data_adam_obi_to_axil (
        .seq   (seq),
        .pause (pause_data),

        .axil (axil_data),

        .req    (data_req),
        .gnt    (data_gnt),
        .addr   (data_addr),
        .we     (data_we),
        .be     (data_be),
        .wdata  (data_wdata),
        .rvalid (data_rvalid),
        .rready (data_rready),
        .rdata  (data_rdata) 
    );

    // pause ==================================================================

    ADAM_PAUSE pause_null ();

    adam_pause_demux #(
        `ADAM_CFG_PARAMS_MAP,

        .NO_MSTS  (2),
        .PARALLEL (1)
    ) adam_pause_demux (
        .seq (seq),

        .slv (pause),
        .mst ('{pause_inst, pause_data, pause_null})
    );

endmodule