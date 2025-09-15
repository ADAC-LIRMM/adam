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

package adam_stream_slv_bhv;

class adam_stream_slv_bhv #(
    `ADAM_BHV_CFG_PARAMS,

    parameter MAX_TRANS = 4,

    parameter type T = logic
);

    typedef virtual ADAM_STREAM_DV #(
        .T (T)
    ) dv_t;

    T queue [$];
    dv_t   dv;

    function new(
        dv_t dv
    );
        this.dv = dv;
    endfunction

    task recv(
        output T data
    );
        while (queue.size() == 0) begin
            cycle_start();
            cycle_end();
        end
        
        data = queue.pop_back();
    endtask

    task loop();
        logic  start_transfer;
        logic  end_transfer;

        // init value
        dv.ready = '0;

        forever begin
            cycle_start();
            
            end_transfer = dv.valid && dv.ready;
            
            if (end_transfer) begin
                queue.push_front(dv.data);
            end

            start_transfer = (queue.size() < MAX_TRANS);

            cycle_end();
            
            if (end_transfer) begin
                dv.ready <= #TA 0;
            end
            
            if (start_transfer) begin
                dv.ready <= #TA 1;
            end
        end
    endtask

    task cycle_start();
        #TT;
    endtask

    task cycle_end();
        @(posedge dv.clk);
    endtask

endclass

endpackage
