`timescale 1ns/1ps
`include "adam/macros.svh"
`include "axi/assign.svh"
`include "vunit_defines.svh"

module adam_periph_syscfg_tb;
    `ADAM_BHV_CFG_LOCALPARAMS;

    ADAM_SEQ   seq   ();
    ADAM_PAUSE pause ();

    `ADAM_AXI_LITE_BHV_MST_FACTORY(axi, seq.clk);

    DATA_T irq_vec;
    logic  irq;

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
    
    logic      fab_hsbp_rst;
    ADAM_PAUSE fab_hsbp_pause ();
    
    logic      fab_hsp_rst;
    ADAM_PAUSE fab_hsp_pause ();

    logic      lpcpu_rst;
    ADAM_PAUSE lpcpu_pause ();
    ADDR_T     lpcpu_boot_addr;
    logic      lpcpu_irq;

    logic      lpmem_rst;
    ADAM_PAUSE lpmem_pause ();

    logic      cpu_rst       [NO_CPUS+1];
    ADAM_PAUSE cpu_pause     [NO_CPUS+1];
    ADDR_T     cpu_boot_addr [NO_CPUS+1];
    logic      cpu_irq       [NO_CPUS+1];

    logic      dma_rst       [NO_DMAS+1];
    ADAM_PAUSE dma_pause     [NO_DMAS+1];
    logic      dma_irq       [NO_DMAS+1];

    logic      mem_rst   [NO_MEMS+1];
    ADAM_PAUSE mem_pause [NO_MEMS+1];

    logic      lspa_rst   [NO_LSPAS+1];
    ADAM_PAUSE lspa_pause [NO_LSPAS+1];
    logic      lspa_irq   [NO_LSPAS+1];

    logic      lspb_rst   [NO_LSPBS+1];
    ADAM_PAUSE lspb_pause [NO_LSPBS+1];
    logic      lspb_irq   [NO_LSPBS+1];

    adam_periph_syscfg #(
        `ADAM_CFG_PARAMS_MAP
    ) dut (
        .seq   (seq),
        .pause (pause),

        .slv (axi),

        .irq_vec (irq_vec),
        .irq     (irq),

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
        
        .fab_hsbp_rst   (fab_hsbp_rst),
        .fab_hsbp_pause (fab_hsbp_pause),
        
        .fab_hsp_rst   (fab_hsp_rst),
        .fab_hsp_pause (fab_hsp_pause),

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
        .lspb_irq   (lspb_irq)
    ); 

    // Connect req and ack for pause directly
    always_comb begin
        pause.ack = pause.req;
    end

    `TEST_SUITE begin
        `TEST_CASE("Reset Routing Test") begin
            // Reset test for lsdom
            reset_domain(lsdom_rst);
            assert (!lsdom_rst);

            // ... (similar tests for other domains)

            repeat (10) @(posedge seq.clk);
        end
    end

    // Helper task for resetting a domain
    task reset_domain(output logic rst_line);
        begin
            // Issue reset command via AXI interface
            // Check reset line state
            // Note: Implement AXI write transaction to trigger reset
            // Example: axi.write(addr, data, strb, resp);
        end
    endtask

    initial begin
        #1000us $finish;
    end
endmodule
