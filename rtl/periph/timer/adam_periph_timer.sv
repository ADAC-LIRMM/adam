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

`include "adam/macros.svh"

module adam_periph_timer #(
    `ADAM_CFG_PARAMS
) (    
    ADAM_SEQ.Slave   seq,
    ADAM_PAUSE.Slave pause,

    APB.Slave slv,

    output logic irq
);

    // Registers
    DATA_T control;
    DATA_T prescaler;
    DATA_T value;
    DATA_T auto_reload;
    DATA_T events;
    DATA_T interrupt_enable;

    // Control Register (CR)
    logic peripheral_enable;

    // Event Register (ER)
    logic auto_reload_event;

    // Interrupt Enable Register (IER)
    logic auto_reload_event_ie;

    // APB
    ADDR_T paddr;
    logic  psel;
    logic  penable;
    logic  pwrite;
    DATA_T pwdata;
    STRB_T pstrb;
    logic  pready;
    DATA_T prdata;
    logic  pslverr;
    
    ADDR_T index;
    DATA_T  mask;

    DATA_T clk_count;

    always_comb begin

        // APB inputs
        paddr   = slv.paddr;
        psel    = slv.psel;
        penable = slv.penable;
        pwrite  = slv.pwrite;
        pwdata  = slv.pwdata;
        pstrb   = slv.pstrb;
        
        // APB outputs
        slv.pready  = pready;
        slv.prdata  = prdata;
        slv.pslverr = pslverr;

        // APB address
        index = paddr[ADDR_WIDTH-1:$clog2(STRB_WIDTH)];

        // APB strobe
        for (int i = 0; i < DATA_WIDTH/8; i++) begin
            mask[i*8 +: 8] = (slv.pstrb[i]) ? 8'hFF : 8'h00; 
        end
        
        // Control Register (CR) 
        peripheral_enable = control[0];

        // Event Register (ER)
        auto_reload_event = events[0];

        // Interrupt Enable Register (IER)
        auto_reload_event_ie = interrupt_enable[0];

        // IRQ
        irq = (peripheral_enable && !pause.ack) && (
            (auto_reload_event && auto_reload_event_ie)
        );
    end

    always_ff @(posedge seq.clk) begin
        if (seq.rst) begin
            control          <= 0;
            prescaler        <= 0;
            value            <= 0;
            auto_reload      <= 0;
            events           <= 0;
            interrupt_enable <= 0;

            prdata  <= 0;
            pready  <= 0;
            pslverr <= 0;

            clk_count <= 0;

            pause.ack <= 1;
        end
        else if (pause.req && pause.ack) begin
            // PAUSED
        end
        else begin
            if (
                (!pause.req) &&   // no pause request
                (psel && !pready) // pending APB transaction
            ) case (index)

                12'h000: begin // Control Register (CR)
                    if (pwrite) begin
                        control <= (pwdata & mask) | (control & ~mask);
                    end
                    else begin
                        prdata  <= control;
                    end

                    pready <= 1;                  
                end

                12'h001: begin // Prescaler Register (PR)
                    if (pwrite) begin
                        prescaler <= (pwdata & mask) | (prescaler & ~mask);
                    end
                    else begin
                        prdata <= prescaler;
                    end

                    pready <= 1;
                end

                12'h002: begin // Value Register (VR)
                    if (pwrite) begin
                        value <= (pwdata & mask) | (value & ~mask);
                    end
                    else begin
                        prdata <= value;
                    end 

                    pready <= 1;
                end

                12'h003: begin // Auto Reload Register (ARR)
                    if (pwrite) begin
                        auto_reload <= (pwdata & mask) | (auto_reload & ~mask);
                    end
                    else begin
                        prdata <= auto_reload;
                    end

                    pready <= 1;
                end

                12'h004: begin // Event Register (ER)
                    if (pwrite) begin
                        // clear
                        events <= events & ~(pwdata & mask);
                    end
                    else begin
                        prdata <= events;
                    end

                    pready <= 1;
                end

                12'h005: begin // Interrupt Enable Register (IER)
                    if (pwrite) begin
                        interrupt_enable <=
                            (pwdata & mask) | (interrupt_enable & ~mask);
                    end
                    else begin
                        prdata <= interrupt_enable;
                    end

                    pready <= 1;
                end

                default: begin // Error
                    pready  <= 1;
                    pslverr <= 1;
                end
            endcase
            else if (
                (!pause.ack) &&             // not paused
                (psel && penable && pready) // transaction completed
            ) begin
                // reset APB outputs.
                prdata  <= 0;
                pready  <= 0;
                pslverr <= 0;
            end
            else if (pause.req && !pause.ack) begin
                // pause
                pause.ack <= 1;

                // tie APB interface off
                prdata  <= 0;
                pready  <= 1;
                pslverr <= 1;
            end
            else if (!pause.req && pause.ack) begin
                // resume
                pause.ack <= 0;

                // reset APB outputs
                prdata  <= 0;
                pready  <= 0;
                pslverr <= 0;
            end

            if (peripheral_enable) begin
                if (clk_count < prescaler) begin
                    clk_count <= clk_count + 1;
                end
                else begin
                    clk_count <= 0;
                
                    if (value == auto_reload) begin
                        events[0] <= 1; // Auto Reload Event
                        value     <= 0;
                    end
                    else begin
                        value <= value + 1;
                    end
                end
            end
            else begin
                clk_count <= 0;
                events    <= 0;
            end
        end
    end

endmodule
