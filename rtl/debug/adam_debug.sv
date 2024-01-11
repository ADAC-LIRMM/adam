`include "adam/macros.svh"

module adam_debug #(
    `ADAM_CFG_PARAMS
) (
    ADAM_SEQ.Slave   seq,
    ADAM_PAUSE.Slave pause,

    AXI_LITE.Slave  axil_slv,
    AXI_LITE.Master axil_mst,

    input  logic trst_n,
    input  logic tck,
    input  logic tms,
    input  logic tdi,
    output logic tdo
);
    localparam XLEN = DATA_WIDTH;
    localparam type XLEN_T = logic [XLEN-1:0];

    localparam NO_HARTS = NO_CPUS + 1;

    // dmi_jtag ===============================================================
    
    dm::dmi_req_t dmi_req;
    logic         dmi_req_valid;
    logic         dmi_req_ready;

    dm::dmi_resp_t dmi_resp;
    logic          dmi_resp_ready;
    logic          dmi_resp_valid;

    dmi_jtag #(
        .IdcodeValue (32'h249511C3)
    ) dmi_jtag (
        .clk_i      (seq.clk),
        .rst_ni     (!seq.rst),
        .testmode_i ('0),

        .dmi_rst_no      (), // keep open
        .dmi_req_o       (dmi_req),
        .dmi_req_valid_o (dmi_req_valid),
        .dmi_req_ready_i (dmi_req_ready),
        
        .dmi_resp_i       (dmi_resp),
        .dmi_resp_valid_i (dmi_resp_valid),
        .dmi_resp_ready_o (dmi_resp_ready),
        
        .tck_i    (tck),
        .tms_i    (tms),
        .trst_ni  (trst_n),
        .td_i     (tdi),
        .td_o     (tdo),
        .tdo_oe_o ()
    );

    // dm_top =================================================================

    logic [NO_HARTS-1:0] debug_req;
    
    generate
        dm::hartinfo_t [NO_HARTS-1:0] hartinfo;

        for (genvar i = 0; i < NO_HARTS; i++) {
            assign hartinfo[i] = '{
                zero1:      '0,
                nscratch:   '2, // debug module needs at least two scratch regs
                zero0:      '0,
                dataaccess: '1, // registers are memory mapped in the debugger
                datasize:   'h2,
                dataaddr:   'h380
            };
        }
    endgenerate

    logic  dm_slv_req;
    ADDR_T dm_slv_addr;
    logic  dm_slv_we;
    STRB_T dm_slv_be;
    DATA_T dm_slv_wdata;
    DATA_T dm_slv_rdata;

    logic  dm_mst_req;
    logic  dm_mst_gnt;
    ADDR_T dm_mst_addr;
    logic  dm_mst_we;
    STRB_T dm_mst_be;
    DATA_T dm_mst_wdata;
    logic  dm_mst_rvalid;
    DATA_T dm_mst_rdata;

    dm_top #(
        .NrHarts         (NO_CPUS+1),
        .BusWidth        (XLEN),
        .DmBaseAddress   ('h1000),
        .SelectableHarts ({{NO_CPUS{1'b1}}, 1'b0}),
        .ReadByteEnable  ('1)
    ) dm_top (
        .clk_i         (seq.clk),
        .rst_ni        (!seq.rst),
        .testmode_i    ('0),
        .ndmreset_o    (),
        .dmactive_o    (),
        .debug_req_o   (debug_req),
        .unavailable_i ('0),
        .hartinfo_i    (hartinfo),

        .slave_req_i      (dm_slv_req),
        .slave_we_i       (dm_slv_we),
        .slave_addr_i     (dm_slv_addr),
        .slave_be_i       (dm_slv_be),
        .slave_wdata_i    (dm_slv_wdata),
        .slave_rdata_o    (dm_slv_rdata),

        .master_req_o     (dm_mst_req),
        .master_add_o     (dm_mst_addr),
        .master_we_o      (dm_mst_we),
        .master_wdata_o   (dm_mst_wdata),
        .master_be_o      (dm_mst_be),
        .master_gnt_i     (dm_mst_gnt),
        .master_r_valid_i (dm_mst_valid),
        .master_r_rdata_i (dm_mst_rdata),

        .dmi_rst_ni       (!seq.rst),

        .dmi_req_valid_i  (dmi_req_valid),
        .dmi_req_ready_o  (dmi_req_ready),
        .dmi_req_i        (dmi_req),

        .dmi_resp_valid_o (dmi_resp_valid),
        .dmi_resp_ready_i (dmi_resp_ready),
        .dmi_resp_o       (dmi_resp)
    );

    // obi <-> axil ===========================================================

    adam_obi_from_axil #(
        `ADAM_CFG_PARAMS,

        .MAX_TRANS (FAB_MAX_TRANS)
    ) adam_obi_from_axil (
        .seq   (seq),
        .pause (pause),

        .axil (axil_slv),

        .req    (dm_slv_req),
        .gnt    ('1),
        .addr   (dm_slv_addr),
        .we     (dm_slv_we),
        .be     (dm_slv_be),
        .wdata  (dm_slv_wdata),
        .rvalid ('1),
        .rready (),
        .rdata  (dm_slv_rdata)
    );

    adam_obi_to_axil #(
        `ADAM_CFG_PARAMS,

        .MAX_TRANS (FAB_MAX_TRANS)
    ) adam_obi_to_axil (
        .seq   (seq),
        .pause (),

        .req    (dm_mst_req),
        .gnt    (dm_mst_gnt),
        .we     (dm_mst_we),
        .be     (dm_mst_be),
        .wdata  (dm_mst_wdata),
        .rvalid (dm_mst_rvalid),
        .rdata  (dm_mst_rdata)

        .axil (axil_mst) 
    );

endmodule