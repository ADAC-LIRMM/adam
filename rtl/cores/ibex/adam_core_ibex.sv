`include "adam/macros.svh"

module adam_core_ibex #(
    `ADAM_CFG_PARAMS
) (
    ADAM_SEQ.Slave   seq,
    ADAM_PAUSE.Slave pause,

    input  ADDR_T boot_addr,
    input  DATA_T hart_id,

    AXI_LITE.Master axil_inst,
    AXI_LITE.Master axil_data,

    input  logic irq,

    input logic debug_req,
    output logic debug_unavail
);
    assign debug_unavail = '1;
    // logic  pause_inst.req;
    // logic  pause_inst.ack;

    ADAM_PAUSE pause_inst ();
    ADAM_PAUSE pause_data ();

    logic  inst_req_o;
    logic  inst_gnt_i;
    logic  inst_rvalid_i;
    logic  inst_rready_o;
    ADDR_T inst_addr_o;
    STRB_T inst_be_o;
    DATA_T inst_wdata_o;
    logic  inst_we_o;
    DATA_T inst_rdata_i;

    // logic  pause_data.req;
    // logic  pause_data.ack;

    logic  data_req_o;
    logic  data_gnt_i;
    logic  data_rvalid_i;
    logic  data_rready_o;
    ADDR_T data_addr_o;
    STRB_T data_be_o;
    DATA_T data_wdata_o;
    logic  data_we_o;
    DATA_T data_rdata_i;
    
    assign inst_rready_o = 1;
    assign inst_be_o     = 0;
    assign inst_wdata_o  = 0;
    assign inst_we_o     = 0;

    assign data_rready_o = 1;

    ibex_top #(
        .PMPEnable        (0),
        .PMPGranularity   (0),
        .PMPNumRegions    (4),
        .MHPMCounterNum   (0),
        .MHPMCounterWidth (40),
        .RV32E            (0),
        .RV32M            (ibex_pkg::RV32MFast),
        .RV32B            (ibex_pkg::RV32BNone),
        .RegFile          (ibex_pkg::RegFileFF),
        .ICache           (0),
        .ICacheECC        (0),
        .ICacheScramble   (0),
        .BranchPredictor  (0),
        .SecureIbex       (0),
        .RndCnstLfsrSeed  (ibex_pkg::RndCnstLfsrSeedDefault),
        .RndCnstLfsrPerm  (ibex_pkg::RndCnstLfsrPermDefault),
        .DbgTriggerEn     (0),
        .DmHaltAddr       (32'hFFFF_FFFF),
        .DmExceptionAddr  (32'hFFFF_FFFF)
    ) ibex_top (
        // Clock and reset
        .clk_i       (seq.clk),
        .rst_ni      (!seq.rst),
        .test_en_i   ('0),
        // .scan_rst_ni (test),
        .scan_rst_ni ('0),
        // .ram_cfg_i   (10'b0),

        // Configuration
        .hart_id_i   (hart_id),
        .boot_addr_i (boot_addr),

        // Instruction memory interface
        .instr_req_o        (inst_req_o),
        .instr_gnt_i        (inst_gnt_i),
        .instr_rvalid_i     (inst_rvalid_i),
        .instr_addr_o       (inst_addr_o),
        .instr_rdata_i      (inst_rdata_i),
        .instr_rdata_intg_i (7'b0),
        .instr_err_i        ('0),

        // Data memory interface
        .data_req_o        (data_req_o),
        .data_gnt_i        (data_gnt_i),
        .data_rvalid_i     (data_rvalid_i),
        .data_we_o         (data_we_o),
        .data_be_o         (data_be_o),
        .data_addr_o       (data_addr_o),
        .data_wdata_o      (data_wdata_o),
        // .data_wdata_intg_o (),
        .data_rdata_i      (data_rdata_i),
        .data_rdata_intg_i (7'b0),
        .data_err_i        ('0),

        // Interrupt inputs
        .irq_software_i ('0),
        .irq_timer_i    ('0),
        .irq_external_i (irq),
        .irq_fast_i     (15'b0),
        .irq_nm_i       ('0),

        // Debug interface
        .debug_req_i  ('0),
        // .crash_dump_o (),

        // Special control signals
        .fetch_enable_i         ('1)
        // .alert_minor_o          (),
        // .alert_major_internal_o (),
        // .alert_major_bus_o      (),
        // .core_sleep_o           ()
    );

    adam_obi_to_axil #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH)
    ) instr_adam_obi_to_axil (
        .seq   (seq),
        .pause (pause_inst),

        .axil (axil_inst),

        .req    (inst_req_o),
        .gnt    (inst_gnt_i),
        .addr   (inst_addr_o),
        .we     ('0),
        .be     ('0),
        .wdata  ('0),
        .rvalid (inst_rvalid_i),
        .rready (inst_rready_o),
        .rdata  (inst_rdata_i) 
    );

    adam_obi_to_axil #(
        .ADDR_WIDTH (ADDR_WIDTH),
        .DATA_WIDTH (DATA_WIDTH)
    ) data_adam_obi_to_axil (
        .seq   (seq),
        .pause (pause_data),

        .axil (axil_data),

        .req    (data_req_o),
        .gnt    (data_gnt_i),
        .addr   (data_addr_o),
        .we     (data_we_o),
        .be     (data_be_o),
        .wdata  (data_wdata_o),
        .rvalid (data_rvalid_i),
        .rready (data_rready_o),
        .rdata  (data_rdata_i) 
    );

    always_comb begin
        pause_inst.req = pause.req;
        pause_data.req = pause.req;

        if (pause.req) begin
            pause.ack = pause_inst.ack && pause_data.ack;
        end
        else begin
            pause.ack = pause_inst.ack || pause_data.ack;
        end
    end

endmodule