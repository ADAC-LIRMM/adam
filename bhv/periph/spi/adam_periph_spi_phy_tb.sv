`timescale 1ns/1ps
`include "adam/macros_bhv.svh"
`include "vunit_defines.svh"

module adam_periph_spi_phy_tb;
    import adam_stream_mst_bhv::*;
    import adam_stream_slv_bhv::*;

    `ADAM_BHV_CFG_LOCALPARAMS;
    
    localparam NO_TESTS  = 100;
    localparam NO_FRAMES = 10; 
    localparam BAUD_RATE = 1000000;
    localparam BASE      = 8'hAA;

    ADAM_SEQ   seq   ();
    ADAM_PAUSE pause ();

    logic       tx_enable;
    logic       rx_enable;
    logic       mode_select;
    logic       clock_phase;
    logic       clock_polarity;
    logic       data_order;
    logic [7:0] data_length;
    DATA_T      baud_rate;

    `ADAM_STREAM_BHV_MST_FACTORY(DATA_T, TA, TT, tx, seq.clk);
    `ADAM_STREAM_BHV_SLV_FACTORY(DATA_T, TA, TT, 1, rx, seq.clk);

    ADAM_IO sclk();
    ADAM_IO mosi();
    ADAM_IO miso();
    ADAM_IO ss_n();

    logic slave_trigger;
    
    adam_seq_bhv #(
        `ADAM_BHV_CFG_PARAMS_MAP
    ) adam_seq_bhv (
        .seq (seq)
    );

    adam_periph_spi_phy #(
        `ADAM_CFG_PARAMS_MAP
    ) dut (
        .seq   (seq),
        .pause (pause),

        .tx_enable      (tx_enable),
        .rx_enable      (rx_enable),
        .mode_select    (mode_select),
        .clock_phase    (clock_phase),
        .clock_polarity (clock_polarity),
        .data_order     (data_order),
        .data_length    (data_length),
        .baud_rate      (baud_rate),

        .tx (tx),
        .rx (rx),

        .sclk (sclk),
        .mosi (mosi),
        .miso (miso),
        .ss_n (ss_n)
    );

    assign slave_trigger = sclk.o ^ clock_polarity;

    `TEST_SUITE begin
        `TEST_CASE("test") begin                   
            pause.req = 0;

            tx_enable      = 0;
            rx_enable      = 0; 
            mode_select    = 0;
            clock_phase    = 0;
            clock_polarity = 0;
            data_order     = 0;
            data_length    = 0;
            baud_rate      = 0;
            
            sclk.i = 0;
            mosi.i = 0;
            miso.i = 0;
            ss_n.i = 1;

            @(negedge seq.rst);
            @(posedge seq.clk);

            /* Random Tests */

            for (int k = 0; k < NO_TESTS; k++) begin
                
                $display("\nTEST: %d", k);

                random_config();

                if (mode_select) begin
                    // dut is master
                    fork
                        emulate_top();
                        emulate_slave();
                    join
                end
                else begin
                    // dut is slave
                    fork
                        emulate_top();
                        emulate_master();
                    join
                end
                
            end
        end
    end

    initial begin
        #10000us $error("timeout");
    end
    
    task random_config();
        pause.req <= #TA 1;
        `ADAM_UNTIL(pause.ack == 1);

        tx_enable      <= #TA 1;
        rx_enable      <= #TA 1; 
        mode_select    <= #TA $urandom_range(0, 1);
        clock_phase    <= #TA $urandom_range(0, 1);
        clock_polarity <= #TA $urandom_range(0, 1);
        data_order     <= #TA $urandom_range(0, 1);
        data_length    <= #TA 8;
        baud_rate      <= #TA 1s / (BAUD_RATE * CLK_PERIOD);
        cycle_start();
        cycle_end();

        pause.req <= #TA 0;
        `ADAM_UNTIL(pause.ack == 0);
    endtask

    task emulate_top();
        DATA_T data_tx;
        DATA_T data_rx;

        for (DATA_T i = 0; i < NO_FRAMES; i++) begin
            
            data_tx = BASE + i;

            tx_bhv.send(data_tx);
            rx_bhv.recv(data_rx);

            $display("[emulate_top   ] rx: 0x%02h tx: 0x%02h",
                data_rx, data_tx);

            assert(data_rx == data_tx);
        end 
    endtask

    task emulate_slave();
        logic [7:0] data_tx;
        logic [7:0] data_rx;

        assert (sclk.mode == 1);
        assert (mosi.mode == 1);
        assert (miso.mode == 0);
        assert (ss_n.mode == 1);

        for (int i = 0; i < NO_FRAMES; i++) begin
            
            data_tx = BASE + i;

            if (data_order) begin
                // reversed
                data_tx = reverse(data_tx);
            end

            if (!clock_phase) begin
                miso.i = data_tx[0];
            end

            if (ss_n.o != 0) begin
                @(negedge ss_n.o);
            end

            for (int j = 0; j < data_length; j++) begin
                if (clock_phase) begin
                    @(posedge slave_trigger);
                    miso.i = data_tx[j];

                    @(negedge slave_trigger);
                    data_rx[j] = mosi.o;
                end
                else begin
                    @(posedge slave_trigger);
                    data_rx[j] = mosi.o;

                    @(negedge slave_trigger);
                    miso.i = (j+1 < 8) ? data_tx[j+1] : 0;
                end                
            end

            if (data_order) begin
                // reversed
                data_tx = reverse(data_tx);
                data_rx = reverse(data_rx);
            end

            $display("[emulate_slave ] rx: 0x%02h tx: 0x%02h",
                data_rx, data_tx);

            assert (data_rx == data_tx);
        end
    endtask

    task emulate_master();
        logic [7:0] data_tx;
        logic [7:0] data_rx;

        assert (sclk.mode == 0);
        assert (mosi.mode == 0);
        assert (ss_n.mode == 0);

        sclk.i = clock_polarity;

        for (int i = 0; i < NO_FRAMES; i++) begin
            
            data_tx = BASE + i;

            if (data_order) begin
                // reversed
                data_tx = reverse(data_tx);
            end

            #(0.5s/BAUD_RATE);
            sclk.i = clock_polarity;
            mosi.i = data_tx[0];            
            ss_n.i = 0;
        
            for (int j = 0; j < data_length; j++) begin
                if (clock_phase) begin
                    #(0.5s/BAUD_RATE);
                    sclk.i = !clock_polarity;
                    mosi.i = data_tx[j];
                    
                    #(0.5s/BAUD_RATE);
                    sclk.i = clock_polarity;
                    assert (miso.mode == 1);
                    data_rx[j] = miso.o;
                end
                else begin
                    #(0.5s/BAUD_RATE);
                    sclk.i = !clock_polarity; 
                    assert (miso.mode == 1);
                    data_rx[j] = miso.o; 

                    #(0.5s/BAUD_RATE);
                    sclk.i = clock_polarity;
                    mosi.i = (j+1 < 8) ? data_tx[j+1] : 0;
                end                
            end

            #(0.5s/BAUD_RATE);
            sclk.i <= clock_polarity;
            mosi.i <= 0;            
            ss_n.i <= 1;

            if (data_order) begin
                // reversed
                data_tx = reverse(data_tx);
                data_rx = reverse(data_rx);
            end

            $display("[emulate_master] rx: 0x%02h tx: 0x%02h",
                data_rx, data_tx);

            assert (data_rx == data_tx);
        end

    endtask

    task cycle_start();
        #TT;
    endtask

    task cycle_end();
        @(posedge seq.clk);
    endtask

    function automatic logic [7:0] reverse(
        input logic [7:0] val
    );
        logic [7:0] res;
        
        for (int i = 0; i < 8; i++) begin
            res[i] = val[7 - i];
        end
        
        return res;
    endfunction

endmodule