module adam_periph_spi_phy_tb;
    
    localparam DATA_WIDTH = 32;

    localparam CLK_PERIOD = 20ns;
    localparam RST_CYCLES = 5;

    localparam TA = 2ns;
    localparam TT = CLK_PERIOD - TA;
    
    localparam NO_TESTS  = 100;
    localparam NO_FRAMES = 10; 
    localparam BAUD_RATE = 1000000;
    localparam BASE      = 8'hAA;

    typedef logic [DATA_WIDTH-1:0] data_t;

    logic clk;
    logic rst;
    logic test;

    logic pause_req;
    logic pause_ack;

    logic       tx_enable;
    logic       rx_enable;
    logic       mode_select;
    logic       clock_phase;
    logic       clock_polarity;
    logic       data_order;
    logic [3:0] data_length;
    data_t      baud_rate;

    data_t tx;
    logic  tx_valid;
    logic  tx_ready;

    data_t rx;
    logic  rx_valid;
    logic  rx_ready;

    ADAM_IO sclk();
    ADAM_IO mosi();
    ADAM_IO miso();
    ADAM_IO ss_n();

    logic slave_trigger;

    assign slave_trigger = sclk.o ^ clock_polarity;

    adam_periph_spi_phy #(
        .DATA_WIDTH (DATA_WIDTH)
    ) dut (
        .clk  (clk),
        .rst  (rst),
        .test (test),
        
        .pause_req (pause_req),
        .pause_ack (pause_ack),

        .tx_enable      (tx_enable),
        .rx_enable      (rx_enable),
        .mode_select    (mode_select),
        .clock_phase    (clock_phase),
        .clock_polarity (clock_polarity),
        .data_order     (data_order),
        .data_length    (data_length),
        .baud_rate      (baud_rate),

        .tx       (tx),
        .tx_valid (tx_valid),
        .tx_ready (tx_ready),

        .rx       (rx),
        .rx_valid (rx_valid),
        .rx_ready (rx_ready),

        .sclk (sclk),
        .mosi (mosi),
        .miso (miso),
        .ss_n (ss_n)
    );

    adam_clk_rst_bhv #(
        .CLK_PERIOD (CLK_PERIOD),
        .RST_CYCLES (RST_CYCLES),

        .TA (TA),
        .TT (TT)
    ) adam_clk_rst_bhv (
        .clk (clk),
        .rst (rst)
    );

    // Initialize inputs
    initial begin        
        test = 0;
        
        pause_req = 0;

        tx_enable      = 0;
        rx_enable      = 0; 
        mode_select    = 0;
        clock_phase    = 0;
        clock_polarity = 0;
        data_order     = 0;
        data_length    = 0;
        baud_rate      = 0;
        tx_valid       = 0;
        rx_ready       = 0;
        
        sclk.i = 0;
        mosi.i = 0;
        miso.i = 0;
        ss_n.i = 1;

        @(negedge rst);
        @(posedge clk);

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

        $stop();
    end
    
    task random_config();
        pause_req <= #TA 1;
        cycle_start();
        while (pause_ack != 1) begin
            cycle_end();
            cycle_start();
        end
        cycle_end();

        tx_enable      <= #TA 1;
        rx_enable      <= #TA 1; 
        mode_select    <= #TA $urandom_range(0, 1);
        clock_phase    <= #TA $urandom_range(0, 1);
        clock_polarity <= #TA $urandom_range(0, 1);
        data_order     <= #TA $urandom_range(0, 1);
        data_length    <= #TA 8;
        baud_rate      <= #TA 1s / (BAUD_RATE * CLK_PERIOD);
        tx_valid       <= #TA 0;
        rx_ready       <= #TA 0;
        cycle_start();
        cycle_end();

        pause_req <= #TA 0;
        cycle_start();
        while (pause_ack != 0) begin
            cycle_end();
            cycle_start();
        end
        cycle_end();
    endtask

    task emulate_top();
        data_t data_tx;
        data_t data_rx;

        for (data_t i = 0; i < NO_FRAMES; i++) begin
            
            data_tx = BASE + i;

            write(data_tx);
            read (data_rx);

            $display("[emulate_top   ] rx: 0x%02h tx: 0x%02h",
                data_rx, data_tx);

            assert(data_rx == data_tx) else $finish(1);
        end 
    endtask

    task emulate_slave();
        logic [7:0] data_tx;
        logic [7:0] data_rx;

        assert (sclk.mode == 1) else $finish(1);
        assert (mosi.mode == 1) else $finish(1);
        assert (miso.mode == 0) else $finish(1);
        assert (ss_n.mode == 1) else $finish(1);

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

            assert (data_rx == data_tx) else $finish(1);
        end
    endtask

    task emulate_master();
        logic [7:0] data_tx;
        logic [7:0] data_rx;

        assert (sclk.mode == 0) else $finish(1);
        assert (mosi.mode == 0) else $finish(1);
        assert (ss_n.mode == 0) else $finish(1);

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
                    assert (miso.mode == 1) else $finish(1);
                    data_rx[j] = miso.o;
                end
                else begin
                    #(0.5s/BAUD_RATE);
                    sclk.i = !clock_polarity; 
                    assert (miso.mode == 1) else $finish(1);
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

            assert (data_rx == data_tx) else $finish(1);
        end

    endtask

    task write(
        input data_t data
    );
        tx       <= #TA data;
        tx_valid <= #TA 1;
        cycle_start();
        while (!(tx_valid && tx_ready)) begin
            cycle_end();    
            cycle_start();
        end
        cycle_end();
        
        tx       <= #TA 0;
        tx_valid <= #TA 0;
        cycle_start();
        cycle_end();
    endtask

    task read(
        output data_t data
    );
        rx_ready <= #TA 1;
        cycle_start();
        while (!(rx_valid && rx_ready)) begin
            cycle_end();
            cycle_start();
        end
        cycle_end();
        data = rx;

        rx_ready <= #TA 0;
        cycle_start();
        cycle_end();
    endtask

    task cycle_start();
        #TT;
    endtask

    task cycle_end();
        @(posedge clk);
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