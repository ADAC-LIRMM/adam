`ifndef ADAM_MACROS_BHV_SVH_
`define ADAM_MACROS_BHV_SVH_

`include "adam/macros.svh"

// ADAM_BHV_CFG ===============================================================

`define ADAM_BHV_CFG_PARAMS \
    `ADAM_CFG_PARAMS, \
    parameter type      BHV_CFG_T = adam_cfg_pkg::BHV_CFG_T, \
    parameter BHV_CFG_T BHV_CFG   = adam_cfg_pkg::BHV_CFG, \
    \
    parameter CLK_PERIOD = BHV_CFG.CLK_PERIOD, \
    parameter RST_CYCLES = BHV_CFG.RST_CYCLES, \
    \
    parameter TA = BHV_CFG.TA, \
    parameter TT = BHV_CFG.TT

`define ADAM_BHV_CFG_PARAMS_MAP \
    `ADAM_CFG_PARAMS_MAP, \
    .BHV_CFG_T (BHV_CFG_T), \
    .BHV_CFG   (BHV_CFG)

// ADAM_APB_BHV Factories ====================================================

`define ADAM_APB_BHV_MST_FACTORY(
    prefix, clk
) \
    `ADAM_APB_I ``prefix`` (); \
    `ADAM_APB_DV_I ``prefix``_dv (clk); \
    `APB_ASSIGN(``prefix``, ``prefix``_dv); \
    apb_test::apb_driver #( \
        .ADDR_WIDTH (ADDR_WIDTH), \
        .DATA_WIDTH (DATA_WIDTH), \
        .TA         (TA), \
        .TT         (TT) \
    ) ``prefix``_bhv = new(``prefix``_dv);

// ADAM_STREAM_BHV Factories ==================================================

`define ADAM_STREAM_BHV_MST_FACTORY(
    _data_t, _TA, _TT,
    prefix, clk
) \
    ADAM_STREAM #( \
        .data_t (_data_t) \
    ) ``prefix`` (); \
    \
    ADAM_STREAM_DV #( \
        .data_t (_data_t) \
    ) ``prefix``_dv (clk); \
    \
    `ADAM_STREAM_ASSIGN(``prefix``, ``prefix``_dv); \
    \
    adam_stream_mst_bhv #( \
        .data_t (_data_t), \
        .TA (_TA), \
        .TT (_TT) \
    ) ``prefix``_bhv; \
    \
    initial begin \
        ``prefix``_bhv = new(``prefix``_dv); \
        ``prefix``_bhv.loop(); \
    end

`define ADAM_STREAM_BHV_SLV_FACTORY(
    _data_t, _TA, _TT, _MAX_TRANS,
    prefix, clk
) \
    ADAM_STREAM #( \
        .data_t (_data_t) \
    ) ``prefix`` (); \
    \
    ADAM_STREAM_DV #( \
        .data_t (_data_t) \
    ) ``prefix``_dv (clk); \
    \
    `ADAM_STREAM_ASSIGN(``prefix``_dv, ``prefix``); \
    \
    adam_stream_slv_bhv #( \
        .data_t (_data_t), \
        .TA (_TA), \
        .TT (_TT), \
        .MAX_TRANS (_MAX_TRANS) \
    ) ``prefix``_bhv; \
    \
    initial begin \
        ``prefix``_bhv = new(``prefix``_dv); \
        ``prefix``_bhv.loop(); \
    end

// ADAM_UNTIL =================================================================

`define ADAM_UNTIL_DO_FINNALY(cond, do_, finnaly) begin \
    cycle_start(); \
    while (!(cond)) begin \
        do_; \
        cycle_end(); \
        cycle_start(); \
    end \
    finnaly; \
    cycle_end(); \
end

`define ADAM_UNTIL(cond) `ADAM_UNTIL_DO_FINNALY(cond,,);

`define ADAM_UNTIL_DO(cond, do_) `ADAM_UNTIL_DO_FINNALY(cond, do_,);

`define ADAM_UNTIL_FINNALY(cond, finnaly) \
    `ADAM_UNTIL_DO_FINNALY(cond,, finnaly);

`endif