`ifndef ADAM_STREAM_ASSIGN_SVH_
`define ADAM_STREAM_ASSIGN_SVH_

`define ADAM_STREAM_ASSIGN(slv, mst) \
    assign slv.data  = mst.data; \
    assign slv.valid = mst.valid; \
    assign mst.ready = slv.ready;

`endif