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

module adam_clk_div #(
    parameter WIDTH = 2
) (
    ADAM_SEQ.Slave  slv,
    ADAM_SEQ.Master mst
);

    logic [WIDTH-1:0] counter = 'b0;

    assign mst.clk = counter[WIDTH-1];
    assign mst.rst = slv.rst;

    // initial counter = 0;

    always_ff @(posedge slv.clk) begin
        counter <= counter + 1;
    end

endmodule