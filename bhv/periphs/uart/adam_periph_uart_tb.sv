
`include "apb/assign.svh"

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

    logic clk;
    logic rst;
    logic test;

    logic pause_req;
    logic pause_ack;

    logic irq;

    ADAM_IO tx();
    ADAM_IO rx();
    
    logic pause_req_auto;
    logic critical;

    APB_DV #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH)
    ) slave_dv(clk);
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
        .clk (clk),
        .rst (rst)
    );

    adam_pause_bhv #(
        .DELAY    (1ms),
        .DURATION (1ms),

        .TA (TA),
        .TT (TT)
    ) adam_pause_bhv (
        .rst (rst),
        .clk (clk),

        .pause_req (pause_req_auto),
        .pause_ack (pause_ack)
    );

    adam_periph_uart #(
        .ADDR_WIDTH (ADDR_WIDTH),
        .DATA_WIDTH (DATA_WIDTH)
    ) dut (
        .clk  (clk),
        .rst  (rst),
        .test (test),

        .pause_req (pause_req),
        .pause_ack (pause_ack),

        .apb (slave),
        
        .irq (irq),

        .tx (tx),
        .rx (rx)
    );

    always_comb begin
        pause_req = pause_req_auto && !critical;

        rx.i = tx.o;
    end

    initial begin
        automatic addr_t addr;
        automatic data_t data;
        automatic strb_t strb;
        automatic logic  resp;
        
        automatic data_t check;
        automatic int no_frames;
        automatic data_t frames [0:1];

        test = 1;
        strb = 4'b1111;
        
        critical = 0;

        @(negedge rst);
        master.reset_master();
        repeat (10) @(posedge clk);

        critical_begin();

        // Write to Baud Rate Register (BRR)
        addr = 32'h000C;
        data = 1s / (BAUD_RATE * CLK_PERIOD);
        master.write(addr, data, strb, resp);
        assert (resp == apb_pkg::RESP_OKAY) else $finish(1);
        
        // Verify BRR value
        master.read(addr, check, resp);
        assert (resp == apb_pkg::RESP_OKAY) else $finish(1);
        assert (check == data) else $finish(1);

        // Verifies behavior when peripheral is disabled
        addr = 32'h0000; // Data Register (DR)
        data = 32'h0000_0000;
        master.read(addr, check, resp);
        assert (resp == apb_pkg::RESP_SLVERR) else $finish(1);
        master.write(addr, data, strb, resp);
        assert (resp == apb_pkg::RESP_SLVERR) else $finish(1);

        // Write to Control Register (CR)
        // All enabled, no parity, 1 stop bit, 8 data bits
        addr = 32'h0004; 
        data = 32'h0000_0807; 
        master.write(addr, data, strb, resp);
        assert (resp == apb_pkg::RESP_OKAY) else $finish(1);

        // Verify CR value
        master.read(addr, check, resp);
        assert (resp == apb_pkg::RESP_OKAY) else $finish(1);
        assert (check == data) else $finish(1);

        // IER at 0 by default => IRQ disabled by default
        assert (irq == 0) else $finish(1);

        // Write to Interrupt Enable Register (IER)
        addr = 32'h0010;
        data = 32'hFFFF_FFFF;
        master.write(addr, data, strb, resp);
        assert (resp == apb_pkg::RESP_OKAY) else $finish(1);

        // Verify IER value
        master.read(addr, check, resp);
        assert (resp == apb_pkg::RESP_OKAY) else $finish(1);
        assert (check == data) else $finish(1);

        // Write to Interrupt Enable Register (IER)
        addr = 32'h0010;
        data = 32'hFFFF_FFFF;
        master.write(addr, data, strb, resp);
        assert (resp == apb_pkg::RESP_OKAY) else $finish(1);

        // Verify IER value
        assert (resp == apb_pkg::RESP_OKAY) else $finish(1);
        assert (check == data) else $finish(1);

        // Verify Transmit Buffer Empty Interrupt Enable
        assert (irq == 1) else $finish(1); 

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
                    assert (resp == apb_pkg::RESP_OKAY) else $finish(1);
                end while (data[0] == 0); // Transmit Buffer Empty (TBE)

                addr = 32'h0000; // Data Register (DR)
                master.write(addr, frames[j], strb, resp);
                assert (resp == apb_pkg::RESP_OKAY) else $finish(1);

            end

            // Receive
            for (int j = 0; j < no_frames; j++) begin

                do begin
                    addr = 32'h0008; // Status Register (SR)
                    master.read(addr, data, resp);
                    assert (resp == apb_pkg::RESP_OKAY) else $finish(1);
                end while (data[1] == 0); // Receive Buffer Full (RBF)

                addr = 32'h0000; // Data Register (DR)
                master.read(addr, check, resp);
                assert (resp == apb_pkg::RESP_OKAY) else $finish(1);
                assert (check == frames[j]) else $finish(1);

            end

            critical_end();
        end
        
        repeat (10) @(posedge clk);
        
        $stop();
    end

    task critical_begin();

        cycle_start();
        while (pause_req || pause_ack) begin
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
        @(posedge clk);
    endtask

endmodule