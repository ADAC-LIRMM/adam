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

module adam_pause_mux #(
    parameter NO_SLVS = 2
) (
    ADAM_SEQ.Slave   seq,

    ADAM_PAUSE.Slave  deferred,
    ADAM_PAUSE.Slave  slv [NO_SLVS+1],
    ADAM_PAUSE.Master mst
);

    logic slv_req [NO_SLVS+1];
    logic slv_ack [NO_SLVS+1];

    logic ready;

    generate
        for (genvar i = 0; i < NO_SLVS; i++) begin
            assign slv_req[i] = slv[i].req;
            assign slv[i].ack = slv_ack[i]; 
        end
    endgenerate

    always_comb begin
        mst.req = 0;
        for (int i = 0; i < NO_SLVS; i++) begin
            mst.req |= slv_req[i];
            slv_ack[i] = mst.ack;
        end

        if(deferred.req) begin
            deferred.ack = mst.req && mst.ack;
        end
        else begin
            deferred.ack = mst.req || mst.ack;
        end
    end

endmodule