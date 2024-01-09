module adam_pause_mux #(
    parameter NO_SLVS = 2
) (
    ADAM_SEQ.Slave   seq,

    ADAM_PAUSE.Slave  deferred,
    ADAM_PAUSE.Slave  slv [NO_SLVS+1],
    ADAM_PAUSE.Master mst
);

    logic slv_req [NO_SLVS+1];
    logic slv_ack [NO_SLVS+1];

    logic ready;

    generate
        for (genvar i = 0; i < NO_SLVS; i++) begin
            assign slv_req[i] = slv[i].req;
            assign slv[i].ack = slv_ack[i]; 
        end
    endgenerate

    always_comb begin
        mst.req = 0;
        for (int i = 0; i < NO_SLVS; i++) begin
            mst.req |= slv_req[i];
            slv_ack[i] = mst.ack;
        end

        if(deferred.req) begin
            deferred.ack = mst.req && mst.ack;
        end
        else begin
            deferred.ack = mst.req || mst.ack;
        end
    end

endmodule