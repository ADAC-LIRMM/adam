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

`include "axi/typedef.svh"
`include "axi/assign.svh"

module adam_axil_apb_bridge #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32,

    parameter NO_APBS = 1,
  
    parameter type rule_t = logic
) (
    input logic clk,
    input logic rst,
    input logic test,

    input logic  pause_req,
    output logic pause_ack,

    AXI_LITE.Slave axil,
    
    APB.Master apb [NO_APBS],

    input rule_t [NO_APBS-1:0] addr_map
);
    
    localparam STRB_WIDTH = DATA_WIDTH/8;

    typedef logic [ADDR_WIDTH-1:0] addr_t;
    typedef logic [DATA_WIDTH-1:0] data_t;
    typedef logic [STRB_WIDTH-1:0] strb_t;

    typedef struct packed {
        addr_t          paddr;  
        axi_pkg::prot_t pprot;  
        logic           psel;
        logic           penable;
        logic           pwrite;
        data_t          pwdata;
        strb_t          pstrb;
    } apb_req_t;

    typedef struct packed {
        logic  pready;
        data_t prdata;
        logic  pslverr;
    } apb_resp_t;

    `AXI_LITE_TYPEDEF_AW_CHAN_T(aw_chan_t, addr_t);
    `AXI_LITE_TYPEDEF_W_CHAN_T(w_chan_t, data_t, strb_t);
    `AXI_LITE_TYPEDEF_B_CHAN_T(b_chan_t);
    `AXI_LITE_TYPEDEF_AR_CHAN_T(ar_chan_t, addr_t);
    `AXI_LITE_TYPEDEF_R_CHAN_T(r_chan_t, data_t);
    `AXI_LITE_TYPEDEF_REQ_T(axil_req_t, aw_chan_t, w_chan_t, ar_chan_t);
    `AXI_LITE_TYPEDEF_RESP_T(axil_resp_t, b_chan_t, r_chan_t);

    AXI_LITE #(
        .AXI_ADDR_WIDTH (ADDR_WIDTH),
        .AXI_DATA_WIDTH (DATA_WIDTH)
    ) axil_pause ();

    axil_req_t  axil_pause_req;
    axil_resp_t axil_pause_resp;

    apb_req_t  [NO_APBS-1:0] apb_req;
    apb_resp_t [NO_APBS-1:0] apb_resp;

    `AXI_LITE_ASSIGN_TO_REQ(axil_pause_req, axil_pause);
    `AXI_LITE_ASSIGN_FROM_RESP(axil_pause, axil_pause_resp);

    adam_axil_pause #(
        .ADDR_WIDTH (ADDR_WIDTH),
        .DATA_WIDTH (DATA_WIDTH),

        .MAX_TRANS  (NO_APBS)
    ) adam_axil_pause (
        .clk  (clk),
        .rst  (rst),
        .test (test),

        .pause_req (pause_req),
        .pause_ack (pause_ack), 

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
        .rule_t           (rule_t)
    ) axi_lite_to_apb (
        .clk_i  (clk),
        .rst_ni (!rst),

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