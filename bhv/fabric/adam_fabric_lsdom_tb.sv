`timescale 1ns/1ps
`include "adam/macros_bhv.svh"
`include "axi/assign.svh"
`include "vunit_defines.svh"

module adam_fabric_lsdom_tb;
    import adam_axil_mst_bhv::*;
    import adam_axil_slv_bhv::*;

    `ADAM_BHV_CFG_LOCALPARAMS;

    localparam MAX_TRANS = FAB_MAX_TRANS;

    localparam NO_MSTS = 2*EN_LPCPU + 1;
    localparam NO_SLVS = EN_LPMEM + EN_LSPA + EN_LSPB + 2;

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

    // Masters ===============================================================

    `ADAM_AXIL_I lpcpu [2] ();
    `ADAM_AXIL_I from_hsdom ();

    `ADAM_AXIL_BHV_MST_ARRAY_FACTORY(MAX_TRANS, mst, NO_MSTS, seq.clk);

    generate
        localparam LPCPU_S = 0;
        localparam LPCPU_E = LPCPU_S + 2*EN_LPCPU;

        localparam FROM_HSDOM_S = LPCPU_E;
        localparam FROM_HSDOM_E = FROM_HSDOM_S + 1;

        for (genvar i = LPCPU_S; i < LPCPU_E; i++) begin
            `AXI_LITE_ASSIGN(lpcpu[i-LPCPU_S], mst[i]);
        end

        for (genvar i = FROM_HSDOM_S; i < FROM_HSDOM_E; i++) begin
            `AXI_LITE_ASSIGN(from_hsdom, mst[i]);
        end
    endgenerate

    // Slaves =================================================================

    `ADAM_AXIL_I lpmem ();
    `ADAM_AXIL_I syscfg ();
    `ADAM_AXIL_I lspa ();
    `ADAM_AXIL_I lspb ();
    `ADAM_AXIL_I to_hsdom ();

    MMAP_T addr_map [NO_SLVS+1];

    generate
        localparam LPMEM_S = 0;
        localparam LPMEM_E = LPMEM_S + EN_LPMEM;

        localparam SYSCFG_S = LPMEM_E;
        localparam SYSCFG_E = SYSCFG_S + 1;

        localparam LSPA_S = SYSCFG_E;
        localparam LSPA_E = LSPA_S + EN_LSPA;

        localparam LSPB_S = LSPA_E;
        localparam LSPB_E = LSPB_S + EN_LSPB;

        localparam TO_HSDOM_S = LSPB_E;
        localparam TO_HSDOM_E = TO_HSDOM_S + 1;

        for (genvar i = LPMEM_S; i < LPMEM_E; i++) begin
            assign addr_map[i] = '{
                start : MMAP_LPMEM.start,
                end_  : MMAP_LPMEM.end_,
                inc   : 0
            };

            adam_axil_slv_simple_bhv #(
                `ADAM_BHV_CFG_PARAMS_MAP,

                .ADDR_S ('0),
                .ADDR_E (MMAP_LPMEM.end_ - MMAP_LPMEM.start),
                .DATA   (i),

                .MAX_TRANS (MAX_TRANS)
            ) lpmem_bhv (
                .seq (seq),
                .slv (lpmem)
            );
        end

        for (genvar i = SYSCFG_S; i < SYSCFG_E; i++) begin
            assign addr_map[i] = '{
                start : MMAP_SYSCFG.start,
                end_  : MMAP_SYSCFG.end_,
                inc   : 0
            };

            adam_axil_slv_simple_bhv #(
                `ADAM_BHV_CFG_PARAMS_MAP,

                .ADDR_S ('0),
                .ADDR_E (MMAP_SYSCFG.end_ - MMAP_SYSCFG.start),
                .DATA   (i),

                .MAX_TRANS (MAX_TRANS)
            ) syscfg_bhv (
                .seq (seq),
                .slv (syscfg)
            );
        end

        for (genvar i = LSPA_S; i < LSPA_E; i++) begin
            assign addr_map[i] = '{
                start : MMAP_LSPA.start,
                end_  : MMAP_LSPA.end_,
                inc   : 0
            };

            adam_axil_slv_simple_bhv #(
                `ADAM_BHV_CFG_PARAMS_MAP,

                .ADDR_S ('0),
                .ADDR_E (MMAP_LSPA.end_ - MMAP_LSPA.start),
                .DATA   (i),

                .MAX_TRANS (MAX_TRANS)
            ) lspa_bhv (
                .seq (seq),
                .slv (lspa)
            );
        end

        for (genvar i = LSPB_S; i < LSPB_E; i++) begin
            assign addr_map[i] = '{
                start : MMAP_LSPB.start,
                end_  : MMAP_LSPB.end_,
                inc   : 0
            };

            adam_axil_slv_simple_bhv #(
                `ADAM_BHV_CFG_PARAMS_MAP,

                .ADDR_S ('0),
                .ADDR_E (MMAP_LSPB.end_ - MMAP_LSPB.start),
                .DATA   (i),

                .MAX_TRANS (MAX_TRANS)
            ) lspb_bhv (
                .seq (seq),
                .slv (lspb)
            );
        end

        for (genvar i = TO_HSDOM_S; i < TO_HSDOM_E; i++) begin
            assign addr_map[i] = '{
                start : MMAP_BOUNDRY,
                end_  : {ADDR_WIDTH{1'b1}},
                inc   : 0
            };

            adam_axil_slv_simple_bhv #(
                `ADAM_BHV_CFG_PARAMS_MAP,

                .ADDR_S (MMAP_BOUNDRY),
                .ADDR_E ({ADDR_WIDTH{1'b1}}),
                .DATA   (i),

                .MAX_TRANS (MAX_TRANS)
            ) lspb_bhv (
                .seq (seq),
                .slv (to_hsdom)
            );
        end
    endgenerate

    // DUT ====================================================================

    adam_fabric_lsdom #(
        `ADAM_CFG_PARAMS_MAP
    ) dut (
        .seq   (seq),
        .pause (pause),

        .lpcpu      (lpcpu),
        .from_hsdom (from_hsdom),

        .lpmem    (lpmem),
        .syscfg   (syscfg),
        .lspa     (lspa),
        .lspb     (lspb),
        .to_hsdom (to_hsdom)
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
