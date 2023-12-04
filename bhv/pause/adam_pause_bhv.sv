`timescale 1ns/1ps
`include "adam/macros_bhv.svh"

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

            `UNTIL_DO(!seq.rst, assert(pause.ack));

            pause.req <= #TA 0;
            `UNTIL(!pause.ack);

            repeat (DELAY / (TA + TT)) begin
                `UNTIL(1); // assert(!pause.ack));
            end

            pause.req <= #TA 1;
            `UNTIL(pause.ack);
  
            repeat (DURATION / (TA + TT)) begin
                `UNTIL_DO(1, assert(pause.ack));
            end
            
            pause.req <= #TA 0;
            `UNTIL(!pause.ack);

            `UNTIL(seq.rst);
        end
    end

    task cycle_start();
        #TT;
    endtask

    task cycle_end();
        @(posedge seq.clk);
    endtask

endmodule