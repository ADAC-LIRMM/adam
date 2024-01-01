`include "adam/macros.svh"
`include "axi/typedef.svh"
`include "axi/assign.svh"

module adam_axil_apb_bridge #(
    `ADAM_CFG_PARAMS,

    parameter NO_MSTS   = 1,
    parameter MAX_TRANS = NO_MSTS,

    parameter type RULE_T = logic
) (
    ADAM_SEQ.Slave   seq,
    ADAM_PAUSE.Slave pause,

    AXI_LITE.Slave slv,
    APB.Master     mst [NO_MSTS+1],

    input RULE_T addr_map [NO_MSTS+1]
);

    // pause ==================================================================

    `ADAM_AXIL_I slv_after_pause ();

    adam_axil_pause #(
        `ADAM_CFG_PARAMS_MAP,

        .MAX_TRANS  (MAX_TRANS)
    ) adam_axil_pause (
        .seq   (seq),
        .pause (pause),

        .slv (slv),
        .mst (slv_after_pause)
    );

    // phy ====================================================================

    typedef struct packed {
        int unsigned idx;
        ADDR_T start_addr;
        ADDR_T end_addr;
    } phy_rule_t;

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

    generate
        if (NO_MSTS > 0) begin
            axil_req_t  slv_req;
            axil_resp_t slv_resp;
            
            apb_req_t  [NO_MSTS-1:0] mst_req;
            apb_resp_t [NO_MSTS-1:0] mst_resp;

            phy_rule_t [NO_MSTS-1:0] phy_addr_map;

            `AXI_LITE_ASSIGN_TO_REQ(slv_req, slv_after_pause);
            `AXI_LITE_ASSIGN_FROM_RESP(slv_after_pause, slv_resp);

            for (genvar i = 0; i < NO_MSTS; i++) begin
                assign mst[i].paddr = mst_req[i].paddr -
                        addr_map[i].start;
                    
                assign mst[i].pprot   = mst_req[i].pprot;
                assign mst[i].psel    = mst_req[i].psel;
                assign mst[i].penable = mst_req[i].penable;
                assign mst[i].pwrite  = mst_req[i].pwrite;
                assign mst[i].pwdata  = mst_req[i].pwdata;
                assign mst[i].pstrb   = mst_req[i].pstrb;
            
                assign mst_resp[i].pready  = mst[i].pready;
                assign mst_resp[i].prdata  = mst[i].prdata;
                assign mst_resp[i].pslverr = mst[i].pslverr;

                assign phy_addr_map[i] = '{
                    idx: i,
                    start_addr: addr_map[i].start,
                    end_addr:   addr_map[i].end_
                };
            end
            
            axi_lite_to_apb #(
                .NoApbSlaves      (NO_MSTS),
                .NoRules          (NO_MSTS),
                .AddrWidth        (ADDR_WIDTH),
                .DataWidth        (DATA_WIDTH),
                .PipelineRequest  (1),
                .PipelineResponse (1),
                .axi_lite_req_t   (axil_req_t),
                .axi_lite_resp_t  (axil_resp_t),
                .apb_req_t        (apb_req_t),
                .apb_resp_t       (apb_resp_t),
                .rule_t           (phy_rule_t)
            ) axi_lite_to_apb (
                .clk_i  (seq.clk),
                .rst_ni (!seq.rst),

                .axi_lite_req_i  (slv_req),
                .axi_lite_resp_o (slv_resp),

                .apb_req_o  (mst_req),
                .apb_resp_i (mst_resp),

                .addr_map_i (phy_addr_map)
            );
        end
        else begin
            `ADAM_AXIL_SLV_TIE_OFF(slv_after_pause);

            for (genvar i = 0; i < NO_MSTS; i++) begin
                `ADAM_APB_MST_TIE_OFF(mst[i]);
            end
        end
    endgenerate
endmodule