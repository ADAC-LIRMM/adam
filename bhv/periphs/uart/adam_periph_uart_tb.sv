
`include "apb/assign.svh"
`include "vunit_defines.svh"

module adam_periph_uart_tb;
    
    localparam ADDR_WIDTH = 32;
    localparam DATA_WIDTH = 32;
    localparam STRB_WIDTH = DATA_WIDTH/8;

    localparam CLK_PERIOD = 20ns;
    localparam RST_CYCLES = 5;

    localparam TA = 2ns;
    localparam TT = CLK_PERIOD - TA;
    
    localparam NO_TESTS  = 10;
    localparam BAUD_RATE = 115200;

    typedef logic [ADDR_WIDTH-1:0] addr_t;
    typedef logic [DATA_WIDTH-1:0] data_t;
    typedef logic [STRB_WIDTH-1:0] strb_t;

    ADAM_SEQ   seq   ();
    ADAM_PAUSE pause ();

    logic irq;

    ADAM_IO tx();
    ADAM_IO rx();
    
    ADAM_PAUSE pause_auto ();
    logic critical;

    APB_DV #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH)
    ) slave_dv(seq.clk);
    APB #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH)
    ) slave();
    
    `APB_ASSIGN(slave, slave_dv)

    apb_test::apb_driver #(
        .ADDR_WIDTH (ADDR_WIDTH),
        .DATA_WIDTH (DATA_WIDTH),
        .TA         (TA),
        .TT         (TT)
    ) master = new(slave_dv);

    adam_clk_rst_bhv #(
        .CLK_PERIOD (CLK_PERIOD),
        .RST_CYCLES (RST_CYCLES),

        .TA (TA),
        .TT (TT)
    ) adam_clk_rst_bhv (
        .seq (seq)
    );

    adam_pause_bhv #(
        .DELAY    (1ms),
        .DURATION (1ms),

        .TA (TA),
        .TT (TT)
    ) adam_pause_bhv (
        .seq   (seq),
        .pause (pause_auto)
    );

    adam_periph_uart #(
        .ADDR_WIDTH (ADDR_WIDTH),
        .DATA_WIDTH (DATA_WIDTH)
    ) dut (
        .seq   (seq),
        .pause (pause),

        .apb (slave),
        
        .irq (irq),

        .tx (tx),
        .rx (rx)
    );

    always_comb begin
        pause.req = pause_auto.req && !critical;
        rx.i = tx.o;
    end

    `TEST_SUITE begin
        `TEST_CASE("test") begin
            automatic addr_t addr;
            automatic data_t data;
            automatic strb_t strb;
            automatic logic  resp;
            
            automatic data_t check;
            automatic int no_frames;
            automatic data_t frames [0:1];

            strb = 4'b1111;
            
            critical = 0;

            @(negedge seq.rst);
            master.reset_master();
            repeat (10) @(posedge seq.clk);

            critical_begin();

            // Write to Baud Rate Register (BRR)
            addr = 32'h000C;
            data = 1s / (BAUD_RATE * CLK_PERIOD);
            master.write(addr, data, strb, resp);
            assert (resp == apb_pkg::RESP_OKAY);
            
            // Verify BRR value
            master.read(addr, check, resp);
            assert (resp == apb_pkg::RESP_OKAY);
            assert (check == data);

            // Verifies behavior when peripheral is disabled
            addr = 32'h0000; // Data Register (DR)
            data = 32'h0000_0000;
            master.read(addr, check, resp);
            assert (resp == apb_pkg::RESP_SLVERR);
            master.write(addr, data, strb, resp);
            assert (resp == apb_pkg::RESP_SLVERR);

            // Write to Control Register (CR)
            // All enabled, no parity, 1 stop bit, 8 data bits
            addr = 32'h0004; 
            data = 32'h0000_0807; 
            master.write(addr, data, strb, resp);
            assert (resp == apb_pkg::RESP_OKAY);

            // Verify CR value
            master.read(addr, check, resp);
            assert (resp == apb_pkg::RESP_OKAY);
            assert (check == data);

            // IER at 0 by default => IRQ disabled by default
            assert (irq == 0);

            // Write to Interrupt Enable Register (IER)
            addr = 32'h0010;
            data = 32'hFFFF_FFFF;
            master.write(addr, data, strb, resp);
            assert (resp == apb_pkg::RESP_OKAY);

            // Verify IER value
            master.read(addr, check, resp);
            assert (resp == apb_pkg::RESP_OKAY);
            assert (check == data);

            // Write to Interrupt Enable Register (IER)
            addr = 32'h0010;
            data = 32'hFFFF_FFFF;
            master.write(addr, data, strb, resp);
            assert (resp == apb_pkg::RESP_OKAY);

            // Verify IER value
            assert (resp == apb_pkg::RESP_OKAY);
            assert (check == data);

            // Verify Transmit Buffer Empty Interrupt Enable
            assert (irq == 1); 

            critical_end();

            for(int i = 0; i < NO_TESTS; i++) begin

                critical_begin();
                
                no_frames = $urandom_range(1, 2);
                
                frames[0] = $urandom_range(0, 255);
                frames[1] = $urandom_range(0, 255);

                // Transmit
                for (int j = 0; j < no_frames; j++) begin
                    
                    do begin
                        addr = 32'h0008; // Status Register (SR)
                        master.read(addr, data, resp);
                        assert (resp == apb_pkg::RESP_OKAY);
                    end while (data[0] == 0); // Transmit Buffer Empty (TBE)

                    addr = 32'h0000; // Data Register (DR)
                    master.write(addr, frames[j], strb, resp);
                    assert (resp == apb_pkg::RESP_OKAY);

                end

                // Receive
                for (int j = 0; j < no_frames; j++) begin

                    do begin
                        addr = 32'h0008; // Status Register (SR)
                        master.read(addr, data, resp);
                        assert (resp == apb_pkg::RESP_OKAY);
                    end while (data[1] == 0); // Receive Buffer Full (RBF)

                    addr = 32'h0000; // Data Register (DR)
                    master.read(addr, check, resp);
                    assert (resp == apb_pkg::RESP_OKAY);
                    assert (check == frames[j]);

                end

                critical_end();
            end
            
            repeat (10) @(posedge seq.clk);
        end
    end

    task critical_begin();

        cycle_start();
        while (pause.req || pause.ack) begin
            cycle_end();
            cycle_start();
        end 
        cycle_end();

        critical <= #TA 1;
        cycle_start();
        cycle_end();

    endtask;

    task critical_end();
        critical <= #TA 0;
        cycle_start();
        cycle_end();
    endtask;

    task cycle_start();
        #TT;
    endtask

    task cycle_end();
        @(posedge seq.clk);
    endtask

endmodule