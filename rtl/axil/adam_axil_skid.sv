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
            fall_through_register #(
                .T (aw_chan_t)
            ) aw_chan_fall_through (
                .clk_i      (seq.clk),
                .rst_ni     (!seq.rst),
                .clr_i      ('0),
                .testmode_i ('0),

                .valid_i (slv.aw_valid),
                .ready_o (slv.aw_ready),
                .data_i  (slv_aw),
                
                .valid_o (mst.aw_valid),
                .ready_i (mst.aw_ready),
                .data_o  (mst_aw)
            );
        end

        if (BYPASS_W) begin
            assign mst.w_valid = slv.w_valid;
            assign slv.w_ready = mst.w_ready;
            assign mst_w = slv_w;
        end
        else begin
            fall_through_register #(
                .T (w_chan_t)
            ) w_chan_fall_through (
                .clk_i      (seq.clk),
                .rst_ni     (!seq.rst),
                .clr_i      ('0),
                .testmode_i ('0),

                .valid_i (slv.w_valid),
                .ready_o (slv.w_ready),
                .data_i  (slv_w),
                
                .valid_o (mst.w_valid),
                .ready_i (mst.w_ready),
                .data_o  (mst_w)
            );
        end

        if (BYPASS_B) begin
            assign slv.b_valid = mst.b_valid;
            assign mst.b_ready = slv.b_ready;
            assign slv_b = mst_b;
        end
        else begin
            fall_through_register #(
                .T (b_chan_t)
            ) b_chan_fall_through (
                .clk_i      (seq.clk),
                .rst_ni     (!seq.rst),
                .clr_i      ('0),
                .testmode_i ('0),

                .valid_i (mst.b_valid),
                .ready_o (mst.b_ready),
                .data_i  (mst_b),
                
                .valid_o (slv.b_valid),
                .ready_i (slv.b_ready),
                .data_o  (slv_b)
            );
        end

        if (BYPASS_AR) begin
            assign mst.ar_valid = slv.ar_valid;
            assign slv.ar_ready = mst.ar_ready;
            assign mst_ar = slv_ar;
        end
        else begin
            fall_through_register #(
                .T (ar_chan_t)
            ) ar_chan_fall_through (
                .clk_i      (seq.clk),
                .rst_ni     (!seq.rst),
                .clr_i      ('0),
                .testmode_i ('0),

                .valid_i (slv.ar_valid),
                .ready_o (slv.ar_ready),
                .data_i  (slv_ar),
                
                .valid_o (mst.ar_valid),
                .ready_i (mst.ar_ready),
                .data_o  (mst_ar)
            );
        end

        if (BYPASS_R) begin
            assign slv.r_valid = mst.r_valid;
            assign mst.r_ready = slv.r_ready;
            assign slv_r = mst_r;
        end
        else begin
            fall_through_register #(
                .T (r_chan_t)
            ) r_chan_fall_through (
                .clk_i      (seq.clk),
                .rst_ni     (!seq.rst),
                .clr_i      ('0),
                .testmode_i ('0),

                .valid_i (mst.r_valid),
                .ready_o (mst.r_ready),
                .data_i  (mst_r),
                
                .valid_o (slv.r_valid),
                .ready_i (slv.r_ready),
                .data_o  (slv_r)
            );
        end

    endgenerate

endmodule