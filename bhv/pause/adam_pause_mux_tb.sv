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
`include "vunit_defines.svh"

module adam_pause_mux_tb;

    `ADAM_BHV_CFG_LOCALPARAMS;

    parameter NO_MSTS  = 2;

    // seq ====================================================================
    
    ADAM_SEQ   seq   ();
    ADAM_PAUSE pause ();
    
    adam_seq_bhv #(
        `ADAM_BHV_CFG_PARAMS_MAP
    ) adam_seq_bhv (
        .seq (seq)
    );

    // pause mst bhv ==========================================================

    ADAM_PAUSE deferred ();
    ADAM_PAUSE mst [NO_MSTS+1] ();
    
    generate
        adam_pause_bhv #(
            `ADAM_BHV_CFG_PARAMS_MAP,

            .DELAY    (40us),
            .DURATION (100us)
        ) deferred_bhv (
            .seq   (seq),
            .pause (deferred)
        );

        for (genvar i = 0; i < NO_MSTS; i++) begin
            adam_pause_bhv #(
                `ADAM_BHV_CFG_PARAMS_MAP,

                .DELAY    (45us),
                .DURATION (50us)
            ) mst_bhv (
                .seq   (seq),
                .pause (mst[i])
            );
        end
    endgenerate

    // any_req ================================================================

    logic any_req;
    logic mst_req [NO_MSTS+1];

    generate
        for (genvar i = 0; i < NO_MSTS; i++) begin
            assign mst_req[i] = mst[i].req;
        end
    endgenerate

    always_comb begin
        any_req = 0; //deferred.req;
        for (int i = 0; i < NO_MSTS; i++) begin
            any_req |= mst_req[i];
        end
    end
    
    // dut ====================================================================

    ADAM_PAUSE slv ();

    adam_pause_mux #(
        .NO_SLVS (NO_MSTS)
    ) dut (
        .seq      (seq),

        .deferred (deferred),
        .slv      (mst),
        .mst      (slv)
    );

    // test ===================================================================

    `TEST_SUITE begin
        `TEST_CASE("test") begin
            slv.ack = 1;

            // wait for reset
            `ADAM_UNTIL_DO(!seq.rst, assert(slv.req));

            // resume
            `ADAM_UNTIL(!slv.req);
            slv.ack <= #TA 0;

            // + deffered.req
            `ADAM_UNTIL_DO_FINNALY(deferred.req, begin
                assert(!any_req);
                assert(!deferred.ack);
            end, begin
                assert(!any_req);
                assert(!deferred.ack);
            end);

            // + any_req
            `ADAM_UNTIL_FINNALY(deferred.req && any_req, assert(slv.req));
            slv.ack <= #TA 1;

            // - deffered.req
            `ADAM_UNTIL_FINNALY(!deferred.req && !any_req, assert(!slv.req));
            slv.ack <= #TA 0;

            // idle
            repeat (10) `ADAM_UNTIL(1);
        end
    end

    initial begin
        #1000us $error("timeout");
    end

    task cycle_start();
        #TT;
    endtask

    task cycle_end();
        @(posedge seq.clk);
    endtask

endmodule
