package adam_stream_slv_bhv;

class adam_stream_slv_bhv #(
    parameter type data_t = logic,

    parameter TA = 2ns,
    parameter TT = 18ns,

    parameter MAX_TRANS = 4
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

    task recv(
        output data_t data
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
