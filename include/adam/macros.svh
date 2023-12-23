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
    __opt NO_LSPA_GPIOS  = CFG.NO_LSPA_GPIOS __sep \
    __opt NO_LSPA_SPIS   = CFG.NO_LSPA_SPIS __sep \
    __opt NO_LSPA_TIMERS = CFG.NO_LSPA_TIMERS __sep \
    __opt NO_LSPA_UARTS  = CFG.NO_LSPA_UARTS __sep \
    \
    __opt NO_LSPB_GPIOS  = CFG.NO_LSPB_GPIOS __sep \
    __opt NO_LSPB_SPIS   = CFG.NO_LSPB_SPIS __sep \
    __opt NO_LSPB_TIMERS = CFG.NO_LSPB_TIMERS __sep \
    __opt NO_LSPB_UARTS  = CFG.NO_LSPB_UARTS __sep \
    \
    __opt EN_BOOTSTRAP_CPU0  = CFG.EN_BOOTSTRAP_CPU0 __sep \
    __opt EN_BOOTSTRAP_MEM0  = CFG.EN_BOOTSTRAP_MEM0 __sep \
    __opt EN_BOOTSTRAP_LPCPU = CFG.EN_BOOTSTRAP_LPCPU __sep \
    __opt EN_BOOTSTRAP_LPMEM = CFG.EN_BOOTSTRAP_LPMEM __sep \
    \
    __opt NO_LSPAS = NO_LSPA_GPIOS + NO_LSPA_SPIS + NO_LSPA_TIMERS + \
        NO_LSPA_UARTS __sep \
    \
    __opt EN_LSPA = (NO_LSPAS > 0) __sep \
    \
    __opt NO_LSPBS = NO_LSPB_GPIOS + NO_LSPB_SPIS + NO_LSPB_TIMERS + \
        NO_LSPB_UARTS __sep \
    \
    __opt EN_LSPB = (NO_LSPBS > 0) __sep \
    \
    __opt NO_HSPS = 1 __sep \
    __opt EN_HSP  = 1 __sep \
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

`define ADAM_AXIL_DV_I AXI_LITE_DV #( \
    .AXI_ADDR_WIDTH (ADDR_WIDTH), \
    .AXI_DATA_WIDTH (DATA_WIDTH) \
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