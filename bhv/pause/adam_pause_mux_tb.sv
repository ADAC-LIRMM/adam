`timescale 1ns/1ps
`include "adam/macros_bhv.svh"
`include "vunit_defines.svh"

module adam_pause_mux_tb;

    parameter NO_MSTS  = 2;

    parameter CLK_PERIOD = 20ns;
    parameter RST_CYCLES = 5;

    localparam TA = 2ns;
    localparam TT = CLK_PERIOD - TA;

    ADAM_SEQ seq ();

    ADAM_PAUSE deferred ();
    ADAM_PAUSE msts [NO_MSTS] ();
    ADAM_PAUSE slv ();

    logic common_req;
    
    adam_seq_bhv #(
        .CLK_PERIOD (CLK_PERIOD),
        .RST_CYCLES (RST_CYCLES),

        .TA (TA),
        .TT (TT)
    ) adam_seq_bhv (
        .seq (seq)
    );

    adam_pause_bhv #(
        .DELAY    (40us),
        .DURATION (100us),

        .TA (TA),
        .TT (TT)
    ) deferred_bhv (
        .seq   (seq),
        .pause (deferred)
    );

    adam_pause_bhv #(
        .DELAY    (45us),
        .DURATION (50us),

        .TA (TA),
        .TT (TT)
    ) mst0_bhv (
        .seq   (seq),
        .pause (msts[0])
    );

    adam_pause_bhv #(
        .DELAY    (50us),
        .DURATION (50us),

        .TA (TA),
        .TT (TT)
    ) mst1_bhv (
        .seq   (seq),
        .pause (msts[1])
    );

    adam_pause_mux #(
        .NO_SLVS (NO_MSTS)
    ) dut (
        .seq      (seq),

        .deferred (deferred),
        .slvs     (msts),
        .mst      (slv)
    );

    assign common_req = msts[0].req || msts[1].req;

    `TEST_SUITE begin
        `TEST_CASE("test") begin
            slv.ack = 1;

            // wait for reset
            `ADAM_UNTIL_DO(!seq.rst, assert(slv.req));

            // resume
            `ADAM_UNTIL(!slv.req);
            slv.ack <= #TA 0;

            // + deffered.req
            `ADAM_UNTIL_DO_FINNALY(deferred.req, begin
                assert(!common_req);
                assert(!deferred.ack);
            end, begin
                assert(!common_req);
                assert(!deferred.ack);
            end);

            // + common_req
            `ADAM_UNTIL_FINNALY(deferred.req && common_req, assert(slv.req));
            slv.ack <= #TA 1;

            // - deffered.req
            `ADAM_UNTIL_FINNALY(!deferred.req && !common_req, assert(!slv.req));
            slv.ack <= #TA 0;

            // idle
            repeat (10) `ADAM_UNTIL(1);
        end
    end

    initial begin
        //$display(seq.rst);
        #250us $error("timeout");
    end

    task cycle_start();
        #TT;
    endtask

    task cycle_end();
        @(posedge seq.clk);
    endtask

endmodule
