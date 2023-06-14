module adam_axil_pause #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32,

    parameter MAX_TRANS = 7
) (
    input logic clk,
    input logic rst,
    input logic test,

    input  logic pause_req,
    output logic pause_ack,

    AXI_LITE.Slave  slv,
    AXI_LITE.Master mst
);

    logic [$clog2(MAX_TRANS):0] aw_trans;
    logic [$clog2(MAX_TRANS):0] w_trans;
    logic [$clog2(MAX_TRANS):0] ar_trans;
    
    logic aw_en;
    logic w_en;
    logic b_en;
    logic ar_en;
    logic r_en;
    
    always_comb begin
        automatic logic aw_full;
        automatic logic w_full;
        automatic logic ar_full;

        aw_full = (aw_trans == MAX_TRANS);
        w_full  = (w_trans  == MAX_TRANS);
        ar_full = (ar_trans == MAX_TRANS);

        mst.aw_addr  = slv.aw_addr;
        mst.aw_prot  = slv.aw_prot;
        mst.aw_valid = (aw_en && !aw_full) ? slv.aw_valid : 0;
        slv.aw_ready = (aw_en && !aw_full) ? mst.aw_ready : 0;

        mst.w_data  = slv.w_data;
        mst.w_strb  = slv.w_strb;
        mst.w_valid = (w_en && !w_full) ? slv.w_valid : 0;
        slv.w_ready = (w_en && !w_full) ? mst.w_ready : 0;

        slv.b_resp  = mst.b_resp;
        slv.b_valid = (b_en) ? mst.b_valid : 0;
        mst.b_ready = (b_en) ? slv.b_ready : 0;

        mst.ar_addr  = slv.ar_addr;
        mst.ar_prot  = slv.ar_prot;
        mst.ar_valid = (ar_en && !ar_full) ? slv.ar_valid : 0;
        slv.ar_ready = (ar_en && !ar_full) ? mst.ar_ready : 0;

        slv.r_data  = mst.r_data;
        slv.r_resp  = mst.r_resp;
        slv.r_valid = (r_en) ? mst.r_valid : 0;
        mst.r_ready = (r_en) ? slv.r_ready : 0;
    end

    always_ff @(posedge clk) begin
        if (rst) begin
            aw_trans = 0;
            w_trans  = 0;
            ar_trans = 0;

            aw_en <= 0;
            w_en  <= 0;
            b_en  <= 0;
            ar_en <= 0;
            r_en  <= 0;

            pause_ack <= 1;
        end
        else if (pause_req && pause_ack) begin
            // PAUSED
        end
        else begin

            // AW Stream
            if (mst.aw_valid && mst.aw_ready) begin
                aw_trans += 1;
            end

            // W Stream
            if (mst.w_valid && mst.w_ready) begin
                w_trans += 1;
            end

            // B Stream
            if (mst.b_valid && mst.b_ready) begin
                aw_trans -= 1;
                w_trans  -= 1;
            end

            // AR Stream
            if (mst.ar_valid && mst.ar_ready) begin
                ar_trans += 1;
            end

            // R Stream
            if (mst.r_valid && mst.r_ready) begin
                ar_trans -= 1;
            end

            if (pause_req && !pause_ack) begin
                // Pausing

                if (aw_trans >= w_trans) begin
                    aw_en <= 0;
                end
                
                if(w_trans >= aw_trans) begin
                    w_en <= 0;
                end

                if (aw_trans == 0 && w_trans == 0) begin
                    b_en <= 0;
                end

                ar_en <= 0;

                if (ar_trans == 0) begin
                    r_en <= 0;
                end

                if (aw_trans == 0 && w_trans == 0 && ar_trans == 0) begin
                    pause_ack <= 1;
                end
            end
            else if (!pause_req && pause_ack) begin
                // Resuming 

                aw_en <= 1;
                w_en  <= 1;
                b_en  <= 1;
                ar_en <= 1;
                r_en  <= 1;

                pause_ack <= 0;    
            end
        end
    end
endmodule