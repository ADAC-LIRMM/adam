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

module adam_pause_bhv #(
    `ADAM_BHV_CFG_PARAMS,

    parameter DELAY    = 1us,
    parameter DURATION = 1us
) (
    ADAM_SEQ.Slave    seq,
    ADAM_PAUSE.Master pause
);

    initial begin
        forever begin
            pause.req = 1;

            `ADAM_UNTIL_DO(!seq.rst, assert(pause.ack));

            pause.req <= #TA 0;
            `ADAM_UNTIL(!pause.ack);

            repeat (DELAY / (TA + TT)) begin
                `ADAM_UNTIL(1); // assert(!pause.ack));
            end

            pause.req <= #TA 1;
            `ADAM_UNTIL(pause.ack);
  
            repeat (DURATION / (TA + TT)) begin
                `ADAM_UNTIL_DO(1, assert(pause.ack));
            end
            
            pause.req <= #TA 0;
            `ADAM_UNTIL(!pause.ack);

            `ADAM_UNTIL(seq.rst);
        end
    end

    task cycle_start();
        #TT;
    endtask

    task cycle_end();
        @(posedge seq.clk);
    endtask

endmodule