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

`timescale 1ns/1ps
`include "adam/macros_bhv.svh"
`include "axi/assign.svh"
`include "vunit_defines.svh"

module adam_axil_skid_tb;
    import adam_axil_mst_bhv::*;
    import adam_axil_slv_bhv::*;

    `ADAM_BHV_CFG_LOCALPARAMS;

    localparam MAX_TRANS = 1;

    ADAM_SEQ seq();

    `ADAM_AXIL_I mst ();

    `ADAM_AXIL_DV_I mst_dv (seq.clk);

    `AXI_LITE_ASSIGN(mst, mst_dv);

    adam_axil_mst_bhv #(
        `ADAM_BHV_CFG_PARAMS_MAP,
        
        .MAX_TRANS (MAX_TRANS)
    ) mst_bhv;

    `ADAM_AXIL_I slv ();

    `ADAM_AXIL_DV_I slv_dv(seq.clk);

    `AXI_LITE_ASSIGN(slv_dv, slv);

    adam_axil_slv_bhv #(
        `ADAM_BHV_CFG_PARAMS_MAP,
        
        .MAX_TRANS (MAX_TRANS)
    ) slv_bhv;

    adam_seq_bhv #(
        `ADAM_BHV_CFG_PARAMS_MAP
    ) adam_seq_bhv (
        .seq(seq)
    );

    adam_axil_skid #(
        `ADAM_CFG_PARAMS_MAP,

        .BYPASS_AW (0),
        .BYPASS_W  (0),
        .BYPASS_B  (0),
        .BYPASS_AR (0),
        .BYPASS_R  (0)
    ) dut (
        .seq (seq),

        .slv (mst),
        .mst (slv)
    );

    initial begin
        mst_bhv = new(mst_dv);
        mst_bhv.loop();
    end

    initial begin
        slv_bhv = new(slv_dv);
        slv_bhv.loop();
    end

    `TEST_SUITE begin
        `TEST_CASE("basic") begin
            automatic ADDR_T addr = $urandom();
            automatic PROT_T prot = 3'b000;
            automatic DATA_T data = $urandom();
            automatic STRB_T strb = 4'b1111;
            automatic RESP_T resp = 2'b00;

            @(negedge seq.rst);
            @(posedge seq.clk);
            
            mst_bhv.send_aw(addr, prot);
            slv_bhv.recv_aw(addr, prot);

            mst_bhv.send_w(addr, strb);
            slv_bhv.recv_w(addr, strb);
        
            slv_bhv.send_b(resp);
            mst_bhv.recv_b(resp);

            mst_bhv.send_ar(addr, prot);
            slv_bhv.recv_ar(addr, prot);

            slv_bhv.send_r(data, resp);
            mst_bhv.recv_r(data, resp);
        end

        `TEST_CASE("stall") begin            
            automatic ADDR_T addr;
            automatic PROT_T prot;
            automatic DATA_T data;
            automatic STRB_T strb;
            automatic RESP_T resp;
            
            addr = '0;
            prot = 3'b000;
            data = '0;
            strb = 4'b1111;
            resp = 2'b00;

            @(negedge seq.rst);
            @(posedge seq.clk);

            repeat (2) mst_bhv.send_aw(addr, prot);
            @(negedge mst.aw_ready);
            repeat (2) slv_bhv.recv_aw(addr, prot);
            
            repeat (2) mst_bhv.send_w(addr, strb);
            @(negedge mst.w_ready);
            repeat (2) slv_bhv.recv_w(addr, strb);
            
            repeat (2) slv_bhv.send_b(resp);
            @(negedge slv.b_ready);
            repeat (2) mst_bhv.recv_b(resp);

            repeat (2) mst_bhv.send_ar(addr, prot);
            @(negedge mst.ar_ready);
            repeat (2) slv_bhv.recv_ar(addr, prot);

            repeat (2) slv_bhv.send_r(data, resp);
            @(negedge slv.r_ready);
            repeat (2) mst_bhv.recv_r(data, resp);
        end
    end

    initial begin
        #100us $error("timeout");
    end

endmodule
