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

module adam_axil_xbar #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32,

    parameter NO_SLAVES  = 2,
    parameter NO_MASTERS = 2,
    
    parameter MAX_TRANS = 7,

    parameter type rule_t = logic
) (
    input logic clk,
    input logic rst,
    input logic test,
    
    input  logic pause_req,
    output logic pause_ack,

    AXI_LITE.Slave  axil_slv [NO_SLAVES],
    AXI_LITE.Master axil_mst [NO_MASTERS],

    input rule_t [NO_MASTERS-1:0] addr_map
);

    localparam STRB_WIDTH = DATA_WIDTH/8;

    localparam axi_pkg::xbar_cfg_t CFG = '{
        NoSlvPorts:   NO_SLAVES,
        NoMstPorts:   NO_MASTERS,
        MaxMstTrans:  MAX_TRANS,
        MaxSlvTrans:  MAX_TRANS,
        FallThrough:  0,
        LatencyMode:  axi_pkg::CUT_ALL_AX,
        AxiAddrWidth: ADDR_WIDTH,
        AxiDataWidth: DATA_WIDTH,
        NoAddrRules:  NO_MASTERS,
        default:      0
    };

    typedef logic [ADDR_WIDTH-1:0] addr_t;
    typedef logic [DATA_WIDTH-1:0] data_t;
    typedef logic [STRB_WIDTH-1:0] strb_t;

    `AXI_LITE_TYPEDEF_AW_CHAN_T(aw_chan_t, addr_t);
    `AXI_LITE_TYPEDEF_W_CHAN_T(w_chan_t, data_t, strb_t);
    `AXI_LITE_TYPEDEF_B_CHAN_T(b_chan_t);
    `AXI_LITE_TYPEDEF_AR_CHAN_T(ar_chan_t, addr_t);
    `AXI_LITE_TYPEDEF_R_CHAN_T(r_chan_t, data_t);
    `AXI_LITE_TYPEDEF_REQ_T(axil_req_t, aw_chan_t, w_chan_t, ar_chan_t);
    `AXI_LITE_TYPEDEF_RESP_T(axil_resp_t, b_chan_t, r_chan_t);

    logic slave_pause_req [NO_SLAVES];
    logic slave_pause_ack [NO_SLAVES];

    axil_req_t  [NO_MASTERS-1:0] axil_mst_req;
    axil_resp_t [NO_MASTERS-1:0] axil_mst_resp;
    axil_req_t  [NO_SLAVES-1:0]  axil_slv_req;
    axil_resp_t [NO_SLAVES-1:0]  axil_slv_resp;

    AXI_LITE #(
        .AXI_ADDR_WIDTH (ADDR_WIDTH),
        .AXI_DATA_WIDTH (DATA_WIDTH)
    ) axil_pause [NO_MASTERS] ();

    generate
        for (genvar i = 0; i < NO_SLAVES; i++) begin
            adam_axil_pause #(
                .ADDR_WIDTH (ADDR_WIDTH),
                .DATA_WIDTH (DATA_WIDTH),

                .MAX_TRANS  (MAX_TRANS)
            ) adam_axil_pause (
                .clk  (clk),
                .rst  (rst),
                .test (test),

                .pause_req (slave_pause_req[i]),
                .pause_ack (slave_pause_ack[i]), 

                .slv (axil_slv[i]),
                .mst (axil_pause[i])
            );

            `AXI_LITE_ASSIGN_TO_REQ(axil_slv_req[i], axil_pause[i]);
            `AXI_LITE_ASSIGN_FROM_RESP(axil_pause[i], axil_slv_resp[i]);
        end

        for (genvar i = 0; i < NO_MASTERS; i++) begin
            assign axil_mst[i].aw_addr = axil_mst_req[i].aw.addr -
                addr_map[i].start_addr;
            
            assign axil_mst[i].ar_addr = axil_mst_req[i].ar.addr -
                addr_map[i].start_addr;

            assign axil_mst[i].aw_prot  = axil_mst_req[i].aw.prot;
            assign axil_mst[i].aw_valid = axil_mst_req[i].aw_valid;
            assign axil_mst[i].w_data   = axil_mst_req[i].w.data;
            assign axil_mst[i].w_strb   = axil_mst_req[i].w.strb;
            assign axil_mst[i].w_valid  = axil_mst_req[i].w_valid;
            assign axil_mst[i].b_ready  = axil_mst_req[i].b_ready;
            assign axil_mst[i].ar_prot  = axil_mst_req[i].ar.prot;
            assign axil_mst[i].ar_valid = axil_mst_req[i].ar_valid;
            assign axil_mst[i].r_ready  = axil_mst_req[i].r_ready;

            `AXI_LITE_ASSIGN_TO_RESP(axil_mst_resp[i], axil_mst[i]);
        end
    endgenerate
    
    axi_lite_xbar #(
        .Cfg        (CFG),
        .aw_chan_t  (aw_chan_t),
        .w_chan_t   (w_chan_t),
        .b_chan_t   (b_chan_t),
        .ar_chan_t  (ar_chan_t),
        .r_chan_t   (r_chan_t),
        .axi_req_t  (axil_req_t),
        .axi_resp_t (axil_resp_t),
        .rule_t     (rule_t)
    ) axi_lite_xbar (
        .clk_i  (clk),
        .rst_ni (!rst),
        .test_i ('0),
        
        .slv_ports_req_i  (axil_slv_req),
        .slv_ports_resp_o (axil_slv_resp),
        .mst_ports_req_o  (axil_mst_req),
        .mst_ports_resp_i (axil_mst_resp),
        
        .addr_map_i (addr_map),
        
        .en_default_mst_port_i ('0),
        .default_mst_port_i    ('0)
    );

    always_comb begin
        for (int i = 0; i < NO_SLAVES; i++) begin
            slave_pause_req[i] = pause_req;
        end

        if (pause_req) begin
            pause_ack = 1;
            for (int i = 0; i < NO_SLAVES; i++) begin
                pause_ack &= slave_pause_ack[i];
            end
        end
        else begin
            pause_ack = 0;
            for (int i = 0; i < NO_SLAVES; i++) begin
                pause_ack |= slave_pause_ack[i];
            end
        end
    end
endmodule