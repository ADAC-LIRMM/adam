
`include "apb/assign.svh"
`include "vunit_defines.svh"

module adam_periph_timer_tb;

    localparam ADDR_WIDTH = 32;
    localparam DATA_WIDTH = 32;

    localparam STRB_WIDTH = DATA_WIDTH/8;

    localparam CLK_PERIOD = 20ns;
    localparam RST_CYCLES = 5;

    localparam TA = 2ns;
    localparam TT = CLK_PERIOD - TA;

    localparam NO_TESTS = 10; 
    localparam FREQ     = 1e6;

    typedef logic [ADDR_WIDTH-1:0] addr_t;
    typedef logic [DATA_WIDTH-1:0] data_t;
    typedef logic [STRB_WIDTH-1:0] strb_t;

    logic clk;
    logic rst;

    logic pause_req;
    logic pause_ack;

    logic irq;

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
        .DELAY    (100us),
        .DURATION (100us),

        .TA (TA),
        .TT (TT)
    ) adam_pause_bhv (
        .rst (rst),
        .clk (clk),

        .pause_req (pause_req_auto),
        .pause_ack (pause_ack)
    );

    adam_periph_timer #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH)
    ) dut (
        .clk  (clk),
        .rst  (rst),

        .pause_req (pause_req),
        .pause_ack (pause_ack),

        .apb (slave),
        
        .irq (irq)
    );

    always_comb begin
        pause_req = pause_req_auto && !critical;
    end

    `TEST_SUITE begin
        `TEST_CASE("test") begin
            automatic addr_t addr;
            automatic data_t data;
            automatic strb_t strb;
            automatic logic  resp;
            
            automatic data_t check;

            automatic data_t value;
            automatic data_t auto_reload;
            automatic int no_events;

            strb = 4'b1111;

            critical = 0;

            @(negedge rst);
            master.reset_master();
            repeat (10) @(posedge clk);

            critical_begin();

            // Write to Prescaler Register (PR)
            addr = 32'h0004;
            data = 50e6 / FREQ;
            master.write(addr, data, strb, resp);
            assert (resp == apb_pkg::RESP_OKAY);
        
            // Verify PR value
            master.read(addr, check, resp);
            assert (resp == apb_pkg::RESP_OKAY);
            assert (check == data);

            // Write to Interrupt Enable Register (IER)
            addr = 32'h0014;
            data = 32'hFFFF_FFFF;
            master.write(addr, data, strb, resp);
            assert (resp == apb_pkg::RESP_OKAY);

            // Verify IER value
            master.read(addr, check, resp);
            assert (resp == apb_pkg::RESP_OKAY);
            assert (check == data);

            critical_end();

            repeat (NO_TESTS) begin
                critical_begin();

                value       = $urandom_range(         0, 100);
                auto_reload = $urandom_range(value + 10, 110);
                no_events   = $urandom_range(         0,  10);

                // Write to Control Register (CR)
                // Disable Timer
                addr = 32'h0000;
                data = 32'h0000_0000;
                master.write(addr, data, strb, resp);
                assert (resp == apb_pkg::RESP_OKAY);

                // Write to Value Register (VR)
                addr = 32'h0008; 
                data = value;
                master.write(addr, data, strb, resp);
                assert (resp == apb_pkg::RESP_OKAY);

                // Verify VR value
                master.read(addr, check, resp);
                assert (resp == apb_pkg::RESP_OKAY);
                assert (check == data);

                // Write to Auto Reload Register (ARR)
                addr = 32'h000C; 
                data = auto_reload; 
                master.write(addr, data, strb, resp);
                assert (resp == apb_pkg::RESP_OKAY);

                // Verify ARR value
                master.read(addr, check, resp);
                assert (resp == apb_pkg::RESP_OKAY);
                assert (check == data);
                
                // Write to Control Register (CR)
                // Enable Timer
                addr = 32'h0000; 
                data = 32'h0000_0001; 
                master.write(addr, data, strb, resp);
                assert (resp == apb_pkg::RESP_OKAY);

                // Verify CR value
                master.read(addr, check, resp);
                assert (resp == apb_pkg::RESP_OKAY);
                assert (check == data);

                // Verify Event Register (ER)
                addr = 32'h0010;
                data = 32'h0000_0000;
                master.read(addr, check, resp);
                assert (resp == apb_pkg::RESP_OKAY);
                assert (check == data);

                fork
                    repeat (no_events) begin
                        @(posedge irq);
                        
                        // Write to Event Register (ER)
                        // Clear Event
                        addr = 32'h0010; 
                        data = 32'h0000_0001; 
                        master.write(addr, data, strb, resp);
                        assert (resp == apb_pkg::RESP_OKAY);
                    end

                    repeat (no_events) begin
                        @(negedge irq);
                    end
                join

                critical_end();
            end
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