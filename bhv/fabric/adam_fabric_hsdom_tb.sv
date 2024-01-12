`timescale 1ns/1ps
`include "adam/macros_bhv.svh"
`include "axi/assign.svh"
`include "vunit_defines.svh"

module adam_fabric_hsdom_tb;
    import adam_axil_mst_bhv::*;
    import adam_axil_slv_bhv::*;

    `ADAM_BHV_CFG_LOCALPARAMS;

    localparam MAX_TRANS = FAB_MAX_TRANS;

    localparam NO_MSTS = 2*NO_CPUS + NO_DMAS + EN_DEBUG + 1;
    localparam NO_SLVS = NO_MEMS + NO_HSPS + EN_DEBUG + 1;
    
    // seq and pause ==========================================================

    ADAM_SEQ   seq   ();
    ADAM_PAUSE pause ();
    
    adam_seq_bhv #(
        `ADAM_BHV_CFG_PARAMS_MAP
    ) adam_seq_bhv (
        .seq (seq)
    );

    adam_pause_bhv #(
        `ADAM_BHV_CFG_PARAMS_MAP,

        .DELAY    (10us),
        .DURATION (10us)
    ) adam_pause_bhv (
        .seq   (seq),
        .pause (pause)
    );
    
    // Masters ================================================================

    `ADAM_AXIL_I cpu [2*NO_CPUS+1] ();
    `ADAM_AXIL_I dma [NO_DMAS+1] ();
    `ADAM_AXIL_I debug_mst ();
    `ADAM_AXIL_I from_lsdom ();

    `ADAM_AXIL_BHV_MST_ARRAY_FACTORY(MAX_TRANS, mst, NO_MSTS, seq.clk);

    generate
        localparam CPU_S = 0;
        localparam CPU_E = CPU_S + 2*NO_CPUS;

        localparam DMA_S = CPU_E;
        localparam DMA_E = DMA_S + NO_DMAS;

        localparam DEBUG_MST_S = DMA_E;
        localparam DEBUG_MST_E = DEBUG_MST_S + EN_DEBUG;

        localparam FROM_LSDOM_S = DEBUG_MST_E;
        localparam FROM_LSDOM_E = FROM_LSDOM_S + 1;

        for (genvar i = CPU_S; i < CPU_E; i++) begin
            `AXI_LITE_ASSIGN(cpu[i-CPU_S], mst[i]);
        end

        for (genvar i = DMA_S; i < DMA_E; i++) begin
            `AXI_LITE_ASSIGN(dma[i-DMA_S], mst[i]);
        end

        for (genvar i = DEBUG_MST_S; i < DEBUG_MST_E; i++) begin
            `AXI_LITE_ASSIGN(debug_mst, mst[i]);
        end

        for (genvar i = FROM_LSDOM_S; i < FROM_LSDOM_E; i++) begin
            `AXI_LITE_ASSIGN(from_lsdom, mst[i]);
        end
    endgenerate

    // Slaves =================================================================

    `ADAM_AXIL_I mem  [NO_MEMS+1] ();
    `ADAM_AXIL_I hsp [NO_HSPS+1] ();
    `ADAM_AXIL_I debug_slv ();
    `ADAM_AXIL_I to_lsdom ();

    MMAP_T addr_map [NO_SLVS+1];

    generate  
        localparam MEM_S = 0;
        localparam MEM_E = MEM_S + NO_MEMS;

        localparam HSP_S = MEM_E;
        localparam HSP_E = HSP_S + NO_HSPS;

        localparam DEBUG_SLV_S = HSP_E;
        localparam DEBUG_SLV_E = DEBUG_SLV_S + EN_DEBUG;

        localparam TO_LSDOM_S = DEBUG_SLV_E;
        localparam TO_LSDOM_E = TO_LSDOM_S + 1;

        for (genvar i = MEM_S; i < MEM_E; i++) begin
            assign addr_map[i] = '{
                start : MMAP_MEM.start + MMAP_MEM.inc*i,
                end_  : MMAP_MEM.start + MMAP_MEM.inc*(i+1),
                inc   : '0
            };

            adam_axil_slv_simple_bhv #(
                `ADAM_BHV_CFG_PARAMS_MAP,

                .ADDR_S ('0),
                .ADDR_E (MMAP_MEM.inc),
                .DATA   (i),

                .MAX_TRANS (MAX_TRANS)
            ) mem_bhv (
                .seq (seq),
                .slv (mem[i-MEM_S])
            );
        end

        for (genvar i = HSP_S; i < HSP_E; i++) begin
            assign addr_map[i] = '{
                start : MMAP_HSP.start + MMAP_HSP.inc*i,
                end_  : MMAP_HSP.start + MMAP_HSP.inc*(i+1),
                inc   : '0
            };

            adam_axil_slv_simple_bhv #(
                `ADAM_BHV_CFG_PARAMS_MAP,

                .ADDR_S ('0),
                .ADDR_E (MMAP_HSP.inc),
                .DATA   (i),

                .MAX_TRANS (MAX_TRANS)
            ) mem_bhv (
                .seq (seq),
                .slv (hsp[i-HSP_S])
            );
        end

        for (genvar i = DEBUG_SLV_S; i < DEBUG_SLV_E; i++) begin
            assign addr_map[i] = {
                start : MMAP_DEBUG.start,
                end_  : MMAP_DEBUG.end_,
                inc   : '0
            };

            adam_axil_slv_simple_bhv #(
                `ADAM_BHV_CFG_PARAMS_MAP,

                .ADDR_S ('0),
                .ADDR_E (MMAP_DEBUG.end_ - MMAP_DEBUG.start),
                .DATA   (i),

                .MAX_TRANS (MAX_TRANS)
            ) mem_bhv (
                .seq (seq),
                .slv (debug_slv)
            );
        end

        for (genvar i = TO_LSDOM_S; i < TO_LSDOM_E; i++) begin
            assign addr_map[i] = '{
                start : '0,
                end_  : MMAP_BOUNDRY,
                inc   : '0
            };

            adam_axil_slv_simple_bhv #(
                `ADAM_BHV_CFG_PARAMS_MAP,

                .ADDR_S ('0),
                .ADDR_E (MMAP_BOUNDRY),
                .DATA   (DATA_T'(i)),

                .MAX_TRANS (MAX_TRANS)
            ) mem_bhv (
                .seq (seq),
                .slv (to_lsdom)
            );
        end
    endgenerate

    // DUT ====================================================================

    adam_fabric_hsdom #(
        `ADAM_CFG_PARAMS_MAP
    ) dut (
        .seq   (seq),
        .pause (pause),
        
        .cpu        (cpu),
        .dma        (dma),
        .debug_slv  (debug_mst),
        .from_lsdom (from_lsdom),

        .mem       (mem),
        .hsp       (hsp),
        .debug_mst (debug_slv),
        .to_lsdom  (to_lsdom)
    );
    
    // Test ===================================================================
      
    `TEST_SUITE begin
        `TEST_CASE("test") begin
            ADDR_T addr;
            DATA_T data_w;
            DATA_T data_r;
            RESP_T resp_b;
            RESP_T resp_r;

            `ADAM_UNTIL(!seq.rst);
            
            for (int i = 0; i < NO_MSTS; i++) begin
                for (int j = 0; j < NO_SLVS; j++) begin
                    for (int k = 0; k < 2; k++) begin
                        $display("i: %d; j: %d; k: %d", i, j, k);
                        addr = (k == 0) ? (addr_map[j].start) : (addr_map[j].end_ - 1);
                        data_w = DATA_T'(j);
                        fork
                            mst_bhv[i].send_aw(addr, 3'b000);
                            mst_bhv[i].send_w(data_w, 4'b1111);
                            mst_bhv[i].recv_b(resp_b);
                            mst_bhv[i].send_ar(addr, 3'b000);
                            mst_bhv[i].recv_r(data_r, resp_r);
                        join
                        assert (resp_b == axi_pkg::RESP_OKAY);
                        assert (resp_r == axi_pkg::RESP_OKAY);
                        assert (data_r == data_w);
                    end
                end
            end
        end
    end

    initial begin
        #1000us $error("timeout");
    end

    task cycle_start();
        #TT;
    endtask

    task cycle_end();
        @(posedge seq.clk);
    endtask

endmodule