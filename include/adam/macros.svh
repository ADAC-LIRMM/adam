`ifndef ADAM_MACROS_SVH_
`define ADAM_MACROS_SVH_

`include "axi/assign.svh"

// ADAM_APB ===================================================================

`define ADAM_APB_MST_TIE_OFF(mst) \
    assign mst.paddr = '0; \
    assign mst.pprot = '0; \
    assign mst.psel = 1'b0; \
    assign mst.penable = 1'b0; \
    assign mst.pwrite = 1'b0; \
    assign mst.pwdata = '0; \
    assign mst.pstrb = '0;

`define ADAM_APB_SLV_TIE_OFF(slv) \
    assign slv.pready = 1'b1; \
    assign slv.prdata = '0; \
    assign slv.pslverr = 1'b1;

`define ADAM_APB_OFFSET(dst, src, offset) \
    assign dst.paddr = src.paddr - (offset); \
    assign dst.pprot = src.pprot; \
    assign dst.psel = src.psel; \
    assign dst.penable = src.penable; \
    assign dst.pwrite = src.pwrite; \
    assign dst.pwdata = src.pwdata; \
    assign dst.pstrb = src.pstrb; \
    assign src.pready = dst.pready; \
    assign src.prdata = dst.prdata; \
    assign src.pslverr = dst.pslverr;

// ADAM_AXIL ==================================================================

`define ADAM_AXIL_MST_TIE_OFF(mst) \
    assign mst.aw_addr = '0; \
    assign mst.aw_prot = 3'b000; \
    assign mst.aw_valid = 1'b0; \
    assign mst.w_data = '0; \
    assign mst.w_strb = '0; \
    assign mst.w_valid = 1'b0; \
    assign mst.b_ready = 1'b0; \
    assign mst.ar_addr = '0; \
    assign mst.ar_prot = 3'b000; \
    assign mst.ar_valid = 1'b0; \
    assign mst.r_ready = 1'b0;

`define ADAM_AXIL_SLV_TIE_OFF(slv) \
    assign slv.aw_ready = 1'b0; \
    assign slv.w_ready = 1'b0; \
    assign slv.b_resp = 2'b11; \
    assign slv.b_valid = 1'b1; \
    assign slv.ar_ready = 1'b0; \
    assign slv.r_data = '0; \
    assign slv.r_resp = 2'b11; \
    assign slv.r_valid = 1'b1;

`define ADAM_AXIL_OFFSET(dst, src, offset) \
    assign dst.aw_addr = src.aw_addr - (offset); \
    assign dst.aw_prot = src.aw_prot; \
    assign dst.aw_valid = src.aw_valid; \
    assign src.aw_ready = dst.aw_ready; \
    `AXI_LITE_ASSIGN_W(dst, src); \
    `AXI_LITE_ASSIGN_B(src, dst); \
    assign dst.ar_addr = src.ar_addr - (offset); \
    assign dst.ar_prot = src.ar_prot; \
    assign dst.ar_valid = src.ar_valid; \
    assign src.ar_ready = dst.ar_ready; \
    `AXI_LITE_ASSIGN_R(src, dst);

// ADAM_IO ====================================================================

`define ADAM_IO_ASSIGN(slv, mst) \
    assign mst.i = slv.i; \
    assign slv.o = mst.o; \
    assign slv.mode = mst.mode; \
    assign slv.otype = mst.otype; 

// ADAM_PAUSE =================================================================

`define ADAM_PAUSE_MST_TIE_OFF(mst) \
    assign mst.req = '1;

`define ADAM_PAUSE_SLV_TIE_OFF(slv) \
    assign slv.ack = '1;

`define ADAM_PAUSE_MST_TIE_ON(mst) \
    assign mst.req = '0;

`define ADAM_PAUSE_SLV_TIE_ON(slv) \
    assign slv.ack = '0;

// ADAM_STREAM ================================================================

`define ADAM_STREAM_ASSIGN(slv, mst) \
    assign slv.data  = mst.data; \
    assign slv.valid = mst.valid; \
    assign mst.ready = slv.ready;

// ENDIF ======================================================================
`endif