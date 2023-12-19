`timescale 1ns/1ps
`include "adam/macros_bhv.svh"
`include "vunit_defines.svh"

module adam_pause_demux_tb;

    parameter NO_SLVS  = 8;
    parameter PARALLEL = 1;

    localparam CLK_PERIOD = 20ns;
    localparam RST_CYCLES = 5;
    
    localparam TA = 2ns;
    localparam TT = CLK_PERIOD - TA;

    ADAM_SEQ seq ();

    ADAM_PAUSE mst ();
    ADAM_PAUSE slvs [NO_SLVS] ();

    logic slvs_req [NO_SLVS];
    logic slvs_ack [NO_SLVS];

    integer paused;

    adam_seq_bhv #(
        .CLK_PERIOD (CLK_PERIOD),
        .RST_CYCLES (RST_CYCLES),

        .TA (TA),
        .TT (TT)
    ) adam_seq_bhv (
        .seq (seq)
    );

    adam_pause_bhv #(
        .DELAY    (50us),
        .DURATION (50us),

        .TA (TA),
        .TT (TT)
    ) adam_pause_bhv (
        .seq   (seq),
        .pause (mst)
    );

    adam_pause_demux #(
        .NO_MSTS  (NO_SLVS),
        .PARALLEL (PARALLEL)
    ) dut (
        .seq (seq),

        .slv  (mst),
        .msts (slvs)
    );

    generate
        for (genvar i = 0; i < NO_SLVS; i++) begin
            assign slvs_req[i] = slvs[i].req;
            assign slvs[i].ack = slvs_ack[i];
        
            initial begin
                slvs_ack[i] = 1;

                `ADAM_UNTIL(!seq.rst);

                forever begin
                    `ADAM_UNTIL(slvs_req[i] != slvs_ack[i]);         
                    repeat ($urandom_range(0, 100)) `ADAM_UNTIL(1);
                    
                    paused += (slvs_req[i]) ? 1 : -1;
                    cycle_start();
                    cycle_end();

                    slvs_ack[i] <= #TA slvs_req[i];
                    cycle_start();
                    cycle_end();
                end
            end
        end
    endgenerate

    `TEST_SUITE begin
        `TEST_CASE("test") begin             
            paused = NO_SLVS;

            `ADAM_UNTIL(!seq.rst);

            `ADAM_UNTIL_FINNALY(!mst.req && !mst.ack, begin
                assert(paused == 0);
            end);

            `ADAM_UNTIL_FINNALY(mst.req && mst.ack, begin
                assert(paused == NO_SLVS);
            end);

            `ADAM_UNTIL_FINNALY(mst.req == 0 && mst.ack == 0, begin
                assert(paused == 0);
            end);
        end
    end

    initial begin
        #1000us $error("timeout");
    end

    task cycle_start();
        #TT;
    endtask

    task cycle_end();
        @(posedge seq.clk);
    endtask

endmodule
