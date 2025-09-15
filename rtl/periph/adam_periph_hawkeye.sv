/*
 * Copyright 2025 LIRMM
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

`include "adam/macros.svh"
`include "axi/assign.svh"
`include "axi/typedef.svh"

module adam_periph_hawkeye #(
    `ADAM_CFG_PARAMS
) (
    ADAM_SEQ.Slave seq,

    // OBI
    input  logic  req_i,
    output logic  gnt_o,
    input  ADDR_T addr_i,
    input  logic  we_i,
    input  STRB_T be_i,
    input  DATA_T wdata_i,
    output logic  rvalid_o,
    input  logic  rready_i,
    output DATA_T rdata_o,

    // DIN
    input  din_t din_i,
    input  logic din_valid_i,
    output logic din_ready_o,

    // DOUT
    output dout_t dout_o,
    output logic  dout_valid_o,
    input  logic  dout_ready_i
);
    // skid ===================================================================

    DATA_T rdata;
    logic  rvalid;
    logic  rready;

    ADAM_STREAM #(
        .T (DATA_T)
    ) mst ();

    assign mst.data = rdata;
    assign mst.valid = rvalid;
    assign rready = mst.ready;

    ADAM_STREAM #(
        .T (DATA_T)
    ) slv ();

    assign rdata_o = slv.data;
    assign rvalid_o = slv.valid;
    assign slv.ready = rready_i;

    adam_stream_skid #(
        .T (DATA_T)
    ) skid (
        .seq (seq),

        .slv (mst),
        .mst (slv)
    );

    // ========================================================================

    function automatic int ceil_div(int a, int b);
        return (a + b - 1) / b;
    endfunction

    localparam int DinSize = ceil_div(DinWidth, DATA_WIDTH);
    localparam int DoutSize = ceil_div(DoutWidth, DATA_WIDTH);

    typedef struct packed {
        din_t  din;
        logic  din_valid;
        dout_t dout;
        logic  dout_valid;
    } state_t;

    state_t d, q;

    always_comb begin
        automatic ADDR_T idx = addr_i >> $clog2(STRB_WIDTH);

        gnt_o        = '0;
        rdata        = '0;
        rvalid       = '0;
        din_ready_o  = '0;
        dout_o       = '0;
        dout_valid_o = '0;

        d = q;

        din_ready_o = !d.din_valid;

        if (din_valid_i && din_ready_o) begin
            d.din = din_i;
            d.din_valid = 1;
        end

        gnt_o = rready && (we_i ? !d.dout_valid : d.din_valid);

        if (req_i && gnt_o) begin
            if (we_i) begin
                for (int i = 0; i < DoutSize; i++) begin
                    if (idx == i) d.dout[i*DATA_WIDTH +: DATA_WIDTH] = wdata_i;
                end
                if (idx == DoutSize-1) begin
                    d.dout_valid = 1;
                end
            end
            else begin
                for (int i = 0; i < DinSize; i++) begin
                    if (idx == i) rdata = d.din[i*DATA_WIDTH +: DATA_WIDTH];
                end
                if (idx == DinSize-1) begin
                    d.din_valid = 0;
                end
            end
            rvalid = 1;
        end

        dout_o = d.dout;
        dout_valid_o = d.dout_valid;

        if (dout_valid_o && dout_ready_i) begin
            d.dout_valid = 0;
        end
    end

    always_ff @(posedge seq.clk) begin
        if (seq.rst) begin
            q <= '0;
        end
        else begin
            q <= d;
        end
    end
endmodule
