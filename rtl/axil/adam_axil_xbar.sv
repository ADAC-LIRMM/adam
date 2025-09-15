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
`include "axi/typedef.svh"
`include "axi/assign.svh"

module adam_axil_xbar #(
    `ADAM_CFG_PARAMS,

    parameter NO_SLVS = 2,
    parameter NO_MSTS = 2,
    
    parameter MAX_TRANS = 7,

    parameter type RULE_T = logic
) (
    ADAM_SEQ.Slave   seq,
    ADAM_PAUSE.Slave pause,

    AXI_LITE.Slave  slv [NO_SLVS+1],
    AXI_LITE.Master mst [NO_MSTS+1],

    input RULE_T addr_map [NO_MSTS+1]
);
    
    // pause ==================================================================

    ADAM_PAUSE   slv_pause       [NO_SLVS+1] ();
    `ADAM_AXIL_I slv_after_pause [NO_SLVS+1] ();

    generate
        for (genvar i = 0; i < NO_SLVS; i++) begin
            adam_axil_pause #(
                `ADAM_CFG_PARAMS_MAP,

                .MAX_TRANS  (MAX_TRANS)
            ) adam_axil_pause (
                .seq   (seq),
                .pause (slv_pause[i]),

                .slv (slv[i]),
                .mst (slv_after_pause[i])
            );
        end
    endgenerate
    
    adam_pause_demux #(
        `ADAM_CFG_PARAMS_MAP,

        .NO_MSTS  (NO_SLVS),
        .PARALLEL (1)
    ) adam_pause_demux (
        .seq (seq),

        .slv (pause),
        .mst (slv_pause)
    );

    // phy ====================================================================

    typedef struct packed {
        int unsigned idx;
        ADDR_T start_addr;
        ADDR_T end_addr;
    } phy_rule_t;

    `AXI_LITE_TYPEDEF_AW_CHAN_T(aw_chan_t, ADDR_T);
    `AXI_LITE_TYPEDEF_W_CHAN_T(w_chan_t, DATA_T, STRB_T);
    `AXI_LITE_TYPEDEF_B_CHAN_T(b_chan_t);
    `AXI_LITE_TYPEDEF_AR_CHAN_T(ar_chan_t, ADDR_T);
    `AXI_LITE_TYPEDEF_R_CHAN_T(r_chan_t, DATA_T);
    `AXI_LITE_TYPEDEF_REQ_T(req_t, aw_chan_t, w_chan_t, ar_chan_t);
    `AXI_LITE_TYPEDEF_RESP_T(resp_t, b_chan_t, r_chan_t);

    generate
        if (NO_MSTS > 0 && NO_SLVS > 0) begin
            localparam axi_pkg::xbar_cfg_t PHY_CFG = '{
                NoSlvPorts:   NO_SLVS,
                NoMstPorts:   NO_MSTS,
                MaxMstTrans:  MAX_TRANS,
                MaxSlvTrans:  MAX_TRANS,
                FallThrough:  0,
                LatencyMode:  axi_pkg::CUT_ALL_AX,
                AxiAddrWidth: ADDR_WIDTH,
                AxiDataWidth: DATA_WIDTH,
                NoAddrRules:  NO_MSTS,
                default:      0
            };

            req_t  [NO_SLVS-1:0] slv_req;
            resp_t [NO_SLVS-1:0] slv_resp;
            req_t  [NO_MSTS-1:0] mst_req;
            resp_t [NO_MSTS-1:0] mst_resp;
            
            phy_rule_t [NO_MSTS-1:0] phy_addr_map;

            for (genvar i = 0; i < NO_SLVS; i++) begin
                `AXI_LITE_ASSIGN_TO_REQ(slv_req[i], slv_after_pause[i]);
                `AXI_LITE_ASSIGN_FROM_RESP(slv_after_pause[i], slv_resp[i]);
            end

            for (genvar i = 0; i < NO_MSTS; i++) begin
                `AXI_LITE_ASSIGN_FROM_REQ(mst[i], mst_req[i]);
                `AXI_LITE_ASSIGN_TO_RESP(mst_resp[i], mst[i]);

                assign phy_addr_map[i] = '{
                    idx: i,
                    start_addr: addr_map[i].start,
                    end_addr:   addr_map[i].end_
                };
            end
 
            axi_lite_xbar #(
                .Cfg        (PHY_CFG),
                .aw_chan_t  (aw_chan_t),
                .w_chan_t   (w_chan_t),
                .b_chan_t   (b_chan_t),
                .ar_chan_t  (ar_chan_t),
                .r_chan_t   (r_chan_t),
                .axi_req_t  (req_t),
                .axi_resp_t (resp_t),
                .rule_t     (phy_rule_t)
            ) phy (
                .clk_i  (seq.clk),
                .rst_ni (!seq.rst),
                .test_i ('0),
                
                .slv_ports_req_i  (slv_req),
                .slv_ports_resp_o (slv_resp),
                .mst_ports_req_o  (mst_req),
                .mst_ports_resp_i (mst_resp),
                
                .addr_map_i (phy_addr_map),
                
                .en_default_mst_port_i ('0),
                .default_mst_port_i    ('0)
            );
        end
        else begin
            for (genvar i = 0; i < NO_SLVS; i++) begin
                `ADAM_AXIL_SLV_TIE_OFF(slv_after_pause[i]);
            end

            for (genvar i = 0; i < NO_MSTS; i++) begin
                `ADAM_AXIL_MST_TIE_OFF(mst[i]);
            end
        end
    endgenerate
    
endmodule