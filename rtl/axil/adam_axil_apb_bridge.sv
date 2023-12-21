/*
This wrapper module serves two primary functions:

1. It is designed to subtract the master address offset in each master
   interface. It only supports one rule per master port.

2. It incorporates the implementation of the pause protocol, allowing for safe
   power and clock gating operations.

It is crucial to ensure that the index (idx) of any rule provided matches with
the corresponding index in the addr_map for that rule. Kindly note that this
restriction is not verified within the wrapper itself. It is the responsibility
of the designer to ensure the correctness of the addr_map configuration
provided.
*/

`include "adam/macros.svh"
`include "axi/typedef.svh"
`include "axi/assign.svh"

module adam_axil_apb_bridge #(
    `ADAM_CFG_PARAMS,

    parameter NO_APBS = 1,

    parameter type RULE_T  = logic
) (
    ADAM_SEQ.Slave   seq,
    ADAM_PAUSE.Slave pause,

    AXI_LITE.Slave axil,
    
    APB.Master apb [NO_APBS],

    input RULE_T [NO_APBS-1:0] addr_map
);
    typedef struct packed {
        ADDR_T paddr;  
        PROT_T pprot;  
        logic  psel;
        logic  penable;
        logic  pwrite;
        DATA_T pwdata;
        STRB_T pstrb;
    } apb_req_t;

    typedef struct packed {
        logic  pready;
        DATA_T prdata;
        logic  pslverr;
    } apb_resp_t;

    `AXI_LITE_TYPEDEF_AW_CHAN_T(aw_chan_t, ADDR_T);
    `AXI_LITE_TYPEDEF_W_CHAN_T(w_chan_t, DATA_T, STRB_T);
    `AXI_LITE_TYPEDEF_B_CHAN_T(b_chan_t);
    `AXI_LITE_TYPEDEF_AR_CHAN_T(ar_chan_t, ADDR_T);
    `AXI_LITE_TYPEDEF_R_CHAN_T(r_chan_t, DATA_T);
    `AXI_LITE_TYPEDEF_REQ_T(axil_req_t, aw_chan_t, w_chan_t, ar_chan_t);
    `AXI_LITE_TYPEDEF_RESP_T(axil_resp_t, b_chan_t, r_chan_t);

    `ADAM_AXIL_I axil_pause ();

    axil_req_t  axil_pause_req;
    axil_resp_t axil_pause_resp;

    apb_req_t  [NO_APBS-1:0] apb_req;
    apb_resp_t [NO_APBS-1:0] apb_resp;

    `AXI_LITE_ASSIGN_TO_REQ(axil_pause_req, axil_pause);
    `AXI_LITE_ASSIGN_FROM_RESP(axil_pause, axil_pause_resp);

    adam_axil_pause #(
        `ADAM_CFG_PARAMS_MAP,

        .MAX_TRANS  (NO_APBS)
    ) adam_axil_pause (
        .seq   (seq),
        .pause (pause),

        .slv (axil),
        .mst (axil_pause)
    );

    axi_lite_to_apb #(
        .NoApbSlaves      (NO_APBS),
        .NoRules          (NO_APBS),
        .AddrWidth        (ADDR_WIDTH),
        .DataWidth        (DATA_WIDTH),
        .PipelineRequest  (1),
        .PipelineResponse (1),
        .axi_lite_req_t   (axil_req_t),
        .axi_lite_resp_t  (axil_resp_t),
        .apb_req_t        (apb_req_t),
        .apb_resp_t       (apb_resp_t),
        .rule_t           (RULE_T)
    ) axi_lite_to_apb (
        .clk_i  (seq.clk),
        .rst_ni (!seq.rst),

        .axi_lite_req_i  (axil_pause_req),
        .axi_lite_resp_o (axil_pause_resp),

        .apb_req_o  (apb_req),
        .apb_resp_i (apb_resp),

        .addr_map_i (addr_map)
    );

    generate
        for (genvar i = 0; i < NO_APBS; i++) begin
            always_comb begin
                apb[i].paddr = apb_req[i].paddr -
                    addr_map[i].start_addr;
                
                apb[i].pprot   = apb_req[i].pprot;
                apb[i].psel    = apb_req[i].psel;
                apb[i].penable = apb_req[i].penable;
                apb[i].pwrite  = apb_req[i].pwrite;
                apb[i].pwdata  = apb_req[i].pwdata;
                apb[i].pstrb   = apb_req[i].pstrb;
            
                apb_resp[i].pready  = apb[i].pready;
                apb_resp[i].prdata  = apb[i].prdata;
                apb_resp[i].pslverr = apb[i].pslverr;
            end
        end
    endgenerate

endmodule