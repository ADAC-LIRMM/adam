module adam_pause_demux #(
    parameter NO_MSTS  = 8,
    parameter PARALLEL = 0
) (
    ADAM_SEQ.Slave   seq,

    ADAM_PAUSE.Slave  slv,
    ADAM_PAUSE.Master msts [NO_MSTS]
);
    logic slv_req;
    logic slv_ack;

    logic msts_req [NO_MSTS];
    logic msts_ack [NO_MSTS];

    generate
        assign slv_req = slv.req;
        assign slv.ack = slv_ack;

        for (genvar i = 0; i < NO_MSTS; i++) begin
            assign msts[i].req = msts_req[i];
            assign msts_ack[i] = msts[i].ack;
        end    
    
        if (PARALLEL) begin
            for (genvar i = 0; i < NO_MSTS; i++) begin
                assign msts_req[i] = slv_req;
            end
        end
        else begin
            always_ff @(posedge seq.clk) begin
                if (seq.rst) begin
                    slv_ack <= 1;
                    for (int i = 0; i < NO_MSTS; i++) begin
                        msts_req[i] <= 1;
                    end
                end
                else if (slv_req && slv_ack) begin
                    // PAUSED
                end
                else if (slv_req) begin
                    msts_req[0] <= 1;
                    for (int i = 1; i < NO_MSTS; i++) begin
                        msts_req[i] <= (msts_req[i-1] && msts_ack[i-1]);
                    end
                end
                else begin
                    msts_req[NO_MSTS-1] <= 0;
                    for (int i = 0; i < NO_MSTS-1; i++) begin
                        msts_req[i] <= (msts_req[i+1] || msts_ack[i+1]);
                    end
                end
            end
        end
    endgenerate

    always_comb begin
        if (slv_req) begin
            slv_ack = 1;
            for (int i = 0; i < NO_MSTS; i++) begin
                slv_ack &= msts_ack[i];
            end
        end
        else begin
            slv_ack = 0;
            for (int i = 0; i < NO_MSTS; i++) begin
                slv_ack |= msts_ack[i];
            end
        end
    end
endmodule