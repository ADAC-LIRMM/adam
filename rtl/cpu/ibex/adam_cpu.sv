module adam_cpu #(
	parameter ADDR_WIDTH = 32,
	parameter DATA_WIDTH = 32,

	// Dependent parameters bellow, do not override.
    
	parameter STRB_WIDTH = (DATA_WIDTH/8),

	parameter type addr_t = logic [ADDR_WIDTH-1:0],
	parameter type data_t = logic [DATA_WIDTH-1:0],
	parameter type strb_t = logic [STRB_WIDTH-1:0]
) (
	input logic clk,
	input logic rst,
	input logic test,

	input  logic pause_req,
	output logic pause_ack,

	input  addr_t boot_addr,

	AXI_LITE.Master inst_axil,
	AXI_LITE.Master data_axil,

	input  logic irq
);

	logic  inst_pause_req;
	logic  inst_pause_ack;

	logic  inst_req_o;
	logic  inst_gnt_i;
	logic  inst_rvalid_i;
	logic  inst_rready_o;
	addr_t inst_addr_o;
	strb_t inst_be_o;
	data_t inst_wdata_o;
	logic  inst_we_o;
	data_t inst_rdata_i;

	logic  data_pause_req;
	logic  data_pause_ack;

	logic  data_req_o;
	logic  data_gnt_i;
	logic  data_rvalid_i;
	logic  data_rready_o;
	addr_t data_addr_o;
	strb_t data_be_o;
	data_t data_wdata_o;
	logic  data_we_o;
	data_t data_rdata_i;
	
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
        .DmHaltAddr       (32'h1A110800),
        .DmExceptionAddr  (32'h1A110808)
    ) ibex_top (
        // Clock and reset
        .clk_i       (clk),
        .rst_ni      (!rst),
        .test_en_i   ('0),
        .scan_rst_ni (test),
        // .ram_cfg_i   (10'b0),

        // Configuration
        .hart_id_i   (32'h0000_0000),
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

	adam_obi_axil_bridge #(
		.ADDR_WIDTH(ADDR_WIDTH),
		.DATA_WIDTH(DATA_WIDTH)
	) instr_adam_obi_axil_bridge (
		.clk  (clk),
    	.rst  (rst),
		.test (test),

    	.axil (inst_axil),

		.pause_req (inst_pause_req),
    	.pause_ack (inst_pause_ack),

		.req    (inst_req_o),
    	.gnt    (inst_gnt_i),
    	.addr   (inst_addr_o),
    	.we     ('0),
    	.be     (strb_t'(0)),
    	.wdata  ('0),
    	.rvalid (inst_rvalid_i),
    	.rready (inst_rready_o),
    	.rdata  (inst_rdata_i) 
	);

	adam_obi_axil_bridge #(
		.ADDR_WIDTH (ADDR_WIDTH),
		.DATA_WIDTH (DATA_WIDTH)
	) data_adam_obi_axil_bridge (
		.clk  (clk),
    	.rst  (rst),
		.test (test),

    	.axil (data_axil),

		.pause_req (data_pause_req),
    	.pause_ack (data_pause_ack),

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
		inst_pause_req = pause_req;
		data_pause_req = pause_req;

		if (pause_req) begin
			pause_ack = inst_pause_ack && data_pause_ack;
		end
		else begin
			pause_ack = inst_pause_ack || data_pause_ack;
		end
	end

endmodule