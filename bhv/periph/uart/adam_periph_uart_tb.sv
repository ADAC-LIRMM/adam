/*
 * Copyright 2025 LIRMM
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */


`timescale 1ns/1ps
`include "adam/macros_bhv.svh"
`include "apb/assign.svh"
`include "vunit_defines.svh"

module adam_periph_uart_tb;
    
    `ADAM_BHV_CFG_LOCALPARAMS;
    
    localparam NO_TESTS  = 10;
    localparam BAUD_RATE = 115200;

    ADAM_SEQ   seq   ();
    ADAM_PAUSE pause ();

    logic irq;

    ADAM_IO tx();
    ADAM_IO rx();
    
    ADAM_PAUSE pause_auto ();
    logic critical;

    `ADAM_APB_DV_I slave_dv (seq.clk);
    `ADAM_APB_I slave ();
    
    `APB_ASSIGN(slave, slave_dv);

    apb_test::apb_driver #(
        .ADDR_WIDTH (ADDR_WIDTH),
        .DATA_WIDTH (DATA_WIDTH),
        .TA         (TA),
        .TT         (TT)
    ) master = new(slave_dv);

    adam_seq_bhv #(
        `ADAM_CFG_PARAMS_MAP
    ) adam_seq_bhv (
        .seq (seq)
    );

    adam_pause_bhv #(
        `ADAM_CFG_PARAMS_MAP,
        
        .DELAY    (1ms),
        .DURATION (1ms)
    ) adam_pause_bhv (
        .seq   (seq),
        .pause (pause_auto)
    );

    adam_periph_uart #(
        `ADAM_CFG_PARAMS_MAP
    ) dut (
        .seq   (seq),
        .pause (pause),

        .slv (slave),
        
        .irq (irq),

        .tx (tx),
        .rx (rx)
    );

    always_comb begin
        pause.req = pause_auto.req && !critical;
        pause_auto.ack = pause.ack;

        rx.i = tx.o;
    end

    `TEST_SUITE begin
        `TEST_CASE("test") begin
            automatic ADDR_T addr;
            automatic DATA_T data;
            automatic STRB_T strb;
            automatic logic  resp;
            
            automatic DATA_T check;
            automatic int    no_frames;
            automatic DATA_T frames [0:1];

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

    initial begin
        #100ms $error("timeout");
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