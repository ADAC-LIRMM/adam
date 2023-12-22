`timescale 1ns/1ps
`include "adam/macros_bhv.svh"
`include "axi/assign.svh"
`include "vunit_defines.svh"

`define APB_I APB #( \
    .ADDR_WIDTH (ADDR_WIDTH), \
    .DATA_WIDTH (DATA_WIDTH) \
)

`define AXIL_I AXI_LITE #( \
    .AXI_ADDR_WIDTH (ADDR_WIDTH), \
    .AXI_DATA_WIDTH (DATA_WIDTH) \
)

`define AXI_MST_FACTORY(mst, clk) \
    `AXIL_I mst (); \
    AXI_LITE_DV #( \
        .AXI_ADDR_WIDTH(ADDR_WIDTH), \
        .AXI_DATA_WIDTH(DATA_WIDTH) \
    ) ``mst``_dv (clk); \
    `AXI_LITE_ASSIGN(mst, ``mst``_dv); \
    adam_axil_mst_bhv #( \
        .ADDR_WIDTH (ADDR_WIDTH), \
        .DATA_WIDTH (DATA_WIDTH), \
        .TA (TA), \
        .TT (TT), \
        .MAX_TRANS (MAX_TRANS) \
    ) ``mst``_bhv; \
    initial begin \
        ``mst``_bhv = new(``mst``_dv); \
        ``mst``_bhv.loop(); \
    end

`define AXI_SLV_FACTORY(slv, value) \
    `AXIL_I slv (); \
    assign slv.aw_ready = 1'b1; \
    assign slv.w_ready  = 1'b1; \
    assign slv.b_resp   = 2'b00; \
    assign slv.b_valid  = 1'b1; \
    \
    assign slv.ar_ready = 1'b1; \
    assign slv.r_data   = value; \
    assign slv.r_resp   = 2'b00; \
    assign slv.r_valid  = 1'b1;

`define APB_SLV_FACTORY(slv, value) \
    `APB_I slv (); \
    assign slv.pready  = 1'b1; \
    assign slv.pslverr = 1'b0; \
    assign slv.prdata  = value;

`define TEST_PATH(mst, addr, value) begin \
    data_t data_w; \
    data_t data_r; \
    resp_t resp_b; \
    resp_t resp_d; \
    data_w = value; \
    fork \
        ``mst``_bhv.send_aw(addr, 3'b000); \
        ``mst``_bhv.send_w(data_w, 4'b1111); \
        ``mst``_bhv.recv_b(resp_b); \
        ``mst``_bhv.send_ar(addr, 3'b000); \
        ``mst``_bhv.recv_r(data_r, resp_d); \
    join \
    assert (resp_b == axi_pkg::RESP_OKAY); \
    assert (resp_d == axi_pkg::RESP_OKAY); \
    assert (data_r == value); \
end

module adam_fabric_tb;
    import adam_axil_mst_bhv::*;
    import adam_axil_slv_bhv::*;

    // Local parameters
    localparam ADDR_WIDTH = 32;
    localparam DATA_WIDTH = 32;

    localparam MAX_TRANS = 7;
    
    localparam NO_CPUS = 2;
    localparam NO_DMAS = 2;
    localparam NO_MEMS = 2;
    localparam NO_HSP = 2;
    localparam NO_LSPA = 2;
    localparam NO_LSPB = 2;
    
    localparam EN_LPCPU = 1;
    localparam EN_LPMEM = 1;
    localparam EN_LSPA  = 1;
    localparam EN_LSPB  = 1;
    localparam EN_DEBUG = 1;

    localparam CLK_PERIOD = 20ns;
    localparam RST_CYCLES = 5;
    
    localparam TA = 2ns;
    localparam TT = CLK_PERIOD - TA;
    
    localparam STRB_WIDTH = DATA_WIDTH/8;

    typedef logic [ADDR_WIDTH-1:0] addr_t;
    typedef logic [2:0]            prot_t;       
    typedef logic [DATA_WIDTH-1:0] data_t;
    typedef logic [STRB_WIDTH-1:0] strb_t;
    typedef logic [1:0]            resp_t;

    // lsdom seq / pause ======================================================

    ADAM_SEQ   lsdom_seq ();
    ADAM_PAUSE lsdom_pause ();
    ADAM_PAUSE lsdom_pause_lspa ();
    ADAM_PAUSE lsdom_pause_lspb ();

    adam_seq_bhv #(
        .CLK_PERIOD (CLK_PERIOD),
        .RST_CYCLES (RST_CYCLES),

        .TA (TA),
        .TT (TT)
    ) lsdom_adam_seq_bhv (
        .seq (lsdom_seq)
    );

    adam_pause_bhv #(
        .DELAY    (0.5us),
        .DURATION (0.5us),

        .TA (TA),
        .TT (TT)
    ) lsdom_adam_pause_bhv (
        .seq   (lsdom_seq),
        .pause (lsdom_pause)
    );

    adam_pause_bhv #(
        .DELAY    (1.5us),
        .DURATION (0.5us),

        .TA (TA),
        .TT (TT)
    ) lsdom_adam_pause_bhv_lspa (
        .seq   (lsdom_seq),
        .pause (lsdom_pause_lspa)
    );

    adam_pause_bhv #(
        .DELAY    (2.0us),
        .DURATION (0.5us),

        .TA (TA),
        .TT (TT)
    ) lsdom_adam_pause_bhv_lspb (
        .seq   (lsdom_seq),
        .pause (lsdom_pause_lspb)
    );

    // hsdom seq / pause ======================================================

    ADAM_SEQ   hsdom_seq ();
    ADAM_PAUSE hsdom_pause ();

    adam_seq_bhv #(
        .CLK_PERIOD (CLK_PERIOD),
        .RST_CYCLES (RST_CYCLES),

        .TA (TA),
        .TT (TT)
    ) hsdom_adam_seq_bhv (
        .seq (hsdom_seq)
    );

    adam_pause_bhv #(
        .DELAY    (2.5us),
        .DURATION (0.5us),

        .TA (TA),
        .TT (TT)
    ) hsdom_adam_pause_bhv (
        .seq   (hsdom_seq),
        .pause (hsdom_pause)
    );
        
    // lsdom masters ==========================================================

    `AXI_MST_FACTORY(lsdom_lpcpu0, lsdom_seq.clk);
    `AXI_MST_FACTORY(lsdom_lpcpu1, lsdom_seq.clk);
    
    // hsdom masters ==========================================================

    `AXI_MST_FACTORY(hsdom_cpus0, hsdom_seq.clk);
    `AXI_MST_FACTORY(hsdom_cpus1, hsdom_seq.clk);
    `AXI_MST_FACTORY(hsdom_cpus2, hsdom_seq.clk);
    `AXI_MST_FACTORY(hsdom_cpus3, hsdom_seq.clk);

    `AXI_MST_FACTORY(hsdom_dmas0, hsdom_seq.clk);
    `AXI_MST_FACTORY(hsdom_dmas1, hsdom_seq.clk);

    `AXI_MST_FACTORY(hsdom_debug_slv, hsdom_seq.clk);

    // lsdom slaves ===========================================================

    `AXI_SLV_FACTORY(lsdom_lpmem,  0);
    `AXI_SLV_FACTORY(lsdom_syscfg, 1);

    `APB_SLV_FACTORY(lsdom_lspa0,  2);
    `APB_SLV_FACTORY(lsdom_lspa1,  3);

    `APB_SLV_FACTORY(lsdom_lspb0,  4);
    `APB_SLV_FACTORY(lsdom_lspb1,  5);

    // hsdom slaves ===========================================================

    `AXI_SLV_FACTORY(hsdom_mems0, 6);
    `AXI_SLV_FACTORY(hsdom_mems1, 7);

    `AXI_SLV_FACTORY(hsdom_hsp0, 8);
    `AXI_SLV_FACTORY(hsdom_hsp1, 9);

    `AXI_SLV_FACTORY(hsdom_debug_mst, 10);

    // dut ====================================================================

    adam_fabric #(
        .ADDR_WIDTH (ADDR_WIDTH),
        .DATA_WIDTH (DATA_WIDTH),

        .MAX_TRANS (MAX_TRANS),
        
        .NO_CPUS (2),
        .NO_DMAS (2),
        .NO_MEMS (2),
        .NO_HSP (2),
        .NO_LSPA (2),
        .NO_LSPB (2),

        .EN_LPCPU (1),
        .EN_LPMEM (1),
        .EN_DEBUG (1)
    ) dut (
        .lsdom_seq        (lsdom_seq),
        .lsdom_pause      (lsdom_pause),
        .lsdom_pause_lspa (lsdom_pause_lspa),
        .lsdom_pause_lspb (lsdom_pause_lspb),
    
        .lsdom_lpcpu  ('{lsdom_lpcpu0, lsdom_lpcpu1}),

        .lsdom_lpmem  (lsdom_lpmem),
        .lsdom_syscfg (lsdom_syscfg),
        .lsdom_lspa   ('{lsdom_lspa0, lsdom_lspa1}),
        .lsdom_lspb   ('{lsdom_lspb0, lsdom_lspb1}),

        .hsdom_seq   (hsdom_seq),
        .hsdom_pause (hsdom_pause),

        .hsdom_cpus      ('{hsdom_cpus0, hsdom_cpus1, hsdom_cpus2, hsdom_cpus3}),
        .hsdom_dmas      ('{hsdom_dmas0, hsdom_dmas1}),
        .hsdom_debug_slv (hsdom_debug_slv),

        .hsdom_mems      ('{hsdom_mems0, hsdom_mems1}),
        .hsdom_hsp      ('{hsdom_hsp0, hsdom_hsp1}),
        .hsdom_debug_mst (hsdom_debug_mst)
    );

    // test suite =============================================================

    `TEST_SUITE begin
        `TEST_CASE("test") begin

            @(negedge hsdom_seq.rst);
            @(posedge hsdom_seq.clk);
                        
            `TEST_PATH(lsdom_lpcpu0, 32'h0008_0000, 10);
            `TEST_PATH(lsdom_lpcpu1, 32'h0200_0000,  7);
            
            #2us;

            `TEST_PATH(hsdom_cpus0, 32'h0000_0000, 0);
            `TEST_PATH(hsdom_cpus1, 32'h0000_8000, 1);
            `TEST_PATH(hsdom_cpus2, 32'h0001_0000, 2);
            `TEST_PATH(hsdom_cpus3, 32'h0001_0400, 3);

            `TEST_PATH(hsdom_dmas0, 32'h0001_8000, 4);
            `TEST_PATH(hsdom_dmas1, 32'h0001_8400, 5);

            `TEST_PATH(hsdom_debug_slv, 32'h0100_0000, 6);
        end
    end

    initial begin
        #1000us $error("timeout");
    end

endmodule
