`include "adam/macros.svh"

module adam_axil_to_mem #(
    `ADAM_CFG_PARAMS,

    parameter MAX_TRANS = FAB_MAX_TRANS
) (
    ADAM_SEQ.Slave   seq,
    ADAM_PAUSE.Slave pause,

    AXI_LITE.Slave axil,

    output logic  mem_req,
    output ADDR_T mem_addr,
    output logic  mem_we,
    output STRB_T mem_be,
    output DATA_T mem_wdata,
    input  DATA_T mem_rdata
);

    logic  obi_req;
    logic  obi_gnt;
    logic  obi_rvalid;
    logic  obi_rready;
    DATA_T obi_rdata;
    
    logic  buf_write;
    DATA_T buf_rdata;
    
    adam_obi_from_axil #(
        `ADAM_CFG_PARAMS_MAP,

        .MAX_TRANS (FAB_MAX_TRANS)
    ) adam_obi_from_axil (
        .seq   (seq),
        .pause (pause),

        .axil (axil),

        .req    (obi_req),
        .gnt    (obi_gnt),
        .addr   (mem_addr),
        .we     (mem_we),
        .be     (mem_be),
        .wdata  (mem_wdata),
        .rvalid (obi_rvalid),
        .rready (obi_rready),
        .rdata  (obi_rdata)
    );

    assign mem_req = obi_req && obi_gnt;
    assign obi_gnt = !obi_rvalid;
    assign obi_rdata = (buf_write) ? mem_rdata : buf_rdata;

    always_ff @(posedge seq.clk) begin
        if (seq.rst) begin
            obi_rvalid <= 0;
        end
        else begin
            if (obi_rvalid && obi_rready) begin
                obi_rvalid <= 0; 
            end

            if (obi_req && obi_gnt) begin
                obi_rvalid <= 1;
            end
        end
    end

    always @(posedge seq.clk) begin
        if (seq.rst) begin
            buf_write <= '0;
            buf_rdata <= '0;
        end
        else begin
            if (buf_write) buf_rdata <= mem_rdata;
            buf_write <= mem_req;
        end
    end

endmodule