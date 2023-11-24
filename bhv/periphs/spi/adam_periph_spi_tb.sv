
`include "apb/assign.svh"
`include "vunit_defines.svh"

module adam_periph_spi_tb;

    localparam ADDR_WIDTH = 32;
    localparam DATA_WIDTH = 32;
    localparam STRB_WIDTH = DATA_WIDTH/8;

    localparam CLK_PERIOD = 20ns;
    localparam RST_CYCLES = 5;

    localparam TA = 2ns;
    localparam TT = CLK_PERIOD - TA;
    
    localparam NO_TESTS  = 100;
    localparam BAUD_RATE = 1000000;

    typedef logic [ADDR_WIDTH-1:0] addr_t;
    typedef logic [DATA_WIDTH-1:0] data_t;
    typedef logic [STRB_WIDTH-1:0] strb_t;

    logic clk;
    logic rst;

    logic pause_req;
    logic pause_ack;

    logic irq;
    
    ADAM_IO sclk();
    ADAM_IO mosi();
    ADAM_IO miso();
    ADAM_IO ss_n();

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

    apb_test::apb_driver #(
        .ADDR_WIDTH (ADDR_WIDTH),
        .DATA_WIDTH (DATA_WIDTH),
        .TA         (TA),
        .TT         (TT)
    ) master = new(slave_dv);

    adam_periph_spi #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH)
    ) dut (
        .clk  (clk),
        .rst  (rst),

        .pause_req (pause_req),
        .pause_ack (pause_ack),

        .apb (slave),
        
        .irq (irq),

        .sclk (sclk),
        .mosi (mosi),
        .miso (miso),
        .ss_n (ss_n)
    );

    // loopback
    always_comb begin
        pause_req = pause_req_auto && !critical;

        miso.i = mosi.o;
    end

    `TEST_SUITE begin
        `TEST_CASE("test") begin
            automatic addr_t addr;
            automatic data_t data;
            automatic strb_t strb;
            automatic logic  resp;
            
            automatic data_t check;

            strb = 4'b1111;

            critical = 0;
            
            @(negedge rst);
            master.reset_master();
            repeat (10) @(posedge clk);

            critical_begin();

            // Write to Baud Rate Register (BRR)
            addr = 32'h000C;
            data = 50e6 / BAUD_RATE;
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
            // All enabled, master, leading edge, low polarity, lsb, 8 bit frame 
            addr = 32'h0004; 
            data = 32'h0000_080F; 
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

            addr = 32'h0000; // Data Register (DR)

            for(int i = 0; i < NO_TESTS; i++) begin            
                
                critical_begin();
                
                do begin
                    addr = 32'h0008; // Status Register (SR)
                    master.read(addr, data, resp);
                    assert (resp == apb_pkg::RESP_OKAY);
                end while (data[0] == 0); // Transmit Buffer Empty (TBE)

                addr = 32'h0000; // Data Register (DR)
                data = data_t'(i);
                master.write(addr, data, strb, resp);
                $display("tx: %02h", data);
                assert (resp == apb_pkg::RESP_OKAY);
                
                do begin
                    addr = 32'h0008; // Status Register (SR)
                    master.read(addr, data, resp);
                    assert (resp == apb_pkg::RESP_OKAY);
                end while (data[1] == 0); // Receive Buffer Full (RBF)


                addr = 32'h0000; // Data Register (DR)
                data = data_t'(i);
                master.read(addr, check, resp);
                $display("rx: %02h", check);
                assert (resp == apb_pkg::RESP_OKAY);
                assert (check == data);
            
                critical_end();

            end
            
            repeat (10) @(posedge clk);
        end
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