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

module adam_periph_gpio_tb;

    `ADAM_BHV_CFG_LOCALPARAMS;
        
    localparam NO_TESTS  = 100;

    ADAM_SEQ   seq   ();
    ADAM_PAUSE pause ();

    ADAM_IO     io   [GPIO_WIDTH] ();
    logic [1:0] func [GPIO_WIDTH];

    ADAM_PAUSE pause_auto ();
    logic critical;

    logic irq;
    logic ref_irq;

    GPIO_T idr;
    GPIO_T ref_idr;
    
    GPIO_T odr;
    GPIO_T ref_odr;

    GPIO_T moder;
    GPIO_T ref_moder;

    GPIO_T otyper;
    GPIO_T ref_otyper;

    GPIO_T fsr     [2];
    GPIO_T ref_fsr [2];

    GPIO_T ref_ier;

    `ADAM_APB_DV_I slave_dv (seq.clk);

    `ADAM_APB_I slave ();
    
    `APB_ASSIGN(slave, slave_dv)

    apb_test::apb_driver #(
        .ADDR_WIDTH (ADDR_WIDTH),
        .DATA_WIDTH (DATA_WIDTH),
        .TA         (TA),
        .TT         (TT)
    ) master = new(slave_dv);

    adam_seq_bhv #(
        `ADAM_BHV_CFG_PARAMS_MAP
    ) adam_seq_bhv (
        .seq (seq)
    );

    adam_pause_bhv #(
        `ADAM_BHV_CFG_PARAMS_MAP,

        .DELAY    (1us),
        .DURATION (1us)
    ) adam_pause_bhv (
        .seq   (seq),
        .pause (pause_auto)
    );

    adam_periph_gpio #(
        `ADAM_CFG_PARAMS_MAP
    ) dut (
        .seq   (seq),
        .pause (pause),

        .slv (slave),
        
        .irq (irq),

        .io   (io),
        .func (func)
    );

    generate
        for (genvar i = 0; i < GPIO_WIDTH; i++) begin
            assign io[i].i = idr[i];

            assign odr[i]    = io[i].o;
            assign moder[i]  = io[i].mode;
            assign otyper[i] = io[i].otype;
        end
    endgenerate

    always_comb begin
        automatic int word;
        automatic int bit_;

        fsr[0] = 0;
        fsr[1] = 0;
        
        for (int i = 0; i < GPIO_WIDTH; i++) begin
            for (int j = 0; j < 2; j++) begin
                word = (2*i + j) / DATA_WIDTH;
                bit_ = (2*i + j) % DATA_WIDTH;
                fsr[word][bit_] = func[i][j];
            end
        end 
    end

    always_comb begin
        pause.req = pause_auto.req && !critical;
        pause_auto.ack = pause.ack;
    end
    
    `TEST_SUITE begin
        `TEST_CASE("test") begin
            automatic ADDR_T addr;
            automatic GPIO_T data;
            automatic STRB_T strb;
            automatic logic  resp;
            automatic bit    write;

            automatic GPIO_T tmp;

            ref_irq    = 0;
            ref_idr    = 0;
            ref_odr    = 0;
            ref_moder  = 0;
            ref_otyper = 0;
            ref_fsr[0] = 0;
            ref_fsr[1] = 0;
            ref_ier    = 0;

            critical = 0;

            @(negedge seq.rst);
            master.reset_master();
            repeat (10) @(posedge seq.clk);

            for(int i = 0; i < NO_TESTS; i++) begin
                addr  = $urandom_range(0, 6) << $clog2(ADDR_WIDTH/8);
                data  = $urandom();
                strb  = $urandom();
                write = $urandom_range(0, 1);

                idr     = $urandom();
                ref_idr = idr;

                critical_begin();

                if (write) begin
                    $display("Write addr: %0h", addr);
                    $display("Write data: %0h strb: %0h", data, strb);
                    
                    master.write(addr, data, strb, resp);

                    $display("Write resp: %0h", resp);

                    case (addr)
                        32'h00:
                            assert (resp == apb_pkg::RESP_SLVERR);
                        32'h04, 32'h08, 32'h0C, 32'h10, 32'h14, 32'h18:
                            assert (resp == apb_pkg::RESP_OKAY);
                    endcase
                    
                    for (int i = 0; i < GPIO_WIDTH/8; i++) begin
                        if (strb[i]) begin
                            case (addr)
                                32'h00: ;
                                32'h04: ref_odr   [i*8 +: 8] = data[i*8 +: 8];
                                32'h08: ref_moder [i*8 +: 8] = data[i*8 +: 8];
                                32'h0C: ref_otyper[i*8 +: 8] = data[i*8 +: 8];
                                32'h10: ref_fsr[0][i*8 +: 8] = data[i*8 +: 8];
                                32'h14: ref_fsr[1][i*8 +: 8] = data[i*8 +: 8];
                                32'h18: ref_ier   [i*8 +: 8] = data[i*8 +: 8];
                            endcase
                        end
                    end
                end
                else begin
                    $display("Read from addr: %0h", addr);
                    
                    master.read(addr, data, resp);

                    $display("Read data: %0h", data);
                    $display("Read resp: %0h", resp);

                    assert (resp == apb_pkg::RESP_OKAY);

                    tmp = data[GPIO_WIDTH-1:0];

                    case (addr)
                        32'h00: assert (tmp == ref_idr   );
                        32'h04: assert (tmp == ref_odr   );
                        32'h08: assert (tmp == ref_moder );
                        32'h0C: assert (tmp == ref_otyper);
                        32'h10: assert (tmp == ref_fsr[0]);
                        32'h14: assert (tmp == ref_fsr[1]);
                        32'h18: assert (tmp == ref_ier   );
                    endcase
                end

                ref_irq = 0;
                for (int i = 0; i < GPIO_WIDTH; i++) begin
                    ref_irq |= ref_ier[i] & ref_idr[i];
                end

                assert (irq == ref_irq); 

                critical_end();

            end
            
            repeat (10) @(posedge seq.clk);   
        end
    end

    initial begin
        #100us $error("timeout");
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