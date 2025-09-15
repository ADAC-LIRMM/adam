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
`include "vunit_defines.svh"

module adam_clk_div_tb;
    
    localparam WIDTH = 1;

    localparam CLK_PERIOD = 5ns;
    localparam RST_CYCLES = 1;

    localparam TA = 1ns;
    localparam TT = CLK_PERIOD - TA;

    ADAM_SEQ mst ();
    ADAM_SEQ slv ();
    
    adam_seq_bhv #(
        .CLK_PERIOD (CLK_PERIOD),
        .RST_CYCLES (RST_CYCLES),

        .TA (TA),
        .TT (TT)
    ) adam_seq_bhv (
        .seq (mst)
    );

    adam_clk_div #(
        .WIDTH (WIDTH)
    ) dut (
        .slv (mst),
        .mst (slv)
    );

    `TEST_SUITE begin
        `TEST_CASE("test") begin
            #200ns;
        end
    end

endmodule