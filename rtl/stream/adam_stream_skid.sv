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

module adam_stream_skid #(
    parameter type T = logic
) (
    ADAM_SEQ.Slave seq,

    ADAM_STREAM.Slave  slv,
    ADAM_STREAM.Master mst
);
    logic stall;
    T     buffer;

    always_comb begin
        mst.data  = (stall) ? buffer : slv.data;
        mst.valid = slv.valid || stall;
    end

    always_ff @(posedge seq.clk) begin
        
        if (seq.rst) begin
            stall     <= '0;
            buffer    <= '0;
            slv.ready <= '0;
        end 
        else begin
            slv.ready <= !stall || mst.ready;

            if (slv.valid && slv.ready && mst.valid && !mst.ready) begin
                stall     <= '1; 
                buffer    <= slv.data;
                slv.ready <= '0;
            end

            if (stall && mst.valid && mst.ready) begin
                stall     <= '0;
                buffer    <= '0;
                slv.ready <= '1;
            end
        end
    end

endmodule