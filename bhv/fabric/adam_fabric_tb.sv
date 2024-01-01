`timescale 1ns/1ps
`include "adam/macros_bhv.svh"
`include "axi/assign.svh"
`include "vunit_defines.svh"

`define AXIL_SLV_STATIC(slv, value) \
    assign slv.aw_ready = 1'b1; \
    assign slv.w_ready  = 1'b1; \
    assign slv.b_resp   = 2'b00; \
    assign slv.b_valid  = 1'b1; \
    \
    assign slv.ar_ready = 1'b1; \
    assign slv.r_data   = value; \
    assign slv.r_resp   = 2'b00; \
    assign slv.r_valid  = 1'b1;

`define APB_SLV_STATIC(slv, value) \
    assign slv.pready  = 1'b1; \
    assign slv.pslverr = 1'b0; \
    assign slv.prdata  = value;

module adam_fabric_tb;
    import adam_axil_mst_bhv::*;
    import adam_axil_slv_bhv::*;

    `ADAM_BHV_CFG_LOCALPARAMS;

    localparam MAX_TRANS = FAB_MAX_TRANS;

    localparam NO_MSTS = 2*EN_LPCPU + 2*NO_CPUS + NO_DMAS + EN_DEBUG;
    localparam NO_SLVS = EN_LPMEM + NO_LSPAS + NO_LSPBS +
        NO_MEMS + NO_HSPS + EN_DEBUG + 1;

    // lsdom seq and pause ====================================================

    ADAM_SEQ   lsdom_seq ();
    ADAM_PAUSE lsdom_pause ();
    ADAM_PAUSE lsdom_pause_lspa ();
    ADAM_PAUSE lsdom_pause_lspb ();

    adam_seq_bhv #(
        `ADAM_BHV_CFG_PARAMS_MAP
    ) lsdom_adam_seq_bhv (
        .seq (lsdom_seq)
    );

    adam_pause_bhv #(
        `ADAM_BHV_CFG_PARAMS_MAP,

        .DELAY    (0.5us),
        .DURATION (0.5us)
    ) lsdom_adam_pause_bhv (
        .seq   (lsdom_seq),
        .pause (lsdom_pause)
    );

    adam_pause_bhv #(
        `ADAM_BHV_CFG_PARAMS_MAP,

        .DELAY    (1.5us),
        .DURATION (0.5us)
    ) lsdom_adam_pause_bhv_lspa (
        .seq   (lsdom_seq),
        .pause (lsdom_pause_lspa)
    );

    adam_pause_bhv #(
        `ADAM_BHV_CFG_PARAMS_MAP,

        .DELAY    (2.0us),
        .DURATION (0.5us)
    ) lsdom_adam_pause_bhv_lspb (
        .seq   (lsdom_seq),
        .pause (lsdom_pause_lspb)
    );

    // hsdom seq and pause ====================================================

    ADAM_SEQ   hsdom_seq ();
    ADAM_PAUSE hsdom_pause ();

    adam_seq_bhv #(
        `ADAM_CFG_PARAMS_MAP
    ) hsdom_adam_seq_bhv (
        .seq (hsdom_seq)
    );

    adam_pause_bhv #(
        `ADAM_BHV_CFG_PARAMS_MAP,

        .DELAY    (2.5us),
        .DURATION (0.5us)
    ) hsdom_adam_pause_bhv (
        .seq   (hsdom_seq),
        .pause (hsdom_pause)
    );
        
    // Masters ================================================================

    `ADAM_AXIL_I lsdom_lpcpu [2] ();

    `ADAM_AXIL_I hsdom_cpu [2*NO_CPUS+1] ();
    `ADAM_AXIL_I hsdom_dma [NO_DMAS+1] ();
    `ADAM_AXIL_I hsdom_debug_mst ();
    
    `ADAM_AXIL_BHV_MST_ARRAY_FACTORY(MAX_TRANS, mst, NO_MSTS, hsdom_seq.clk);

    generate
        localparam LSDOM_LPCPU_S = 0;
        localparam LSDOM_LPCPU_E = LSDOM_LPCPU_S + EN_LPCPU;

        localparam HSDOM_CPU_S = LSDOM_LPCPU_E;
        localparam HSDOM_CPU_E = HSDOM_CPU_S + 2*NO_CPUS;

        localparam HSDOM_DMA_S = HSDOM_CPU_E;
        localparam HSDOM_DMA_E = HSDOM_DMA_S + NO_DMAS;

        localparam HSDOM_DEBUG_MST_S = HSDOM_DMA_E;
        localparam HSDOM_DEBUG_MST_E = HSDOM_DEBUG_MST_S + EN_DEBUG;

        for (genvar i = LSDOM_LPCPU_S; i < LSDOM_LPCPU_E; i++) begin
            `AXI_LITE_ASSIGN(lsdom_lpcpu[i-LSDOM_LPCPU_S], mst[i]);
        end

        for (genvar i = HSDOM_CPU_S; i < HSDOM_CPU_E; i++) begin
            `AXI_LITE_ASSIGN(hsdom_cpu[i-HSDOM_CPU_S], mst[i]);
        end

        for (genvar i = HSDOM_DMA_S; i < HSDOM_DMA_E; i++) begin
            `AXI_LITE_ASSIGN(hsdom_dma[i-HSDOM_DMA_S], mst[i]);
        end

        for (genvar i = HSDOM_DEBUG_MST_S; i < HSDOM_DEBUG_MST_E; i++) begin
            `AXI_LITE_ASSIGN(hsdom_debug_mst, mst[i]);
        end
    endgenerate

    // Slaves =================================================================

    `ADAM_AXIL_I lsdom_lpmem ();
    `ADAM_AXIL_I lsdom_syscfg ();

    `ADAM_APB_I  lsdom_lspa [NO_LSPAS+1] ();
    `ADAM_APB_I  lsdom_lspb [NO_LSPBS+1] ();
    
    `ADAM_AXIL_I hsdom_mem [NO_MEMS+1] ();
    `ADAM_AXIL_I hsdom_hsp [NO_HSPS+1] ();
    `ADAM_AXIL_I hsdom_debug_slv ();

    ADDR_T test_addr [NO_SLVS+1];
    
    generate
        localparam LSDOM_LPMEM_S = 0;
        localparam LSDOM_LPMEM_E = LSDOM_LPMEM_S + EN_LPMEM;

        localparam LSDOM_SYSCFG_S = LSDOM_LPMEM_E;
        localparam LSDOM_SYSCFG_E = LSDOM_SYSCFG_S + 1;

        localparam LSDOM_LSPA_S = LSDOM_SYSCFG_E;
        localparam LSDOM_LSPA_E = LSDOM_LSPA_S + NO_LSPAS;

        localparam LSDOM_LSPB_S = LSDOM_LSPA_E;
        localparam LSDOM_LSPB_E = LSDOM_LSPB_S + NO_LSPBS;

        localparam HSDOM_MEM_S = LSDOM_LSPB_E;
        localparam HSDOM_MEM_E = HSDOM_MEM_S + NO_MEMS;

        localparam HSDOM_HSP_S = HSDOM_MEM_E;
        localparam HSDOM_HSP_E = HSDOM_HSP_S + NO_HSPS;

        localparam HSDOM_DEBUG_SLV_S = HSDOM_HSP_E;
        localparam HSDOM_DEBUG_SLV_E = HSDOM_DEBUG_SLV_S + EN_DEBUG;

        for (genvar i = LSDOM_LPMEM_S; i < LSDOM_LPMEM_E; i++) begin
            assign test_addr[i] = MMAP_LPMEM.start;
            
            `AXIL_SLV_STATIC(lsdom_lpmem, test_addr[i]);
        end

        for (genvar i = LSDOM_SYSCFG_S; i < LSDOM_SYSCFG_E; i++) begin
            assign test_addr[i] = MMAP_SYSCFG.start;
            
            `AXIL_SLV_STATIC(lsdom_syscfg, test_addr[i]);
        end

        for (genvar i = LSDOM_LSPA_S; i < LSDOM_LSPA_E; i++) begin
            assign test_addr[i] = MMAP_LSPA.start +
                MMAP_LSPA.inc*(i-LSDOM_LSPA_S);
            
            `APB_SLV_STATIC(lsdom_lspa[i-LSDOM_LSPA_S], test_addr[i]);
        end

        for (genvar i = LSDOM_LSPB_S; i < LSDOM_LSPB_E; i++) begin
            assign test_addr[i] = MMAP_LSPB.start +
                MMAP_LSPB.inc*(i-LSDOM_LSPB_S);
            
            `APB_SLV_STATIC(lsdom_lspb[i-LSDOM_LSPB_S], test_addr[i]);
        end

        for (genvar i = HSDOM_MEM_S; i < HSDOM_MEM_E; i++) begin
            assign test_addr[i] = MMAP_MEM.start +
                MMAP_MEM.inc*(i-HSDOM_MEM_S);
            
            `AXIL_SLV_STATIC(hsdom_mem[i-HSDOM_MEM_S], test_addr[i]);
        end

        for (genvar i = HSDOM_HSP_S; i < HSDOM_HSP_E; i++) begin
            assign test_addr[i] = MMAP_HSP.start +
                MMAP_HSP.inc*(i-HSDOM_HSP_S);
            
            `AXIL_SLV_STATIC(hsdom_hsp[i-HSDOM_HSP_S], test_addr[i]);
        end

        for (genvar i = HSDOM_DEBUG_SLV_S; i < HSDOM_DEBUG_SLV_E; i++) begin
            assign test_addr[i] = MMAP_DEBUG.start;
            `AXIL_SLV_STATIC(hsdom_debug_slv, test_addr[i]);
        end
    endgenerate

    // DUT ====================================================================

    adam_fabric #(
        `ADAM_CFG_PARAMS_MAP
    ) dut (
        .lsdom_seq        (lsdom_seq),
        .lsdom_pause      (lsdom_pause),
        .lsdom_pause_lspa (lsdom_pause_lspa),
        .lsdom_pause_lspb (lsdom_pause_lspb),
    
        .lsdom_lpcpu  (lsdom_lpcpu),

        .lsdom_lpmem  (lsdom_lpmem),
        .lsdom_syscfg (lsdom_syscfg),
        .lsdom_lspa   (lsdom_lspa),
        .lsdom_lspb   (lsdom_lspb),

        .hsdom_seq   (hsdom_seq),
        .hsdom_pause (hsdom_pause),

        .hsdom_cpu       (hsdom_cpu),
        .hsdom_dma       (hsdom_dma),
        .hsdom_debug_slv (hsdom_debug_mst),

        .hsdom_mem       (hsdom_mem),
        .hsdom_hsp       (hsdom_hsp),
        .hsdom_debug_mst (hsdom_debug_slv)
    );

    // Test ===================================================================

    `TEST_SUITE begin
        `TEST_CASE("test") begin
            ADDR_T addr;
            DATA_T data_w;
            DATA_T data_r;
            RESP_T resp_b;
            RESP_T resp_r;

            `ADAM_UNTIL(!hsdom_seq.rst);
            
            for (int i = 0; i < NO_MSTS; i++) begin
                for (int j = 0; j < NO_SLVS; j++) begin
                    $display("i: %d; j: %d", i, j);
                    addr = test_addr[j];
                    data_w = DATA_T'(addr);
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

    initial begin
        #1000us $error("timeout");
    end

    task cycle_start();
        #TT;
    endtask

    task cycle_end();
        @(posedge hsdom_seq.clk);
    endtask

endmodule
