`include "adam/macros.svh"

module adam_core_gmsv
    import gmsv_pkg::*;
#(
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

    cv32e40x_if_xif xif ();

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

    cv32e40x_core #(
        .X_EXT (1)
    ) i_cv32e40x_core (
        // Clock and reset
        .rst_ni       (!seq.rst),
        .clk_i        (seq.clk),
        .scan_cg_en_i ('0),

        // Static Configuration
        .boot_addr_i         (boot_addr),
        .dm_exception_addr_i (DEBUG_ADDR_EXCEPTION),
        .dm_halt_addr_i      (DEBUG_ADDR_HALT),
        .mhartid_i           (hart_id),
        .mimpid_patch_i      ('0),
        .mtvec_addr_i        (boot_addr),

        // Instruction memory interface
        .instr_req_o     (inst_req),
        .instr_gnt_i     (inst_gnt),
        .instr_rvalid_i  (inst_rvalid),
        .instr_addr_o    (inst_addr),
        .instr_memtype_o (),
        .instr_prot_o    (),
        .instr_dbg_o     (),
        .instr_rdata_i   (inst_rdata),
        .instr_err_i     ('0),

        // Data memory interface
        .data_req_o     (data_req),
        .data_gnt_i     (data_gnt),
        .data_rvalid_i  (data_rvalid),
        .data_addr_o    (data_addr),
        .data_be_o      (data_be),
        .data_we_o      (data_we),
        .data_wdata_o   (data_wdata),
        .data_memtype_o (),
        .data_prot_o    (),
        .data_dbg_o     (),
        .data_atop_o    (),
        .data_rdata_i   (data_rdata),
        .data_err_i     ('0),
        .data_exokay_i  ('0),

        // Cycle count
        .mcycle_o (),

        // Time input
        .time_i ('0),

        // eXtension interface
        .xif_compressed_if (xif),
        .xif_issue_if      (xif),
        .xif_commit_if     (xif),
        .xif_mem_if        (xif),
        .xif_mem_result_if (xif),
        .xif_result_if     (xif),

        // Basic Interrupt interface
        .irq_i     ({20'b0, irq, 11'b0}),

        .wu_wfe_i ('0),

        // CLIC interrupt architecture
        .clic_irq_i       (),
        .clic_irq_id_i    (),
        .clic_irq_level_i (),
        .clic_irq_priv_i  (),
        .clic_irq_shv_i   (),

        // Fence.i flush handshake
        .fencei_flush_req_o (),
        .fencei_flush_ack_i ('0),

        // Debug interface
        .debug_req_i       (debug_req),
        .debug_havereset_o (),
        .debug_running_o   (),
        .debug_halted_o    (),
        .debug_pc_valid_o  (),
        .debug_pc_o        (),

        // CPU control signals
        .fetch_enable_i  ('1),
        .core_sleep_o    ()
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

    `ADAM_AXIL_I axil_data_core ();

    adam_obi_to_axil #(
        `ADAM_CFG_PARAMS_MAP
    ) data_adam_obi_to_axil (
        .seq   (seq),
        .pause (pause_data),

        .axil (axil_data_core),

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

    // gmsv ===================================================================

    dec_req_t dec_req;
    logic     dec_req_valid;
    logic     dec_req_ready;

    dec_rsp_t dec_rsp;
    logic     dec_rsp_valid;
    logic     dec_rsp_ready;

    exe_req_t exe_req;
    logic     exe_req_valid;
    logic     exe_req_ready;

    exe_req_t exe_rsp;
    logic     exe_rsp_valid;
    logic     exe_rsp_ready;

    axi_aw_t axi_aw;
    logic    axi_aw_valid;
    logic    axi_aw_ready;

    axi_w_t axi_w;
    logic   axi_w_valid;
    logic   axi_w_ready;

    axi_b_t axi_b;
    logic   axi_b_valid;
    logic   axi_b_ready;

    axi_ar_t axi_ar;
    logic    axi_ar_valid;
    logic    axi_ar_ready;

    axi_r_t axi_r;
    logic   axi_r_valid;
    logic   axi_r_ready;

    gmsv i_gmsv (
        .clk_i (seq.clk),
        .rst_i (seq.rst),

        .dec_req_i       (dec_req),
        .dec_req_valid_i (dec_req_valid),
        .dec_req_ready_o (dec_req_ready),

        .dec_rsp_o       (dec_rsp),
        .dec_rsp_valid_o (dec_rsp_valid),
        .dec_rsp_ready_i (dec_rsp_ready),

        .exe_req_i       (exe_req),
        .exe_req_valid_i (exe_req_valid),
        .exe_req_ready_o (exe_req_ready),

        .exe_rsp_o       (exe_rsp),
        .exe_rsp_valid_o (exe_rsp_valid),
        .exe_rsp_ready_i (exe_rsp_ready),

        .axi_aw_o       (axi_aw),
        .axi_aw_valid_o (axi_aw_valid),
        .axi_aw_ready_i (axi_aw_ready),

        .axi_w_o       (axi_w),
        .axi_w_valid_o (axi_w_valid),
        .axi_w_ready_i (axi_w_ready),

        .axi_b_i       (axi_b),
        .axi_b_valid_i (axi_b_valid),
        .axi_b_ready_o (axi_b_ready),

        .axi_ar_o       (axi_ar),
        .axi_ar_valid_o (axi_ar_valid),
        .axi_ar_ready_i (axi_ar_ready),

        .axi_r_i       (axi_r),
        .axi_r_valid_i (axi_r_valid),
        .axi_r_ready_o (axi_r_ready)
    );

    `ADAM_AXIL_I axil_data_gmsv ();

    assign axil_data_gmsv.aw_addr = axi_aw.addr;
    assign axil_data_gmsv.aw_prot = axi_aw.prot;
    assign axil_data_gmsv.aw_valid = axi_aw_valid;
    assign axi_aw_ready = axil_data_gmsv.aw_ready;

    assign axil_data_gmsv.w_data = axi_w.data;
    assign axil_data_gmsv.w_strb = axi_w.strb;
    assign axil_data_gmsv.w_valid = axi_w_valid;
    assign axi_w_ready = axil_data_gmsv.w_ready;

    assign axi_b.resp = axil_data_gmsv.b_resp;
    assign axi_b_valid = axil_data_gmsv.b_valid;
    assign axil_data_gmsv.b_ready = axi_b_ready;

    assign axil_data_gmsv.ar_addr = axi_ar.addr;
    assign axil_data_gmsv.ar_prot = axi_ar.prot;
    assign axil_data_gmsv.ar_valid = axi_ar_valid;
    assign axi_ar_ready = axil_data_gmsv.ar_ready;

    assign axi_r.resp = axil_data_gmsv.r_resp;
    assign axi_r_valid = axil_data_gmsv.r_valid;
    assign axil_data_gmsv.r_ready = axi_r_ready;

    adam_core_gmsv_cvx_bridge i_cvx_bridge (
        .clk_i (seq.clk),
        .rst_i (seq.rst),

        .dec_req_o       (dec_req),
        .dec_req_valid_o (dec_req_valid),
        .dec_req_ready_i (dec_req_ready),

        .dec_rsp_i       (dec_rsp),
        .dec_rsp_valid_i (dec_rsp_valid),
        .dec_rsp_ready_o (dec_rsp_ready),

        .exe_req_o       (exe_req),
        .exe_req_valid_o (exe_req_valid),
        .exe_req_ready_i (exe_req_ready),

        .exe_rsp_i       (exe_rsp),
        .exe_rsp_valid_i (exe_rsp_valid),
        .exe_rsp_ready_o (exe_rsp_ready),

        .xif_compressed_if (xif),
        .xif_issue_if      (xif),
        .xif_commit_if     (xif),
        .xif_mem_if        (xif),
        .xif_mem_result_if (xif),
        .xif_result_if     (xif)
    );

    // axi mux ================================================================

    axi_lite_mux_intf #(
        .AxiAddrWidth (ADDR_WIDTH),
        .AxiDataWidth (DATA_WIDTH),
        .NoSlvPorts   (2),
        .MaxTrans     (7)
    ) i_axi_mux (
        .clk_i  (seq.clk),
        .rst_ni (!seq.rst),
        .test_i (0),

        .slv    ({axil_data_core, axil_data_gmsv}),
        .mst    (axil_data)
    );

    // pause ==================================================================

    ADAM_PAUSE pause_null ();
    ADAM_PAUSE temp_pause [3] ();
    assign temp_pause[0].ack        = pause_inst.ack;
    assign temp_pause[1].ack        = pause_data.ack;
    assign temp_pause[2].ack        = pause_null.ack;
    assign pause_inst.req           = temp_pause[0].req;
    assign pause_data.req           = temp_pause[1].req;
    assign pause_null.req           = temp_pause[2].req;

    adam_pause_demux #(
        `ADAM_CFG_PARAMS_MAP,

        .NO_MSTS  (2),
        .PARALLEL (1)
    ) adam_pause_demux (
        .seq (seq),

        .slv (pause),
        .mst (temp_pause)
    );

endmodule
