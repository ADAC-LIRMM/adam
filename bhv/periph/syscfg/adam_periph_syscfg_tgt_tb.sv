`timescale 1ns/1ps
`include "adam/macros_bhv.svh"
`include "apb/assign.svh"
`include "vunit_defines.svh"

module adam_periph_syscfg_tgt_tb;
    `ADAM_BHV_CFG_LOCALPARAMS;

    localparam EN_BOOTSTRAP = 1;
    localparam EN_BOOT_ADDR = 1;
    localparam EN_IRQ       = 1;

    localparam SR  = 'h0000;
    localparam MR  = 'h0004;
    localparam BAR = 'h0008;
    localparam IER = 'h000C;
    
    localparam IDLE   = 'd0;
    localparam RESUME = 'd1;
    localparam PAUSE  = 'd2;
    localparam STOP   = 'd3;
    localparam RESET  = 'd4;

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

    DATA_T     irq_vec;
    
    logic      tgt_rst;        
    ADAM_PAUSE tgt_pause ();
    ADDR_T     tgt_boot_addr;
    logic      tgt_irq;

    assign irq_vec = (DATA_T'('1) << 4);

    adam_periph_syscfg_tgt #(
        `ADAM_CFG_PARAMS_MAP,

        .EN_BOOTSTRAP (EN_BOOTSTRAP),
        .EN_BOOT_ADDR (EN_BOOT_ADDR),
        .EN_IRQ       (EN_IRQ)
    ) dut (
        .seq   (seq),
        .pause (pause),

        .slv (apb),

        .irq_vec (irq_vec),

        .tgt_rst       (tgt_rst),        
        .tgt_pause     (tgt_pause),
        .tgt_boot_addr (tgt_boot_addr),
        .tgt_irq       (tgt_irq)
    ); 
    
    `TEST_SUITE begin
        `TEST_CASE("basic") begin  
            // Step 0: Hard-reset =============================================

            tgt_pause.ack <= #TA '1;
            apb_bhv.reset_master();
            `ADAM_UNTIL(!seq.rst);

            verify_status('b11);

            if (EN_BOOTSTRAP) complete_action(RESUME);

            // Step 1: RESUME =================================================

            start_action(RESUME);
            complete_action(RESUME);
            verify_status('b00);

            // Step 2: RESET ==================================================
            
            start_action(RESET);
            complete_action(STOP); // RESET's step 1
            verify_status('b11);
            complete_action(RESUME); // RESET's step 2
            verify_status('b00);

            // Step 3: PAUSE ==================================================

            start_action(PAUSE);
            complete_action(PAUSE);
            verify_status('b01);

            // Step 4: STOP ===================================================

            start_action(STOP);
            complete_action(STOP);
            verify_status('b11);
        end

        `TEST_CASE("write_after_write") begin
            automatic logic resp;

            // Step 0: Hard-reset =============================================

            tgt_pause.ack <= #TA '1;
            apb_bhv.reset_master();
            `ADAM_UNTIL(!seq.rst);
            
            if (EN_BOOTSTRAP) complete_action(RESUME);

            // Step 1: Start an action but do not complete it =================

            start_action(STOP);

            // Step 2: Write to MR ============================================

            apb_bhv.write(MR, RESUME, 4'b1111, resp);
            assert (resp == apb_pkg::RESP_SLVERR);

            // Step 3: Write to BAR ===========================================

            if (EN_BOOT_ADDR) begin
                apb_bhv.write(BAR, '0, 4'b1111, resp);
                assert (resp == apb_pkg::RESP_SLVERR);
            end
        end

        `TEST_CASE("boot_addr") begin
            automatic DATA_T data;
            automatic logic  resp;

            // Step 0: Hard-reset =============================================

            tgt_pause.ack <= #TA '1;
            apb_bhv.reset_master();
            `ADAM_UNTIL(!seq.rst);

            if (EN_BOOT_ADDR) begin
                assert (tgt_boot_addr == '0);
            end

            if (EN_BOOTSTRAP) complete_action(RESUME);

            // Step 1: Write to BAR ===========================================

            apb_bhv.write(BAR, 'hABCD, 4'b1111, resp);
            if (EN_BOOT_ADDR) begin
                assert(resp == apb_pkg::RESP_OKAY);
                assert(tgt_boot_addr == 'hABCD);
            end
            else begin
                assert(resp == apb_pkg::RESP_SLVERR);
            end
        
            // Step 2: Read BAR ===============================================

            apb_bhv.read(BAR, data, resp);
            if (EN_BOOT_ADDR) begin
                assert(resp == apb_pkg::RESP_OKAY);
                assert(data == 'hABCD);
            end
            else begin
                assert(resp == apb_pkg::RESP_SLVERR);
            end
        end

        `TEST_CASE("irq") begin
            automatic DATA_T data;
            automatic logic  resp;

            // Step 0: Hard-reset =============================================
            
            tgt_pause.ack <= #TA '1;
            apb_bhv.reset_master();
            `ADAM_UNTIL(!seq.rst);

            assert (tgt_irq == '0);

            if (EN_BOOTSTRAP) complete_action(RESUME);

            // Step 1: Write to IER ===========================================

            apb_bhv.write(IER, {(DATA_WIDTH){1'b1}}, 4'b1111, resp);
            if (EN_IRQ) begin
                assert (resp == apb_pkg::RESP_OKAY);
                assert (tgt_irq == '1);
            end
            else begin
                assert (resp == apb_pkg::RESP_SLVERR);
            end
            
            // Step 2: Read from IER ==========================================

            apb_bhv.read(IER, data, resp);
            if (EN_IRQ) begin
                assert(resp == apb_pkg::RESP_OKAY);
                assert(data == {(DATA_WIDTH){1'b1}});
            end
            else begin
                assert(resp == apb_pkg::RESP_SLVERR);
            end
        end
    end

    initial begin
        #1000us $error("timeout");
    end

    task start_action(input DATA_T action);
        automatic logic resp;
        apb_bhv.write(MR, action, 4'b1111, resp);
        assert (resp == apb_pkg::RESP_OKAY);
    endtask
    
    task verify_status(input bit [1:0] expected);
        automatic DATA_T data;
        automatic logic  resp;
        apb_bhv.read(SR, data, resp);
        assert (resp == apb_pkg::RESP_OKAY);
        assert (data[1] == expected[1]); // stopped status
        assert (data[0] == expected[0]); // paused status
    endtask

    task complete_action(input DATA_T action);
        case (action)
            IDLE: begin
                // EMPTY
            end
            RESUME: begin
                tgt_pause.ack <= #TA '0;
                `ADAM_UNTIL_FINNALY(!tgt_pause.req && !tgt_pause.ack,
                    assert(!tgt_rst));
            end
            PAUSE: begin
                tgt_pause.ack <= #TA '1;
                `ADAM_UNTIL(tgt_pause.req && tgt_pause.ack);
            end
            STOP: begin
                tgt_pause.ack <= #TA '1;
                `ADAM_UNTIL_DO(tgt_pause.req && tgt_pause.ack,
                    assert(!tgt_rst));
                `ADAM_UNTIL(tgt_rst);
            end
            RESET: begin
                complete_action(STOP);
                complete_action(RESUME);
            end
        endcase
    endtask

    task cycle_start();
        #TT;
    endtask

    task cycle_end();
        @(posedge seq.clk);
    endtask
    
endmodule
