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

module adam_axil_skid #(
    `ADAM_CFG_PARAMS,
    
    parameter BYPASS_AW = 0,
    parameter BYPASS_W  = 0,
    parameter BYPASS_B  = 0,
    parameter BYPASS_AR = 0,
    parameter BYPASS_R  = 0
) (
    ADAM_SEQ.Slave seq,

    AXI_LITE.Slave  slv,
    AXI_LITE.Master mst
);

    `AXI_LITE_TYPEDEF_AW_CHAN_T(aw_chan_t, ADDR_T);
    `AXI_LITE_TYPEDEF_W_CHAN_T(w_chan_t, DATA_T, STRB_T);
    `AXI_LITE_TYPEDEF_B_CHAN_T(b_chan_t);
    `AXI_LITE_TYPEDEF_AR_CHAN_T(ar_chan_t, ADDR_T);
    `AXI_LITE_TYPEDEF_R_CHAN_T(r_chan_t, DATA_T);

    aw_chan_t aw_slv;
    w_chan_t  w_slv;
    b_chan_t  b_slv;
    ar_chan_t ar_slv;
    r_chan_t  r_slv;

    aw_chan_t aw_mst;
    w_chan_t  w_mst;
    b_chan_t  b_mst;
    ar_chan_t ar_mst;
    r_chan_t  r_mst;

    `AXI_LITE_ASSIGN_TO_AW(aw_slv, slv);
    `AXI_LITE_ASSIGN_TO_W(w_slv, slv);
    `AXI_LITE_ASSIGN_FROM_B(slv, b_slv);
    `AXI_LITE_ASSIGN_TO_AR(ar_slv, slv);
    `AXI_LITE_ASSIGN_FROM_R(slv, r_slv);

    `AXI_LITE_ASSIGN_FROM_AW(mst, aw_mst);
    `AXI_LITE_ASSIGN_FROM_W(mst, w_mst);
    `AXI_LITE_ASSIGN_TO_B(b_mst, mst);
    `AXI_LITE_ASSIGN_FROM_AR(mst, ar_mst);
    `AXI_LITE_ASSIGN_TO_R(r_mst, mst);

    generate
        if (BYPASS_AW) begin
            assign mst.aw_valid = slv.aw_valid;
            assign slv.aw_ready = mst.aw_ready;
            assign aw_mst = aw_slv;
        end
        else begin
            ADAM_STREAM #(
                .T (aw_chan_t)
            ) aw_slv_intf ();

            assign aw_slv_intf.data = aw_slv;
            assign aw_slv_intf.valid = slv.aw_valid;
            assign slv.aw_ready = aw_slv_intf.ready;

            ADAM_STREAM #(
                .T (aw_chan_t)
            ) aw_mst_intf ();
            
            assign aw_mst = aw_mst_intf.data;
            assign mst.aw_valid = aw_mst_intf.valid;
            assign aw_mst_intf.ready = mst.aw_ready;

            adam_stream_skid #(
                .T (aw_chan_t)
            ) aw_chan_skid (
                .seq (seq),

                .slv (aw_slv_intf),
                .mst (aw_mst_intf)
            );
        end
    endgenerate

    generate
        if (BYPASS_W) begin
            assign mst.w_valid = slv.w_valid;
            assign slv.w_ready = mst.w_ready;
            assign w_mst = w_slv;
        end
        else begin
            ADAM_STREAM #(
                .T (w_chan_t)
            ) w_slv_intf ();

            assign w_slv_intf.data = w_slv;
            assign w_slv_intf.valid = slv.w_valid;
            assign slv.w_ready = w_slv_intf.ready;

            ADAM_STREAM #(
                .T (w_chan_t)
            ) w_mst_intf ();
            
            assign w_mst = w_mst_intf.data;
            assign mst.w_valid = w_mst_intf.valid;
            assign w_mst_intf.ready = mst.w_ready;

            adam_stream_skid #(
                .T (w_chan_t)
            ) w_chan_skid (
                .seq (seq),

                .slv (w_slv_intf),
                .mst (w_mst_intf)
            );
        end
    endgenerate

    generate
        if (BYPASS_B) begin
            assign slv.b_valid = mst.b_valid;
            assign mst.b_ready = slv.b_ready;
            assign b_slv = b_mst;
        end
        else begin
            ADAM_STREAM #(
                .T (b_chan_t)
            ) b_mst_intf ();

            assign b_mst_intf.data = b_mst;
            assign b_mst_intf.valid = mst.b_valid;
            assign mst.b_ready = b_mst_intf.ready;

            ADAM_STREAM #(
                .T (b_chan_t)
            ) b_slv_intf ();
            
            assign b_slv = b_slv_intf.data;
            assign slv.b_valid = b_slv_intf.valid;
            assign b_slv_intf.ready = slv.b_ready;

            adam_stream_skid #(
                .T (b_chan_t)
            ) b_chan_skid (
                .seq (seq),

                .slv (b_mst_intf),
                .mst (b_slv_intf)
            );
        end
    endgenerate

    generate
        if (BYPASS_AR) begin
            assign mst.ar_valid = slv.ar_valid;
            assign slv.ar_ready = mst.ar_ready;
            assign ar_mst = ar_slv;
        end
        else begin
            ADAM_STREAM #(
                .T (ar_chan_t)
            ) ar_slv_intf ();

            assign ar_slv_intf.data = ar_slv;
            assign ar_slv_intf.valid = slv.ar_valid;
            assign slv.ar_ready = ar_slv_intf.ready;

            ADAM_STREAM #(
                .T (ar_chan_t)
            ) ar_mst_intf ();
            
            assign ar_mst = ar_mst_intf.data;
            assign mst.ar_valid = ar_mst_intf.valid;
            assign ar_mst_intf.ready = mst.ar_ready;

            adam_stream_skid #(
                .T (ar_chan_t)
            ) ar_chan_skid (
                .seq (seq),

                .slv (ar_slv_intf),
                .mst (ar_mst_intf)
            );
        end
    endgenerate

    generate
        if (BYPASS_R) begin
            assign slv.r_valid = mst.r_valid;
            assign mst.r_ready = slv.r_ready;
            assign r_slv = r_mst;
        end
        else begin
            ADAM_STREAM #(
                .T (r_chan_t)
            ) r_mst_intf ();

            assign r_mst_intf.data = r_mst;
            assign r_mst_intf.valid = mst.r_valid;
            assign mst.r_ready = r_mst_intf.ready;

            ADAM_STREAM #(
                .T (r_chan_t)
            ) r_slv_intf ();
            
            assign r_slv = r_slv_intf.data;
            assign slv.r_valid = r_slv_intf.valid;
            assign r_slv_intf.ready = slv.r_ready;

            adam_stream_skid #(
                .T (r_chan_t)
            ) r_chan_skid (
                .seq (seq),

                .slv (r_mst_intf),
                .mst (r_slv_intf)
            );
        end
    endgenerate

endmodule