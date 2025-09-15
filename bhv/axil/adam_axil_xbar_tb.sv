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

module adam_axil_xbar_tb;
    import adam_axil_mst_bhv::*;
    import adam_axil_slv_bhv::*;

    `ADAM_BHV_CFG_LOCALPARAMS;
    
    localparam NO_XBAR_SLVS = 4;
    localparam NO_XBAR_MSTS = 4;

    localparam MAX_TRANS = 7;

    localparam NO_TESTS = 1000;

    typedef struct packed {
        ADDR_T start;
        ADDR_T end_;
    } rule_t;
    
    integer done;

    ADAM_SEQ   seq   ();
    ADAM_PAUSE pause ();

    rule_t addr_map [NO_XBAR_SLVS+1];

    `ADAM_AXIL_I mst [NO_XBAR_SLVS+1] ();
    `ADAM_AXIL_I slv [NO_XBAR_MSTS+1] ();

    `ADAM_AXIL_DV_I mst_dv [NO_XBAR_SLVS+1] (seq.clk);
    `ADAM_AXIL_DV_I slv_dv [NO_XBAR_MSTS+1] (seq.clk);

    adam_axil_mst_bhv #(
        `ADAM_BHV_CFG_PARAMS_MAP,

        .MAX_TRANS (MAX_TRANS)
    ) mst_bhv [NO_XBAR_SLVS+1];

    adam_axil_slv_bhv #(
        `ADAM_BHV_CFG_PARAMS_MAP,

        .MAX_TRANS (MAX_TRANS)
    ) slv_bhv [NO_XBAR_MSTS+1];

    generate
        for (genvar i = 0; i < NO_XBAR_SLVS; i++) begin
            `AXI_LITE_ASSIGN(mst[i], mst_dv[i]);

            initial begin
                mst_bhv[i] = new(mst_dv[i]);
                mst_bhv[i].loop();
            end
        end

        for (genvar i = 0; i < NO_XBAR_MSTS; i++) begin
            `AXI_LITE_ASSIGN(slv_dv[i], slv[i]);

            initial begin
                slv_bhv[i] = new(slv_dv[i]);
                slv_bhv[i].loop();
            end
        end
    endgenerate

    always_comb begin
        for (int i = 0; i < NO_XBAR_MSTS; i++) begin
            addr_map[i] = '{
                start : (i     << 16),
                end_  : ((i+1) << 16)
            };
        end
    end

    adam_seq_bhv #(
        `ADAM_BHV_CFG_PARAMS_MAP
    ) adam_seq_bhv (
        .seq (seq)
    );
    
    adam_pause_bhv #(
        `ADAM_BHV_CFG_PARAMS_MAP,

        .DELAY    (10us),
        .DURATION (10us)
    ) adam_pause_bhv (
        .seq   (seq),
        .pause (pause)
    );

    adam_axil_xbar #(
        `ADAM_CFG_PARAMS_MAP,

        .NO_SLVS (NO_XBAR_SLVS),
        .NO_MSTS (NO_XBAR_MSTS),
        
        .MAX_TRANS (MAX_TRANS),

        .RULE_T (rule_t)
    ) dut (
        .seq   (seq),
        .pause (pause),

        .slv (mst),
        .mst (slv),

        .addr_map (addr_map)
    );

    `TEST_SUITE begin
        `TEST_CASE("test") begin
            done = 0;

            @(negedge seq.rst); 
            @(posedge seq.clk);

            cycle_start();
            while (done < NO_XBAR_SLVS) begin
                cycle_end();
                cycle_start();
            end
            cycle_end();
        end
    end

    initial begin
        #1000us $error("timeout");
    end

    generate
        for (genvar i = 0; i < NO_XBAR_SLVS; i++) begin
            initial begin
                automatic ADDR_T addr_high;
                automatic ADDR_T addr_low;
                automatic ADDR_T addr;
                automatic DATA_T data;
                automatic RESP_T resp;

                @(negedge seq.rst); 
                @(posedge seq.clk);

                for (int j = 0; j < NO_TESTS; j++) begin
                    addr_high = i << 16;
                    addr_low  = $urandom_range(0, 32'hFFFF);
                    addr = addr_high | addr_low;
                    
                    if($urandom_range(0, 1)) begin
                        data = addr_low;

                        fork
                            mst_bhv[i].send_aw(addr, 3'b000);
                            mst_bhv[i].send_w(addr, 4'b1111);
                            mst_bhv[i].recv_b(resp);
                        join

                        assert (resp == axi_pkg::RESP_OKAY); 
                    end
                    else begin
                        fork
                            mst_bhv[i].send_ar(addr, 3'b000);
                            mst_bhv[i].recv_r(data, resp);
                        join

                        assert (resp == axi_pkg::RESP_OKAY);
                        assert (data == i);
                    end
                end

                done += 1;
            end
        end

        for (genvar i = 0; i < NO_XBAR_MSTS; i++) begin
            initial begin
                automatic ADDR_T addr;
                automatic PROT_T prot;
                automatic DATA_T data;
                automatic STRB_T strb;
                automatic RESP_T resp;

                @(negedge seq.rst); 
                @(posedge seq.clk);

                resp = axi_pkg::RESP_OKAY;

                for (int j = 0; j < NO_TESTS; j++) begin
                    fork
                        slv_bhv[i].recv_aw(addr, prot);
                        slv_bhv[i].recv_w(data, strb);
                    join
    
                    assert ((data >> 16) == i);
                    
                    slv_bhv[i].send_b(resp);
                end
            end

            initial begin
                automatic ADDR_T addr;
                automatic PROT_T prot;
                automatic DATA_T data;
                automatic STRB_T strb;
                automatic RESP_T resp;

                @(negedge seq.rst); 
                @(posedge seq.clk);

                resp = axi_pkg::RESP_OKAY;

                for (int j = 0; j < NO_TESTS; j++) begin    
                    slv_bhv[i].recv_ar(addr, prot);
                    data = (addr >> 16);
                    slv_bhv[i].send_r(data, resp);
                end
            end
        end
    endgenerate

    task cycle_start();
        #TT;
    endtask

    task cycle_end();
        @(posedge seq.clk);
    endtask

endmodule