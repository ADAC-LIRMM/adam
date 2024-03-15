`include "adam/macros.svh"

module adam_stream_skid #(
    parameter type T = logic
) (
    ADAM_SEQ.Slave seq,

    ADAM_STREAM.Slave  slv,
    ADAM_STREAM.Master mst
);
    logic stall;
    T     buffer;

    always_comb begin
        mst.data  = (stall) ? buffer : slv.data;
        mst.valid = slv.valid || stall;
    end

    always_ff @(posedge seq.clk) begin
        
        if (seq.rst) begin
            stall     <= '0;
            buffer    <= '0;
            slv.ready <= '0;
        end 
        else begin
            slv.ready <= !stall || mst.ready;

            if (slv.valid && slv.ready && mst.valid && !mst.ready) begin
                stall     <= '1; 
                buffer    <= slv.data;
                slv.ready <= '0;
            end

            if (stall && mst.valid && mst.ready) begin
                stall     <= '0;
                buffer    <= '0;
                slv.ready <= '1;
            end
        end
    end

endmodule