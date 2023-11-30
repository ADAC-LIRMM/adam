`ifndef ADAM_MACROS_BHV_SVH_
`define ADAM_MACROS_BHV_SVH_

`include "adam/macros.svh"

`define ADAM_STREAM_MST_BHV_FACTORY(
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

`define ADAM_STREAM_SLV_BHV_FACTORY(
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

`endif
