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
`include "axi/assign.svh"

module adam_fabric_lspx #(
    `ADAM_CFG_PARAMS,

    parameter NO_MSTS = 8,
    parameter INC     = 1024
) (
    ADAM_SEQ.Slave   seq,
    ADAM_PAUSE.Slave pause,

    AXI_LITE.Slave slv,
    APB.Master     mst [NO_MSTS+1]
);    
    
    localparam type RULE_T = adam_cfg_pkg::MMAP_T;
    
    RULE_T addr_map [NO_MSTS+1];

    always_comb begin
        for (int i = 0; i < NO_MSTS; i++) begin
            addr_map[i] = '{
                start : INC*i,
                end_  : INC*(i+1),
                inc   : '0
            };
        end
    end

    adam_axil_apb_bridge #(
        `ADAM_CFG_PARAMS_MAP,

        .NO_MSTS   (NO_MSTS),
        .MAX_TRANS (1),

        .RULE_T (RULE_T)
    ) adam_axil_apb_bridge (
        .seq   (seq),
        .pause (pause),

        .slv (slv),
        .mst (mst),

        .addr_map (addr_map)
    );

endmodule