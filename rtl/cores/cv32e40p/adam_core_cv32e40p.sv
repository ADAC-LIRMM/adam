`include "adam/macros.svh"

module adam_core_cv32e40p #(
    `ADAM_CFG_PARAMS
) (
    ADAM_SEQ.Slave   seq,
    ADAM_PAUSE.Slave pause,

    input ADDR_T boot_addr,
    input DATA_T hart_id,

    AXI_LITE.Master inst_axil,
    AXI_LITE.Master data_axil,

    input logic irq
);

    ADAM_PAUSE inst_pause ();
    ADAM_PAUSE data_pause ();

    logic  inst_req_o;
    logic  inst_gnt_i;
    logic  inst_rvalid_i;
    logic  inst_rready_o;
    ADDR_T inst_addr_o;
    STRB_T inst_be_o;
    DATA_T inst_wdata_o;
    logic  inst_we_o;
    DATA_T inst_rdata_i;

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

    // unused
    logic core_sleep_o;
    
    logic       irq_ack_o;
    logic [4:0] irq_id_o;

    logic debug_havereset_o;
    logic debug_running_o;
    logic debug_halted_o;

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
        .core_sleep_o    (core_sleep_o),
        .pulp_clock_en_i ('0),

        // Configuration
        .boot_addr_i         (boot_addr),
        .mtvec_addr_i        (boot_addr),
        .dm_halt_addr_i      (32'hFFFF_FFFF),
        .dm_exception_addr_i (32'hFFFF_FFFF),
        .hart_id_i           (hart_id),

        // Instruction memory interface
        .instr_req_o    (inst_req_o),
        .instr_gnt_i    (inst_gnt_i),
        .instr_rvalid_i (inst_rvalid_i),
        .instr_addr_o   (inst_addr_o),
        .instr_rdata_i  (inst_rdata_i),

        // Data memory interface
        .data_req_o    (data_req_o),
        .data_gnt_i    (data_gnt_i),
        .data_rvalid_i (data_rvalid_i),
        .data_addr_o   (data_addr_o),
        .data_be_o     (data_be_o),
        .data_wdata_o  (data_wdata_o),
        .data_we_o     (data_we_o),
        .data_rdata_i  (data_rdata_i),

        // Interrupt interface
        .irq_i     ({20'b0, irq, 11'b0}),
        .irq_ack_o (irq_ack_o),
        .irq_id_o  (irq_id_o),

        // Debug interface
        .debug_req_i       ('0),
        .debug_havereset_o (debug_havereset_o),
        .debug_running_o   (debug_running_o),
        .debug_halted_o    (debug_halted_o)
    );

    adam_obi_to_axil #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH)
    ) instr_adam_obi_to_axil (
        .seq   (seq),
        .pause (inst_pause),

        .axil (inst_axil),

        .req    (inst_req_o),
        .gnt    (inst_gnt_i),
        .addr   (inst_addr_o),
        .we     ('0),
        .be     (STRB_T'(0)),
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
        .pause (data_pause),

        .axil (data_axil),

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
        inst_pause.req = pause.req;
        data_pause.req = pause.req;

        if (pause.req) begin
            pause.ack = inst_pause.ack && data_pause.ack;
        end
        else begin
            pause.ack = inst_pause.ack || data_pause.ack;
        end
    end

endmodule