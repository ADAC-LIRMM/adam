`include "vunit_defines.svh"

`define UNTIL(condition, body) begin \
    cycle_start(); \
    while (!(condition)) begin \
        cycle_end(); \
        body \
        cycle_start(); \
    end \
    cycle_end(); \
end

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

    adam_clk_rst_bhv #(
        .CLK_PERIOD (CLK_PERIOD),
        .RST_CYCLES (RST_CYCLES),

        .TA (TA),
        .TT (TT)
    ) adam_clk_rst_bhv (
        .seq (seq)
    );

    adam_pause_bhv #(
        .DELAY    (100us),
        .DURATION (100us),

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

                `UNTIL(!seq.rst,);

                forever begin
                    `UNTIL(slvs_req[i] != slvs_ack[i],);         
                    repeat ($urandom_range(0, 100)) `UNTIL(1,);
                    
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

            `UNTIL(!seq.rst,);

            `UNTIL(mst.req == 0 && mst.ack == 0,);
            assert (paused == 0);

            `UNTIL(mst.req == 1 && mst.ack == 1,);
            assert (paused == NO_SLVS);

            `UNTIL(mst.req == 0 && mst.ack == 0,);
            assert (paused == 0);
            //#300us;
        end
    end

    initial begin
        #10us $error("timeout");
    end

    task cycle_start();
        #TT;
    endtask

    task cycle_end();
        @(posedge seq.clk);
    endtask

endmodule
