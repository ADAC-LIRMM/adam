`include "axi/assign.svh"
`include "axi/typedef.svh"

module adam_axil_skid #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32,
        
    parameter BYPASS_AW = 0,
    parameter BYPASS_W  = 0,
    parameter BYPASS_B  = 0,
    parameter BYPASS_AR = 0,
    parameter BYPASS_R  = 0,

    // Dependent parameters bellow, do not override.

    parameter STRB_WIDTH  = DATA_WIDTH/8,

    parameter type addr_t = logic [ADDR_WIDTH-1:0],
    parameter type data_t = logic [DATA_WIDTH-1:0],
    parameter type strb_t = logic [STRB_WIDTH-1:0]  
) (
    ADAM_SEQ.Slave   seq,

    AXI_LITE.Slave  slv,
    AXI_LITE.Master mst
);

    `AXI_LITE_TYPEDEF_AW_CHAN_T(aw_chan_t, addr_t);
    `AXI_LITE_TYPEDEF_W_CHAN_T(w_chan_t, data_t, strb_t);
    `AXI_LITE_TYPEDEF_B_CHAN_T(b_chan_t);
    `AXI_LITE_TYPEDEF_AR_CHAN_T(ar_chan_t, addr_t);
    `AXI_LITE_TYPEDEF_R_CHAN_T(r_chan_t, data_t);

    aw_chan_t slv_aw;
    w_chan_t  slv_w;
    b_chan_t  slv_b;
    ar_chan_t slv_ar;
    r_chan_t  slv_r;

    aw_chan_t mst_aw;
    w_chan_t  mst_w;
    b_chan_t  mst_b;
    ar_chan_t mst_ar;
    r_chan_t  mst_r;

    `AXI_LITE_ASSIGN_TO_AW(slv_aw, slv);
    `AXI_LITE_ASSIGN_TO_W(slv_w, slv);
    `AXI_LITE_ASSIGN_FROM_B(slv, slv_b);
    `AXI_LITE_ASSIGN_TO_AR(slv_ar, slv);
    `AXI_LITE_ASSIGN_FROM_R(slv, slv_r);

    `AXI_LITE_ASSIGN_FROM_AW(mst, mst_aw);
    `AXI_LITE_ASSIGN_FROM_W(mst, mst_w);
    `AXI_LITE_ASSIGN_TO_B(mst_b, mst);
    `AXI_LITE_ASSIGN_FROM_AR(mst, mst_ar);
    `AXI_LITE_ASSIGN_TO_R(mst_r, mst);

    generate
        if (BYPASS_AW) begin
            assign mst.aw_valid = slv.aw_valid;
            assign slv.aw_ready = mst.aw_ready;
            assign mst_aw = slv_aw;
        end
        else begin
            adam_skid #(
                .data_t (aw_chan_t)
            ) aw_chan_skid (
                .seq (seq),

                .slv_data  (slv_aw),
                .slv_valid (slv.aw_valid),
                .slv_ready (slv.aw_ready),
                
                .mst_data  (mst_aw),
                .mst_valid (mst.aw_valid),
                .mst_ready (mst.aw_ready)
            );
        end

        if (BYPASS_W) begin
            assign mst.w_valid = slv.w_valid;
            assign slv.w_ready = mst.w_ready;
            assign mst_w = slv_w;
        end
        else begin
            adam_skid #(
                .data_t (w_chan_t)
            ) w_chan_skid (
                .seq (seq),

                .slv_data  (slv_w),
                .slv_valid (slv.w_valid),
                .slv_ready (slv.w_ready),
                
                .mst_data  (mst_w),
                .mst_valid (mst.w_valid),
                .mst_ready (mst.w_ready)
            );
        end

        if (BYPASS_B) begin
            assign slv.b_valid = mst.b_valid;
            assign mst.b_ready = slv.b_ready;
            assign slv_b = mst_b;
        end
        else begin
            adam_skid #(
                .data_t (b_chan_t)
            ) b_chan_skid (
                .seq (seq),

                .slv_data  (mst_b),
                .slv_valid (mst.b_valid),
                .slv_ready (mst.b_ready),
                
                .mst_data  (slv_b),
                .mst_valid (slv.b_valid),
                .mst_ready (slv.b_ready)
            );
        end

        if (BYPASS_AR) begin
            assign mst.ar_valid = slv.ar_valid;
            assign slv.ar_ready = mst.ar_ready;
            assign mst_ar = slv_ar;
        end
        else begin
            adam_skid #(
                .data_t (ar_chan_t)
            ) ar_chan_skid (
                .seq (seq),

                .slv_data  (slv_ar),
                .slv_valid (slv.ar_valid),
                .slv_ready (slv.ar_ready),
                
                .mst_data  (mst_ar),
                .mst_valid (mst.ar_valid),
                .mst_ready (mst.ar_ready)
            );
        end

        if (BYPASS_R) begin
            assign slv.r_valid = mst.r_valid;
            assign mst.r_ready = slv.r_ready;
            assign slv_r = mst_r;
        end
        else begin
            adam_skid #(
                .data_t (r_chan_t)
            ) r_chan_skid (
                .seq (seq),

                .slv_data  (mst_r),
                .slv_valid (mst.r_valid),
                .slv_ready (mst.r_ready),
                
                .mst_data  (slv_r),
                .mst_valid (slv.r_valid),
                .mst_ready (slv.r_ready)
            );
        end

    endgenerate

endmodule