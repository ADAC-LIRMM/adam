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

module adam_pause_demux #(
    `ADAM_CFG_PARAMS,

    parameter NO_MSTS  = 8,
    parameter PARALLEL = 0
) (
    ADAM_SEQ.Slave   seq,

    ADAM_PAUSE.Slave  slv,
    ADAM_PAUSE.Master mst [NO_MSTS+1]
);
    logic slv_req;
    logic slv_ack;

    logic mst_req [NO_MSTS+1];
    logic mst_ack [NO_MSTS+1];

    generate
        assign slv_req = slv.req;
        assign slv.ack = slv_ack;

        for (genvar i = 0; i < NO_MSTS; i++) begin
            assign mst[i].req = mst_req[i];
            assign mst_ack[i] = mst[i].ack;
        end    
    
        if (PARALLEL) begin
            for (genvar i = 0; i < NO_MSTS; i++) begin
                assign mst_req[i] = slv_req;
            end
        end
        else begin
            always_ff @(posedge seq.clk) begin
                if (seq.rst) begin
                    for (int i = 0; i < NO_MSTS; i++) begin
                        mst_req[i] <= 1;
                    end
                end
                else if (slv_req && slv_ack) begin
                    // PAUSED
                end
                else if (slv_req) begin
                    mst_req[0] <= 1;
                    for (int i = 1; i < NO_MSTS; i++) begin
                        mst_req[i] <= (mst_req[i-1] && mst_ack[i-1]);
                    end
                end
                else begin
                    mst_req[NO_MSTS-1] <= 0;
                    for (int i = 0; i < NO_MSTS-1; i++) begin
                        mst_req[i] <= (mst_req[i+1] || mst_ack[i+1]);
                    end
                end
            end
        end
    endgenerate

    always_comb begin
        if (slv_req) begin
            slv_ack = 1;
            for (int i = 0; i < NO_MSTS; i++) begin
                slv_ack &= mst_ack[i];
            end
        end
        else begin
            slv_ack = 0;
            for (int i = 0; i < NO_MSTS; i++) begin
                slv_ack |= mst_ack[i];
            end
        end
    end
endmodule