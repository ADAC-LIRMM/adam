`timescale 1ns/1ps
`include "adam/macros_bhv.svh"
`include "apb/assign.svh"
`include "vunit_defines.svh"

module adam_periph_syscfg_tgt_tb #(
    `ADAM_BHV_CFG_PARAMS
);

    ADAM_SEQ   seq   ();
    ADAM_PAUSE pause ();

    adam_seq_bhv #(
        `ADAM_BHV_CFG_PARAMS_MAP
    ) adam_seq_bhv (
        .seq (seq)
    );

    adam_pause_bhv #(
        `ADAM_BHV_CFG_PARAMS_MAP,

        .DELAY    (10us),
        .DURATION (10us)
    ) adam_pause_bhv (
        .seq   (seq),
        .pause (pause)
    );

    `ADAM_APB_BHV_MST_FACTORY(apb, seq.clk);

    // adam_periph_syscfg_tgt #(
    //     `ADAM_CFG_PARAMS_MAP
    // ) dut (
    //     .seq   (seq),
    //     .pause (pause),
    //     .slv   (apb)
    //     // ... Other connections
    // );
    
    `TEST_SUITE begin
        `TEST_CASE("basic") begin
            #10us;
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
