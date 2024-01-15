`timescale 1ns/1ps
`include "adam/macros_bhv.svh"
`include "axi/assign.svh"
`include "vunit_defines.svh"

module adam_syscfg_tb;
    import adam_axil_mst_bhv::*;

    `ADAM_BHV_CFG_LOCALPARAMS;

    parameter MAX_TRANS = 7;

    localparam NO_TGTS = 4 + EN_LSPA + EN_LSPB + EN_HSP + EN_LPCPU + EN_LPMEM +
        NO_CPUS + NO_DMAS + NO_MEMS + NO_LSPAS + NO_LSPBS;

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

    // master =================================================================
    
    `ADAM_AXIL_BHV_MST_FACTORY(MAX_TRANS, mst, seq.clk);

    // dut ====================================================================

    logic      lsdom_rst;
    ADAM_PAUSE lsdom_pause ();

    logic      hsdom_rst;
    ADAM_PAUSE hsdom_pause ();
    
    logic      fab_lsdom_rst;
    ADAM_PAUSE fab_lsdom_pause ();
    
    logic      fab_hsdom_rst;
    ADAM_PAUSE fab_hsdom_pause ();
    
    logic      fab_lspa_rst;
    ADAM_PAUSE fab_lspa_pause ();
    
    logic      fab_lspb_rst;
    ADAM_PAUSE fab_lspb_pause ();
    
    logic      lpcpu_rst;
    ADAM_PAUSE lpcpu_pause ();
    ADDR_T     lpcpu_boot_addr;
    logic      lpcpu_irq;

    logic      lpmem_rst;
    ADAM_PAUSE lpmem_pause ();

    logic      cpu_rst       [NO_CPUS+1];
    ADAM_PAUSE cpu_pause     [NO_CPUS+1] ();
    ADDR_T     cpu_boot_addr [NO_CPUS+1];
    logic      cpu_irq       [NO_CPUS+1];

    logic      dma_rst       [NO_DMAS+1];
    ADAM_PAUSE dma_pause     [NO_DMAS+1] ();
    logic      dma_irq       [NO_DMAS+1];

    logic      mem_rst   [NO_MEMS+1];
    ADAM_PAUSE mem_pause [NO_MEMS+1] ();

    logic      lspa_rst   [NO_LSPAS+1];
    ADAM_PAUSE lspa_pause [NO_LSPAS+1] ();
    logic      lspa_irq   [NO_LSPAS+1];

    logic      lspb_rst   [NO_LSPBS+1];
    ADAM_PAUSE lspb_pause [NO_LSPBS+1] ();
    logic      lspb_irq   [NO_LSPBS+1];

    logic      hsp_rst   [NO_HSPS+1];
    ADAM_PAUSE hsp_pause [NO_HSPS+1] ();
    logic      hsp_irq   [NO_HSPS+1];

    adam_syscfg #(
        `ADAM_CFG_PARAMS_MAP
    ) dut (
        .seq   (seq),
        .pause (pause),

        .slv (mst),

        .lsdom_rst   (lsdom_rst),
        .lsdom_pause (lsdom_pause),

        .hsdom_rst   (hsdom_rst),
        .hsdom_pause (hsdom_pause),
        
        .fab_lsdom_rst   (fab_lsdom_rst),
        .fab_lsdom_pause (fab_lsdom_pause),
        
        .fab_hsdom_rst   (fab_hsdom_rst),
        .fab_hsdom_pause (fab_hsdom_pause),
        
        .fab_lspa_rst   (fab_lspa_rst),
        .fab_lspa_pause (fab_lspa_pause),
        
        .fab_lspb_rst   (fab_lspb_rst),
        .fab_lspb_pause (fab_lspb_pause),

        .lpcpu_rst       (lpcpu_rst),
        .lpcpu_pause     (lpcpu_pause),
        .lpcpu_boot_addr (lpcpu_boot_addr),
        .lpcpu_irq       (lpcpu_irq),

        .lpmem_rst   (lpmem_rst),
        .lpmem_pause (lpmem_pause),

        .cpu_rst       (cpu_rst),
        .cpu_pause     (cpu_pause),
        .cpu_boot_addr (cpu_boot_addr),
        .cpu_irq       (cpu_irq),

        .dma_rst   (dma_rst),
        .dma_pause (dma_pause),
        .dma_irq   (dma_irq),

        .mem_rst   (mem_rst),
        .mem_pause (mem_pause),

        .lspa_rst   (lspa_rst),
        .lspa_pause (lspa_pause),
        .lspa_irq   (lspa_irq),

        .lspb_rst   (lspb_rst),
        .lspb_pause (lspb_pause),
        .lspb_irq   (lspb_irq),

        .hsp_rst   (hsp_rst),
        .hsp_pause (hsp_pause),
        .hsp_irq   (hsp_irq)
    ); 

    // tgt pause ==============================================================

    generate
        assign lsdom_pause.ack = lsdom_pause.req;
        assign hsdom_pause.ack = hsdom_pause.req;
        assign fab_lsdom_pause.ack = fab_lsdom_pause.req;
        assign fab_hsdom_pause.ack = fab_hsdom_pause.req;
        assign fab_lspa_pause.ack = fab_lspa_pause.req;
        assign fab_lspb_pause.ack = fab_lspb_pause.req;
        assign lpcpu_pause.ack = lpcpu_pause.req;
        assign lpmem_pause.ack = lpmem_pause.req;
        for (genvar i = 0; i < NO_CPUS; i++) begin
            assign cpu_pause[i].ack = cpu_pause[i].req;
        end
        for (genvar i = 0; i < NO_DMAS; i++) begin
            assign dma_pause[i].ack = dma_pause[i].req;
        end
        for (genvar i = 0; i < NO_MEMS; i++) begin
            assign mem_pause[i].ack = mem_pause[i].req;
        end
        for (genvar i = 0; i < NO_LSPAS; i++) begin
            assign lspa_pause[i].ack = lspa_pause[i].req;
        end
        for (genvar i = 0; i < NO_LSPBS; i++) begin
            assign lspb_pause[i].ack = lspb_pause[i].req;
        end
        for (genvar i = 0; i < NO_HSPS; i++) begin
            assign hsp_pause[i].ack = hsp_pause[i].req;
        end
    endgenerate

    // tgt rst mapping ========================================================

    logic tgt_rst [NO_TGTS+1];

    generate
        localparam LSDOM_S = 0;
        localparam LSDOM_E = LSDOM_S + 1;

        localparam HSDOM_S = LSDOM_E;
        localparam HSDOM_E = HSDOM_S + 1;

        localparam FAB_LSDOM_S = HSDOM_E;
        localparam FAB_LSDOM_E = FAB_LSDOM_S + 1;

        localparam FAB_HSDOM_S = FAB_LSDOM_E;
        localparam FAB_HSDOM_E = FAB_HSDOM_S + 1;

        localparam FAB_LSPA_S = FAB_HSDOM_E;
        localparam FAB_LSPA_E = FAB_LSPA_S + EN_LSPA;

        localparam FAB_LSPB_S = FAB_LSPA_E;
        localparam FAB_LSPB_E = FAB_LSPB_S + EN_LSPB;

        localparam LPCPU_S = FAB_LSPB_E;
        localparam LPCPU_E = LPCPU_S + EN_LPCPU;

        localparam LPMEM_S = LPCPU_E;
        localparam LPMEM_E = LPMEM_S + EN_LPMEM;

        localparam CPU_S = LPMEM_E;
        localparam CPU_E = CPU_S + NO_CPUS;

        localparam DMA_S = CPU_E;
        localparam DMA_E = DMA_S + NO_DMAS;

        localparam MEM_S = DMA_E;
        localparam MEM_E = MEM_S + NO_MEMS;

        localparam LSPA_S = MEM_E;
        localparam LSPA_E = LSPA_S + NO_LSPAS;

        localparam LSPB_S = LSPA_E;
        localparam LSPB_E = LSPB_S + NO_LSPBS;

        localparam HSP_S = LSPB_E;
        localparam HSP_E = HSP_S + NO_HSPS;


        for (genvar i = LSDOM_S; i < LSDOM_E; i++) begin
            assign tgt_rst[i] = lsdom_rst;
        end

        for (genvar i = HSDOM_S; i < HSDOM_E; i++) begin
            assign tgt_rst[i] = hsdom_rst;
        end

        for (genvar i = FAB_LSDOM_S; i < FAB_LSDOM_E; i++) begin
            assign tgt_rst[i] = fab_lsdom_rst;
        end

        for (genvar i = FAB_HSDOM_S; i < FAB_HSDOM_E; i++) begin
            assign tgt_rst[i] = fab_hsdom_rst;
        end

        for (genvar i = FAB_LSPA_S; i < FAB_LSPA_E; i++) begin
            assign tgt_rst[i] = fab_lspa_rst;
        end

        for (genvar i = FAB_LSPB_S; i < FAB_LSPB_E; i++) begin
            assign tgt_rst[i] = fab_lspb_rst;
        end

        for (genvar i = LPCPU_S; i < LPCPU_E; i++) begin
            assign tgt_rst[i] = lpcpu_rst;
        end

        for (genvar i = LPMEM_S; i < LPMEM_E; i++) begin
            assign tgt_rst[i] = lpmem_rst;
        end

        for (genvar i = CPU_S; i < CPU_E; i++) begin
            assign tgt_rst[i] = cpu_rst[i-CPU_S];
        end

        for (genvar i = DMA_S; i < DMA_E; i++) begin
            assign tgt_rst[i] = dma_rst[i-DMA_S];
        end

        for (genvar i = MEM_S; i < MEM_E; i++) begin
            assign tgt_rst[i] = mem_rst[i-MEM_S];
        end

        for (genvar i = LSPA_S; i < LSPA_E; i++) begin
            assign tgt_rst[i] = lspa_rst[i-LSPA_S];
        end

        for (genvar i = LSPB_S; i < LSPB_E; i++) begin
            assign tgt_rst[i] = lspb_rst[i-LSPB_S];
        end
    
        for (genvar i = HSP_S; i < HSP_E; i++) begin
            assign tgt_rst[i] = hsp_rst[i-HSP_S];
        end
    endgenerate

    // test ===================================================================

    `TEST_SUITE begin
        `TEST_CASE("test") begin

            `ADAM_UNTIL(!seq.rst);
            
            for (int i = 0; i < NO_TGTS; i++) begin
                $display("tgt %d", i);

                tgt_maestro(i, 3); // STOP
                assert (tgt_rst[i]);

                tgt_maestro(i, 1); // RESUME
                assert (!tgt_rst[i]);
            end
        end
    end

    task tgt_maestro(
        input int i,
        input int action
    );
        ADDR_T addr;
        DATA_T data;
        RESP_T resp;

        addr = ADDR_T'(STRB_WIDTH * (4*i + 1)); // MR Register

        do begin
            mst_bhv.send_ar(addr, 3'b000);
            mst_bhv.recv_r(data, resp);
            assert (resp == axi_pkg::RESP_OKAY);
        end
        while (data != '0);

        mst_bhv.send_aw(addr, 3'b000);
        mst_bhv.send_w(action, 4'b1111);
        mst_bhv.recv_b(resp);
        assert (resp == axi_pkg::RESP_OKAY);

        do begin
            mst_bhv.send_ar(addr, 3'b111);
            mst_bhv.recv_r(data, resp);
            assert (resp == axi_pkg::RESP_OKAY);
        end
        while (data != '0);
    endtask

    initial begin
        #1000us $finish;
    end

    task cycle_start();
        #TT;
    endtask

    task cycle_end();
        @(posedge seq.clk);
    endtask

endmodule
