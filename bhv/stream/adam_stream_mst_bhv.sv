`timescale 1ns/1ps

package adam_stream_mst_bhv;

class adam_stream_mst_bhv #(
    parameter type data_t = logic,

    parameter TA = 2ns,
    parameter TT = 18ns
);

    typedef virtual ADAM_STREAM_DV #(
        .data_t (data_t)
    ) dv_t;

    data_t queue [$];
    dv_t   dv;

    function new(
        dv_t dv
    );
        this.dv = dv;
    endfunction

    task send(
        input data_t data
    );
        queue.push_front(data);
    endtask

    task loop();
        logic  start_transfer;
        logic  end_transfer;
        data_t data;

        dv.data  = 0;
        dv.valid = 0;

        forever begin
            cycle_start();

            end_transfer = dv.valid && dv.ready;

            start_transfer = (!dv.valid || end_transfer) &&
                (queue.size() > 0);

            cycle_end();

            if (start_transfer) begin
                data = queue.pop_back();
                dv.data  <= #TA data;
                dv.valid <= #TA '1;
            end else if (end_transfer) begin
                dv.data  <= #TA '0;
                dv.valid <= #TA '0;
            end
        end
    endtask

    task cycle_start();
        #TT;
    endtask

    task cycle_end();
        @(posedge dv.clk);
    endtask

endclass

endpackage
