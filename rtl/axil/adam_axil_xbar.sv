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

    parameter NO_SLVS = 2,
    parameter NO_MSTS = 2,
    
    parameter MAX_TRANS = 7,

    parameter type rule_t = logic
) (
    ADAM_SEQ.Slave   seq,
    ADAM_PAUSE.Slave pause,

    AXI_LITE.Slave  axil_slvs [NO_SLVS],
    AXI_LITE.Master axil_msts [NO_MSTS],

    input rule_t [NO_MSTS-1:0] addr_map
);

    localparam STRB_WIDTH = DATA_WIDTH/8;

    localparam axi_pkg::xbar_cfg_t CFG = '{
        NoSlvPorts:   NO_SLVS,
        NoMstPorts:   NO_MSTS,
        MaxMstTrans:  MAX_TRANS,
        MaxSlvTrans:  MAX_TRANS,
        FallThrough:  0,
        LatencyMode:  axi_pkg::CUT_ALL_AX,
        AxiAddrWidth: ADDR_WIDTH,
        AxiDataWidth: DATA_WIDTH,
        NoAddrRules:  NO_MSTS,
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

    ADAM_PAUSE slave_pause [NO_SLVS] ();

    axil_req_t  [NO_MSTS-1:0] axil_msts_req;
    axil_resp_t [NO_MSTS-1:0] axil_msts_resp;
    axil_req_t  [NO_SLVS-1:0] axil_slvs_req;
    axil_resp_t [NO_SLVS-1:0] axil_slvs_resp;

    AXI_LITE #(
        .AXI_ADDR_WIDTH (ADDR_WIDTH),
        .AXI_DATA_WIDTH (DATA_WIDTH)
    ) axil_pause [NO_SLVS] ();

    generate
        for (genvar i = 0; i < NO_SLVS; i++) begin
            adam_axil_pause #(
                .ADDR_WIDTH (ADDR_WIDTH),
                .DATA_WIDTH (DATA_WIDTH),

                .MAX_TRANS  (MAX_TRANS)
            ) adam_axil_pause (
                .seq   (seq),
                .pause (slave_pause[i]),

                .slv (axil_slvs[i]),
                .mst (axil_pause[i])
            );

            `AXI_LITE_ASSIGN_TO_REQ(axil_slvs_req[i], axil_pause[i]);
            `AXI_LITE_ASSIGN_FROM_RESP(axil_pause[i], axil_slvs_resp[i]);
        end

        for (genvar i = 0; i < NO_MSTS; i++) begin
            `AXI_LITE_ASSIGN_FROM_REQ(axil_msts[i], axil_msts_req[i]);
            `AXI_LITE_ASSIGN_TO_RESP(axil_msts_resp[i], axil_msts[i]);
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
        .clk_i  (seq.clk),
        .rst_ni (!rst),
        .test_i ('0),
        
        .slv_ports_req_i  (axil_slvs_req),
        .slv_ports_resp_o (axil_slvs_resp),
        .mst_ports_req_o  (axil_msts_req),
        .mst_ports_resp_i (axil_msts_resp),
        
        .addr_map_i (addr_map),
        
        .en_default_mst_port_i ('0),
        .default_mst_port_i    ('0)
    );
    
    always_comb begin
        for (int i = 0; i < NO_SLVS; i++) begin
            slave_pause[i].req = pause.req;
        end

        if (pause.req) begin
            pause.ack = 1;
            for (int i = 0; i < NO_SLVS; i++) begin
                pause.ack &= slave_pause[i].ack;
            end
        end
        else begin
            pause.ack = 0;
            for (int i = 0; i < NO_SLVS; i++) begin
                pause.ack |= slave_pause[i].ack;
            end
        end
    end
endmodule