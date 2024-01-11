`include "adam/macros.svh"

module adam_obi_to_axil #(
    `ADAM_CFG_PARAMS,

    parameter MAX_TRANS = FAB_MAX_TRANS
) (
    ADAM_SEQ.Slave   seq,
    ADAM_PAUSE.Slave pause,

    input  logic  req,
    output logic  gnt,
    input  ADDR_T addr,
    input  logic  we,
    input  STRB_T be,
    input  DATA_T wdata,
    output logic  rvalid,
    input  logic  rready,
    output DATA_T rdata,

    AXI_LITE.Master axil 
);

    logic [$clog2(MAX_TRANS):0] transfers;
    logic [MAX_TRANS-1:0] is_write;

    logic aw_ok;
    logic w_ok;

    always_ff @(posedge seq.clk) begin
        if (seq.rst) begin
            transfers = '0;
            is_write  = '0;

            aw_ok = '0;
            w_ok  = '0;

            pause.ack = '1;
        end
        else if (pause.req && pause.ack) begin
            // PAUSED
        end
        else if (!pause.req && pause.ack) begin
            // resume
            pause.ack = 0;
        end
        else begin 
            if (req && gnt) begin
                is_write[transfers] = we;
                transfers = transfers + 1;
            end

            if (axil.aw_valid && axil.aw_ready) begin
                aw_ok = 1;
            end
            
            if (axil.w_valid && axil.w_ready) begin
                w_ok = 1;
            end

            if (aw_ok && w_ok) begin
                aw_ok = 0;
                w_ok  = 0;
            end

            if (rvalid && rready) begin
                is_write = {'0, is_write[MAX_TRANS-1:1]};
                transfers = transfers - 1;
            end

            if (pause.req && transfers == 0) begin
                // pause
                pause.ack = pause.req;
            end
        end
    end

    always_comb begin
        if (req && transfers < MAX_TRANS && !pause.req) begin
            if (we) begin
                axil.aw_valid = !aw_ok;
                axil.w_valid  = !w_ok;
                axil.ar_valid = 0;

                gnt = (aw_ok || axil.aw_ready) && (w_ok || axil.w_ready);
            end
            else begin
                axil.aw_valid = 0;
                axil.w_valid  = 0;
                axil.ar_valid = 1;

                gnt = axil.ar_ready;
            end
        end
        else begin
            axil.aw_valid = 0;
            axil.w_valid  = 0;
            axil.ar_valid = 0;

            gnt = 0;
        end

        if (is_write[0]) begin
            rvalid = axil.b_valid;
            axil.b_ready = rready;
            axil.r_ready = 0;
        end
        else begin
            rvalid = axil.r_valid;
            axil.b_ready = 0;
            axil.r_ready = rready;
        end
    end

    always_comb begin
        axil.aw_addr = addr;
        axil.aw_prot = 0;
        axil.w_data  = wdata;
        axil.w_strb  = be;

        axil.ar_addr = addr;
        axil.ar_prot = 0;

        rdata = axil.r_data;

        // force alignment
        axil.aw_addr[$clog2(STRB_WIDTH)-1:0] = 0;
        axil.ar_addr[$clog2(STRB_WIDTH)-1:0] = 0;
    end

endmodule