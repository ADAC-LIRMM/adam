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

module cv32e40x_clock_gate #(
    parameter LIB = 0
) (
    input  logic clk_i,
    input  logic en_i,
    input  logic scan_cg_en_i,
    output logic clk_o
);

    ADAM_SEQ slv ();
    ADAM_SEQ mst ();

    assign slv.clk = clk_i;
    assign slv.rst = '0;

    assign clk_o = mst.clk;

    adam_clk_gate adam_clk_gate (
        .slv (slv),
        .mst (mst),

        .enable (en_i)
    );

endmodule

