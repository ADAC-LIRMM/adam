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
                end_  : INC*(i+1)
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