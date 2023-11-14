module adam_axil_offset #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32,

    // Dependent parameters bellow, do not override.

    parameter STRB_WIDTH  = DATA_WIDTH/8,

    parameter type addr_t = logic [ADDR_WIDTH-1:0],
    parameter type data_t = logic [DATA_WIDTH-1:0],
    parameter type strb_t = logic [STRB_WIDTH-1:0]    
) (
    AXI_LITE.Slave  slv,
    AXI_LITE.Master mst,

    addr_t offset
);

    // aw channel
    assign mst.aw_addr = slv.aw_addr - offset;
    assign mst.aw_prot = slv.aw_prot;
    assign mst.aw_valid = slv.aw_valid;
    assign slv.aw_ready = mst.aw_ready;

    // w channel
    assign mst.w_data = slv.w_data;
    assign mst.w_strb = slv.w_strb;
    assign mst.w_valid = slv.w_valid;
    assign slv.w_ready = mst.w_ready;

    // b channel
    assign slv.b_resp = mst.b_resp;
    assign slv.b_valid = mst.b_valid;
    assign mst.b_ready = slv.b_ready;

    // ar channel
    assign mst.ar_addr = slv.ar_addr - offset;
    assign mst.ar_prot = slv.ar_prot;
    assign mst.ar_valid = slv.ar_valid;
    assign slv.ar_ready = mst.ar_ready;

    // r channel
    assign slv.r_data = mst.r_data;
    assign slv.r_resp = mst.r_resp;
    assign slv.r_valid = mst.r_valid;
    assign mst.r_ready = slv.r_ready;

endmodule
