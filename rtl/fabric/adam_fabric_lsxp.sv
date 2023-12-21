`include "axi/assign.svh"

module adam_fabric_lsxp #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32,

    parameter NO_MSTS = 8,

    // Dependent parameters bellow, do not override.

    parameter STRB_WIDTH  = DATA_WIDTH/8,

    parameter type addr_t = logic [ADDR_WIDTH-1:0],
    parameter type data_t = logic [DATA_WIDTH-1:0],
    parameter type strb_t = logic [STRB_WIDTH-1:0]
) (
    ADAM_SEQ.Slave   seq,
    ADAM_PAUSE.Slave pause,

    AXI_LITE.Slave slv,
    APB.Master     msts [NO_MSTS]
);    
    
    typedef struct packed {
        int unsigned idx;
        addr_t start_addr;
        addr_t end_addr;
    } rule_t;

    rule_t [NO_MSTS-1:0] addr_map;

    always_comb begin
        for (int i = 0; i < NO_MSTS; i++) begin
            addr_map[i] = '{
                idx: i,
                start_addr: 1024*i,
                end_addr:   1024*(i+1)
            };
        end
    end

    adam_axil_apb_bridge #(
        .ADDR_WIDTH (ADDR_WIDTH),
        .DATA_WIDTH (DATA_WIDTH),

        .NO_APBS (NO_MSTS),
    
        .RULE_T (rule_t)
    ) adam_axil_apb_bridge (
        .seq   (seq),
        .pause (pause),

        .axil (slv),
        
        .apb (msts),

        .addr_map (addr_map)
    );

endmodule