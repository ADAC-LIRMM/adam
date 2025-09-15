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

package adam_axil_slv_bhv;

class adam_axil_slv_bhv #(
    `ADAM_BHV_CFG_PARAMS,
    
    parameter MAX_TRANS = 4
);

    typedef struct {
        ADDR_T addr;
        PROT_T prot;
    } aw_t;

    typedef struct {
        DATA_T data;
        STRB_T strb;
    } w_t;

    typedef struct {
        RESP_T resp;
    } b_t;

    typedef struct {
        ADDR_T addr;
        PROT_T prot;
    } ar_t;
    
    typedef struct {
        DATA_T data;
        RESP_T resp;
    } r_t;

    typedef virtual AXI_LITE_DV #(
        .AXI_ADDR_WIDTH (ADDR_WIDTH),
        .AXI_DATA_WIDTH (DATA_WIDTH)
    ) axil_dv_t;

    aw_t aw_queue [$];
    w_t  w_queue  [$];
    b_t  b_queue  [$];
    ar_t ar_queue [$];
    r_t  r_queue  [$];
    
    axil_dv_t axil_dv;

    function new(
        axil_dv_t axil_dv
    );
        this.axil_dv = axil_dv;
    endfunction

    task recv_aw(
        output ADDR_T addr,
        output PROT_T prot
    );
        aw_t aw;

        while (aw_queue.size() == 0) begin
            cycle_start();
            cycle_end();
        end
        
        aw = aw_queue.pop_back();

        addr = aw.addr;
        prot = aw.prot;
    endtask

    task recv_w(
        output DATA_T data,
        output STRB_T strb
    );
        w_t w;

        while (w_queue.size() == 0) begin
            cycle_start();
            cycle_end();
        end
        
        w = w_queue.pop_back();

        data = w.data;
        strb = w.strb;
    endtask

    task send_b(
        input RESP_T resp
    );
        b_queue.push_front('{resp});
    endtask

    task recv_ar(
        output ADDR_T addr,
        output PROT_T prot
    );
        ar_t ar;

        while (ar_queue.size() == 0) begin
            cycle_start();
            cycle_end();
        end
        
        ar = ar_queue.pop_back();

        addr = ar.addr;
        prot = ar.prot;
    endtask

    task send_r(
        input DATA_T data,
        input RESP_T resp
    );
        r_queue.push_front('{data, resp});
    endtask

    task loop();
        fork
            aw_loop();
            w_loop();
            b_loop();
            ar_loop();
            r_loop();
        join
    endtask

    // AW stream
    task aw_loop();
        logic start_transfer;
        logic end_transfer;
        aw_t  aw;

        // init value
        axil_dv.aw_ready = 0;

        forever begin
            cycle_start();
            
            end_transfer = axil_dv.aw_valid && axil_dv.aw_ready;
                        
            if (end_transfer) begin
                aw.addr = axil_dv.aw_addr;
                aw.prot = axil_dv.aw_prot;
                aw_queue.push_front(aw);
            end

            start_transfer = (aw_queue.size() < MAX_TRANS);

            cycle_end();
            
            if (end_transfer) begin
                axil_dv.aw_ready <= #TA 0;
            end
            
            if (start_transfer) begin
                axil_dv.aw_ready <= #TA 1;
            end
        end
    endtask

    // W stream
    task w_loop();
        logic start_transfer;
        logic end_transfer;
        w_t   w;

        // init value
        axil_dv.w_ready <= 0;

        forever begin
            cycle_start();
            
            end_transfer = axil_dv.w_valid && axil_dv.w_ready;
            
            if (end_transfer) begin
                w.data = axil_dv.w_data;
                w.strb = axil_dv.w_strb;
                w_queue.push_front(w);
            end

            start_transfer = (w_queue.size() < MAX_TRANS);
            
            cycle_end();
            
            if (end_transfer) begin
                axil_dv.w_ready <= #TA 0;
            end
            
            if (start_transfer) begin
                axil_dv.w_ready <= #TA 1;
            end
        end
    endtask

    // B stream
    task b_loop();
        logic start_transfer;
        logic end_transfer;
        b_t   b;

        // init value
        axil_dv.b_resp  = 0;
        axil_dv.b_valid = 0;

        forever begin
            cycle_start();
            
            end_transfer = axil_dv.b_valid && axil_dv.b_ready;
            
            start_transfer = (!axil_dv.b_valid || end_transfer) &&
                (b_queue.size() > 0);
            
            cycle_end();

            if (start_transfer) begin
                b = b_queue.pop_back();
            
                axil_dv.b_resp  <= #TA b.resp;
                axil_dv.b_valid <= #TA 1;
            end
            else if (end_transfer) begin
                axil_dv.b_resp  <= #TA 0;
                axil_dv.b_valid <= #TA 0;
            end
        end
    endtask

    // AR stream
    task ar_loop();
        logic start_transfer;
        logic end_transfer;
        ar_t  ar;

        // init value
        axil_dv.ar_ready <= 0;

        forever begin
            cycle_start();
            
            end_transfer = axil_dv.ar_valid && axil_dv.ar_ready;
            
            if (end_transfer) begin
                ar.addr = axil_dv.ar_addr;
                ar.prot = axil_dv.ar_prot;
                ar_queue.push_front(ar);
            end

            start_transfer = (ar_queue.size() < MAX_TRANS);
            
            cycle_end();
            
            if (end_transfer) begin
                axil_dv.ar_ready <= #TA 0;
            end
            
            if (start_transfer) begin
                axil_dv.ar_ready <= #TA 1;
            end
        end
    endtask

    // For R stream
    task r_loop();
        logic start_transfer;
        logic end_transfer;
        r_t   r;

        // init value
        axil_dv.r_data  = 0;
        axil_dv.r_resp  = 0;
        axil_dv.r_valid = 0;

        forever begin
            cycle_start();
            
            end_transfer = axil_dv.r_valid && axil_dv.r_ready;
            
            start_transfer = (!axil_dv.r_valid || end_transfer) &&
                (r_queue.size() > 0);
            
            cycle_end();

            if (start_transfer) begin
                r = r_queue.pop_back();

                axil_dv.r_data  <= #TA r.data;
                axil_dv.r_resp  <= #TA r.resp;
                axil_dv.r_valid <= #TA 1;
            end
            else if (end_transfer) begin
                axil_dv.r_data  <= #TA 0;
                axil_dv.r_resp  <= #TA 0;
                axil_dv.r_valid <= #TA 0;
            end
        end
    endtask

    task cycle_start();
        #TT;
    endtask

    task cycle_end();
        @(posedge axil_dv.clk_i);
    endtask

endclass

endpackage
