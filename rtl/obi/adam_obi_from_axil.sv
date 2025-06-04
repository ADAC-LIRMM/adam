`include "adam/macros.svh"

module adam_obi_from_axil #(
    `ADAM_CFG_PARAMS,

    parameter MAX_TRANS = FAB_MAX_TRANS
) (
    ADAM_SEQ.Slave   seq,
    ADAM_PAUSE.Slave pause,

    AXI_LITE.Slave axil,

    output logic  req,
    input  logic  gnt,
    output ADDR_T addr,
    output logic  we,
    output STRB_T be,
    output DATA_T wdata,
    input  logic  rvalid,
    output logic  rready,
    input  DATA_T rdata
);

    localparam LOG_MAX_TRANS = $clog2(MAX_TRANS);

    // pause ==================================================================

    `ADAM_AXIL_I axil_pause ();
    
    adam_axil_pause #(
        `ADAM_CFG_PARAMS_MAP,

        .MAX_TRANS  (MAX_TRANS)
    ) adam_axil_pause (
        .seq   (seq),
        .pause (pause),

        .slv (axil),
        .mst (axil_pause)
    );

    // axil skid ==============================================================

    `ADAM_AXIL_I axil_skid ();

    adam_axil_skid #(
        `ADAM_CFG_PARAMS_MAP,

        .BYPASS_B  (1),
        .BYPASS_R  (1)
    ) adam_axil_skid (
        .seq (seq),

        .slv (axil_pause),
        .mst (axil_skid)
    );

    // logic ==================================================================

    typedef logic [   LOG_MAX_TRANS-1:0] pos_t;
    typedef logic [2**LOG_MAX_TRANS-1:0] buf_t;

    pos_t pos_req;
    pos_t pos_resp;
    buf_t circ_buf;

    // logic - req ============================================================

    always_ff @(posedge seq.clk) begin
        if (seq.rst) begin
            pos_req  <= '0;
            circ_buf <= '0;
        end
        else begin
            if (
                (axil_skid.aw_valid && axil_skid.aw_ready) &&
                (axil_skid.w_valid && axil_skid.w_ready)
            ) begin
                circ_buf[pos_req] <= '1;
                pos_req <= pos_req + 1;
            end
            
            if (axil_skid.ar_valid && axil_skid.ar_ready) begin
                circ_buf[pos_req] <= '0;
                pos_req <= pos_req + 1;
            end
        end
    end

    always_comb begin
        req    = '0;
        addr   = '0;
        we     = '0;
        be     = '0;
        wdata  = '0;

        axil_skid.aw_ready = '0;
        axil_skid.w_ready  = '0;
        axil_skid.ar_ready = '0;
        
        if (pos_t'(pos_req + 1) == pos_resp) begin
            // full
        end
        else if (axil_skid.aw_valid && axil_skid.w_valid) begin
            req    = '1;
            addr   = axil_skid.aw_addr;
            we     = '1;
            be     = axil_skid.w_strb;
            wdata  = axil_skid.w_data;

            axil_skid.aw_ready = gnt;
            axil_skid.w_ready  = gnt;
            axil_skid.ar_ready = '0;
        end
        else if (axil_skid.ar_valid) begin
            req    = '1;
            addr   = axil_skid.ar_addr;
            we     = '0;
            be     = '0;
            wdata  = '0;

            axil_skid.aw_ready = '0;
            axil_skid.w_ready  = '0;
            axil_skid.ar_ready = gnt;
        end
    end

    // logic - resp ===========================================================

    always_ff @(posedge seq.clk) begin
        if (seq.rst) begin
            pos_resp <= '0;
        end
        else begin
            if (rvalid && rready) begin
                pos_resp <= pos_resp + 1;
            end
        end
    end

    always_comb begin
        if (circ_buf[pos_resp]) begin
            axil_skid.b_resp  = axi_pkg::RESP_OKAY;
            axil_skid.b_valid = rvalid;

            axil_skid.r_data  = '0;
            axil_skid.r_resp  = '0;
            axil_skid.r_valid = '0;

            rready = axil_skid.b_ready;
        end
        else begin
            axil_skid.b_resp  = '0;
            axil_skid.b_valid = '0;

            axil_skid.r_data = rdata;
            axil_skid.r_resp = axi_pkg::RESP_OKAY;
            axil_skid.r_valid = rvalid;

            rready = axil_skid.r_ready;
        end
    end

endmodule
