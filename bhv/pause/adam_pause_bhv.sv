`define UNTIL(condition, body) begin \
    cycle_start(); \
    while (!(condition)) begin \
        cycle_end(); \
        body \
        cycle_start(); \
    end \
    cycle_end(); \
end

module adam_pause_bhv #(
    parameter DELAY    = 1us,
    parameter DURATION = 1us,

    parameter TA = 2ns,
    parameter TT = 18ns
) (
    ADAM_SEQ.Slave    seq,
    ADAM_PAUSE.Master pause
);

    initial begin
        forever begin
            pause.req = 1;

            `UNTIL(!seq.rst, begin
                assert(pause.ack == 1);
            end);

            pause.req <= #TA 0;
            `UNTIL(!pause.ack,);

            #(DELAY);
            @(posedge seq.clk);

            pause.req <= #TA 1;
            `UNTIL(pause.ack,);

            #(DURATION);
            @(posedge seq.clk);
            
            pause.req <= #TA 0;
            `UNTIL(!pause.ack,);

           `UNTIL(seq.rst,);
        end
    end

    task cycle_start();
        #TT;
    endtask

    task cycle_end();
        @(posedge seq.clk);
    endtask

endmodule