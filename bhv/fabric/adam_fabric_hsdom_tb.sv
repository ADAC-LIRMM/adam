`timescale 1ns/1ps
`include "adam/macros_bhv.svh"
`include "axi/assign.svh"
`include "vunit_defines.svh"

`define MST_FACTORY(MST) \
    `ADAM_AXIL_I MST (); \
    AXI_LITE_DV #( \
        .AXI_ADDR_WIDTH(ADDR_WIDTH), \
        .AXI_DATA_WIDTH(DATA_WIDTH) \
    ) ``MST``_dv (seq.clk); \
    `AXI_LITE_ASSIGN(MST, ``MST``_dv); \
    adam_axil_mst_bhv #( \
        .ADDR_WIDTH (ADDR_WIDTH), \
        .DATA_WIDTH (DATA_WIDTH), \
        .TA (TA), \
        .TT (TT), \
        .MAX_TRANS (MAX_TRANS) \
    ) ``MST``_bhv; \
    initial begin \
        ``MST``_bhv = new(``MST``_dv); \
        ``MST``_bhv.loop(); \
    end

`define MST_TEST(MST) begin \
    ADDR_T addr; \
    DATA_T data_w; \
    DATA_T data_r; \
    RESP_T resp_b; \
    RESP_T resp_d; \
    for (int i = 0; i < 6; i++) begin \
        for (int j = 0; j < 2; j++) begin \
            if (j == 0) begin \
                addr = map[i].start_addr; \
            end \
            else begin \
                addr = map[i].end_addr - 1; \
            end \
            data_w = DATA_T'(i); \
            fork \
                ``MST``_bhv.send_aw(addr, 3'b000); \
                ``MST``_bhv.send_w(data_w, 4'b1111); \
                ``MST``_bhv.recv_b(resp_b); \
                ``MST``_bhv.send_ar(addr, 3'b000); \
                ``MST``_bhv.recv_r(data_r, resp_d); \
            join \
            assert (resp_b == axi_pkg::RESP_OKAY); \
            assert (resp_d == axi_pkg::RESP_OKAY); \
            assert (data_r == data_w); \
        end \
    end \
end

`define SLV_FACTORY(SLV, ID, _ADDR_S, _ADDR_E) \
    `ADAM_AXIL_I SLV (); \
    adam_axil_slv_simple_bhv #( \
        .ADDR_WIDTH (ADDR_WIDTH), \
        .DATA_WIDTH (DATA_WIDTH), \
        .ADDR_S (_ADDR_S), \
        .ADDR_E (_ADDR_E), \
        .DATA (ID), \
        .TA (TA), \
        .TT (TT), \
        .MAX_TRANS (MAX_TRANS) \
    ) ``SLV``_bhv ( \
        .seq (seq), \
        .slv (SLV) \
    );

module adam_fabric_hsdom_tb;
    import adam_axil_mst_bhv::*;
    import adam_axil_slv_bhv::*;

    `ADAM_BHV_CFG_LOCALPARAMS;

    localparam MAX_TRANS = 7;

    typedef struct packed {
        ADDR_T start_addr;
        ADDR_T end_addr;
    } rule_t;

    ADAM_SEQ   seq   ();
    ADAM_PAUSE pause ();
    
    rule_t [5:0] map;
    assign map = '{
        '{32'h0000_0000, 32'h0008_0000},
        '{32'h0008_0000, 32'h0008_4000},
        '{32'h0009_0400, 32'h0009_0800},
        '{32'h0009_0000, 32'h0009_0400},
        '{32'h0200_0400, 32'h0200_0800},
        '{32'h0100_0000, 32'h0200_0000}
    };

    `MST_FACTORY(cpu0);
    `MST_FACTORY(cpu1);
    `MST_FACTORY(cpu2);
    `MST_FACTORY(cpu3);
    `MST_FACTORY(dma0);
    `MST_FACTORY(dma1);
    `MST_FACTORY(debug_slv);
    `MST_FACTORY(from_lsdom);
    
    `SLV_FACTORY(mem0     , 0, 32'h0000_0000, 32'h0100_0000);
    `SLV_FACTORY(mem1     , 1, 32'h0000_0000, 32'h0100_0000);
    `SLV_FACTORY(hsp0     , 2, 32'h0000_0000, 32'h0000_0400);
    `SLV_FACTORY(hsp1     , 3, 32'h0000_0000, 32'h0000_0400);
    `SLV_FACTORY(debug_mst, 4, 32'h0000_0000, 32'h0000_4000);
    `SLV_FACTORY(to_lsdom , 5, 32'h0000_0000, 32'h0008_0000);

    adam_fabric_hsdom #(
        .ADDR_WIDTH (ADDR_WIDTH),
        .DATA_WIDTH (DATA_WIDTH),
        
        .NO_CPUS (2),
        .NO_DMAS (2),
        .NO_MEMS (2),
        .NO_HSPS (2),

        .EN_DEBUG (1)
    ) dut (
        .seq   (seq),
        .pause (pause),
        
        .cpus ('{cpu0, cpu1, cpu2, cpu3}),
        .dmas ('{dma0, dma1}),
        .debug_slv (debug_slv),
        .from_lsdom (from_lsdom),

        .mems ('{mem0, mem1}),
        .hsp ('{hsp0, hsp1}),
        .debug_mst (debug_mst),
        .to_lsdom (to_lsdom)
    );

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

    `TEST_SUITE begin
        `TEST_CASE("test") begin
            @(negedge seq.rst);
            @(posedge seq.clk);
            
            `MST_TEST(cpu0);
            `MST_TEST(cpu1);
            `MST_TEST(cpu2);
            `MST_TEST(cpu3);
            `MST_TEST(dma0);
            `MST_TEST(dma1);
            `MST_TEST(debug_slv);
            `MST_TEST(from_lsdom);
        end
    end

    initial begin
        #1000us $error("timeout");
    end

endmodule