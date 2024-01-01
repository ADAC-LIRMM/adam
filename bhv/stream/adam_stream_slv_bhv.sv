`timescale 1ns/1ps
`include "adam/macros_bhv.svh"

package adam_stream_slv_bhv;

class adam_stream_slv_bhv #(
    `ADAM_BHV_CFG_PARAMS,

    parameter MAX_TRANS = 4,

    parameter type T = logic
);

    typedef virtual ADAM_STREAM_DV #(
        .T (T)
    ) dv_t;

    T queue [$];
    dv_t   dv;

    function new(
        dv_t dv
    );
        this.dv = dv;
    endfunction

    task recv(
        output T data
    );
        while (queue.size() == 0) begin
            cycle_start();
            cycle_end();
        end
        
        data = queue.pop_back();
    endtask

    task loop();
        logic  start_transfer;
        logic  end_transfer;

        // init value
        dv.ready = 0;

        forever begin
            cycle_start();
            
            end_transfer = dv.valid && dv.ready;
            
            if (end_transfer) begin
                queue.push_front(dv.data);
            end

            start_transfer = (queue.size() < MAX_TRANS);

            cycle_end();
            
            if (end_transfer) begin
                dv.ready <= #TA 0;
            end
            
            if (start_transfer) begin
                dv.ready <= #TA 1;
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
