module adam_pause_mux #(
    parameter NO_SLVS = 1
) (
    ADAM_SEQ.Slave   seq,

    ADAM_PAUSE.Slave  deferred,
    ADAM_PAUSE.Slave  slvs [NO_SLVS],
    ADAM_PAUSE.Master mst
);

    logic slvs_req [NO_SLVS];
    logic slvs_ack [NO_SLVS];

    logic ready;

    generate
        for (genvar i = 0; i < NO_SLVS; i++) begin
            assign slvs_req[i] = slvs[i].req;
            assign slvs[i].ack = slvs_ack[i]; 
        end
    endgenerate

    always_comb begin
        mst.req = 0;
        for (int i = 0; i < NO_SLVS; i++) begin
            mst.req |= slvs_req[i];
            slvs_ack[i] = mst.ack;
        end

        if(deferred.req) begin
            deferred.ack = mst.req && mst.ack;
        end
        else begin
            deferred.ack = mst.req || mst.ack;
        end
    end

endmodule