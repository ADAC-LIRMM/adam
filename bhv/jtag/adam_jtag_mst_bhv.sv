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

package adam_jtag_mst_bhv;

class adam_jtag_mst_bhv #(
    `ADAM_BHV_CFG_PARAMS,

    parameter MAX_WIDTH  = 64,
    parameter TCK_PERIOD = 100ns
);
    typedef logic [MAX_WIDTH-1:0] vec;
 
    typedef virtual ADAM_JTAG jtag_t;

    jtag_t jtag;

    function new(
        jtag_t jtag
    );
        this.jtag = jtag;
    endfunction

    task tap_reg_write(
        input vec ir,
        input int ir_size,
        input vec dr,
        input int dr_size
    );
        vec ir_o;
        vec dr_o;

        tap_ir(ir, ir_o, ir_size);
        tap_dr(dr, dr_o, dr_size);
    endtask;

    task tap_reg_read(
        input  vec ir,
        input  int ir_size,
        output vec dr,
        input  int dr_size
    );
        vec ir_o;
    
        tap_ir(ir, ir_o, ir_size);
        tap_dr('0, dr,   dr_size);
    endtask;

    task reset();
        jtag.trst_n = 0;
        jtag.tck    = 0;
        jtag.tms    = 0;
        jtag.tdi    = 0;

        pulse_clock(5);

        jtag.trst_n = 1;
    endtask

    task tap_reset();
        jtag.tms = 1; pulse_clock(5); // Apply >= 5 TCK cycles with TMS high
        jtag.tms = 0; pulse_clock(1); // Exit Test-Logic-Reset state
    endtask

    task tap_nop();
        jtag.tms = 0; pulse_clock(1); // Run-Test/Idle
    endtask;

    task tap_ir(
        input  vec ir_i,
        output vec ir_o,
        input  int size
    );
        // Assuming we are in Run-Test/Idle state
        jtag.tms = 1; pulse_clock(1); // Select-DR-Scan
        jtag.tms = 1; pulse_clock(1); // Select-IR-Scan
        jtag.tms = 0; pulse_clock(1); // Capture-IR
        jtag.tms = 0; pulse_clock(1); // Shift-IR

        for (int i = 0; i < size; i++) begin

            if (i == size-1) begin
                jtag.tms = 1; // Exit1-IR
            end

            jtag.tdi = ir_i[i];
            pulse_clock(1);
            ir_o[i] = jtag.tdo;
        end

        jtag.tms = 1; pulse_clock(1); // Update-IR
        jtag.tms = 0; pulse_clock(1); // Run-Test/Idle
    endtask

    task tap_dr(
        input  vec dr_i,
        output vec dr_o,
        input  int size
    );
        jtag.tms = 1; pulse_clock(1); // Select-DR-Scan
        jtag.tms = 0; pulse_clock(1); // Capture-DR
        jtag.tms = 0; pulse_clock(1); // Shift-DR

        for (int i = 0; i < size; i++) begin

            if (i == size-1) begin
                jtag.tms = 1; // Exit1-DR
            end

            jtag.tdi = dr_i[i]; 
            pulse_clock(1);
            dr_o[i] = jtag.tdo;
        end

        jtag.tms = 1; pulse_clock(1); // Update-DR
        jtag.tms = 0; pulse_clock(1); // Run-Test/Idle
    endtask

    task pulse_clock(
        input int cycles
    );
        repeat (cycles) begin
            #(TCK_PERIOD/2); jtag.tck <= 1;
            #(TCK_PERIOD/2); jtag.tck <= 0;
        end
    endtask

endclass

endpackage