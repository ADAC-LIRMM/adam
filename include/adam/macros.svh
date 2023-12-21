`ifndef ADAM_MACROS_SVH_
`define ADAM_MACROS_SVH_

`include "axi/assign.svh"

`define ADAM_COMMA ,
`define ADAM_SEMICOLON ;

// ADAM_CFG ===================================================================

`define ADAM_CFG_PARAMS_GENERIC(__opt, __sep) \
    __opt type CFG_T = adam_cfg_pkg::CFG_T __sep \
    __opt CFG_T CFG  = adam_cfg_pkg::CFG __sep \
    \
    __opt ADDR_WIDTH = CFG.ADDR_WIDTH __sep \
    __opt DATA_WIDTH = CFG.DATA_WIDTH __sep \
    __opt GPIO_WIDTH = CFG.GPIO_WIDTH __sep \
    \
    __opt RST_BOOT_ADDR = CFG.RST_BOOT_ADDR __sep \
    \
    __opt NO_CPUS = CFG.NO_CPUS __sep \
    __opt NO_DMAS = CFG.NO_DMAS __sep \
    __opt NO_MEMS = CFG.NO_MEMS __sep \
    \
    __opt EN_LPCPU = CFG.EN_LPCPU __sep \
    __opt EN_LPMEM = CFG.EN_LPMEM __sep \
    __opt EN_DEBUG = CFG.EN_DEBUG __sep \
    \
    __opt NO_LSBP_GPIOS  = CFG.NO_LSBP_GPIOS __sep \
    __opt NO_LSBP_SPIS   = CFG.NO_LSBP_SPIS __sep \
    __opt NO_LSBP_TIMERS = CFG.NO_LSBP_TIMERS __sep \
    __opt NO_LSBP_UARTS  = CFG.NO_LSBP_UARTS __sep \
    \
    __opt NO_LSIP_GPIOS  = CFG.NO_LSIP_GPIOS __sep \
    __opt NO_LSIP_SPIS   = CFG.NO_LSIP_SPIS __sep \
    __opt NO_LSIP_TIMERS = CFG.NO_LSIP_TIMERS __sep \
    __opt NO_LSIP_UARTS  = CFG.NO_LSIP_UARTS __sep \
    \
    __opt NO_LSBPS = NO_LSBP_GPIOS + NO_LSBP_SPIS + NO_LSBP_TIMERS + \
        NO_LSBP_UARTS __sep \
    \
    __opt EN_LSBP = (NO_LSBPS > 0) __sep \
    \
    __opt NO_LSIPS = NO_LSIP_GPIOS + NO_LSIP_SPIS + NO_LSIP_TIMERS + \
        NO_LSIP_UARTS __sep \
    \
    __opt EN_LSIP = (NO_LSIPS > 0) __sep \
    \
    __opt NO_HSBPS = 1 __sep \
    __opt EN_HSBP  = 1 __sep \
    __opt NO_HSIPS = 1 __sep \
    __opt EN_HSIP  = 1 __sep \
    \
    __opt STRB_WIDTH  = DATA_WIDTH/8 __sep \
    \
    __opt type ADDR_T = logic [ADDR_WIDTH-1:0] __sep \
    __opt type PROT_T = logic [2:0] __sep \
    __opt type DATA_T = logic [DATA_WIDTH-1:0] __sep \
    __opt type STRB_T = logic [STRB_WIDTH-1:0] __sep \
    __opt type RESP_T = logic [1:0]

`define ADAM_CFG_PARAMS \
    `ADAM_CFG_PARAMS_GENERIC(parameter, `ADAM_COMMA)

`define ADAM_CFG_LOCALPARAMS \
    `ADAM_CFG_PARAMS_GENERIC(localparam, `ADAM_SEMICOLON)

`define ADAM_CFG_PARAMS_MAP \
    .CFG_T (CFG_T), \
    .CFG (CFG)

// ADAM_APB ===================================================================

`define ADAM_APB_I APB #( \
    .ADDR_WIDTH (ADDR_WIDTH), \
    .DATA_WIDTH (DATA_WIDTH) \
)

`define ADAM_APB_DV_I APB_DV #( \
    .ADDR_WIDTH (ADDR_WIDTH), \
    .DATA_WIDTH (DATA_WIDTH) \
)

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

`define ADAM_AXIL_I AXI_LITE #( \
    .AXI_ADDR_WIDTH (CFG.ADDR_WIDTH), \
    .AXI_DATA_WIDTH (CFG.DATA_WIDTH) \
)

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