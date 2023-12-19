`timescale 1ns/1ps
`include "adam/macros_bhv.svh"

module adam_pause_bhv #(
    `ADAM_BHV_CFG_PARAMS,

    parameter DELAY    = 1us,
    parameter DURATION = 1us
) (
    ADAM_SEQ.Slave    seq,
    ADAM_PAUSE.Master pause
);

    initial begin
        forever begin
            pause.req = 1;

            `ADAM_UNTIL_DO(!seq.rst, assert(pause.ack));

            pause.req <= #TA 0;
            `ADAM_UNTIL(!pause.ack);

            repeat (DELAY / (TA + TT)) begin
                `ADAM_UNTIL(1); // assert(!pause.ack));
            end

            pause.req <= #TA 1;
            `ADAM_UNTIL(pause.ack);
  
            repeat (DURATION / (TA + TT)) begin
                `ADAM_UNTIL_DO(1, assert(pause.ack));
            end
            
            pause.req <= #TA 0;
            `ADAM_UNTIL(!pause.ack);

            `ADAM_UNTIL(seq.rst);
        end
    end

    task cycle_start();
        #TT;
    endtask

    task cycle_end();
        @(posedge seq.clk);
    endtask

endmodule