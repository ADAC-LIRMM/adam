`include "axi/assign.svh"
`include "vunit_defines.svh"

`define AXIL_I AXI_LITE #( \
    .AXI_ADDR_WIDTH (ADDR_WIDTH), \
    .AXI_DATA_WIDTH (DATA_WIDTH) \
)

`define MST_FACTORY(MST) \
    `AXIL_I MST (); \
    AXI_LITE_DV #( \
        .AXI_ADDR_WIDTH(ADDR_WIDTH), \
        .AXI_DATA_WIDTH(DATA_WIDTH) \
    ) ``MST``_dv (seq.clk); \
    `AXI_LITE_ASSIGN(MST, ``MST``_dv); \
    adam_axil_master_bhv #( \
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
    addr_t addr; \
    data_t data_w; \
    data_t data_r; \
    resp_t resp_b; \
    resp_t resp_d; \
    for (int i = 0; i < 5; i++) begin \
        for (int j = 0; j < 2; j++) begin \
            if (j == 0) begin \
                addr = map[i].start_addr; \
            end \
            else begin \
                addr = map[i].end_addr - 1; \
            end \
            data_w = map[i].idx; \
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
    `AXIL_I SLV (); \
    adam_axil_slave_simple_bhv #( \
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

module adam_fabric_lsdom_tb;
    import adam_axil_master_bhv::*;
    import adam_axil_slave_bhv::*;

    localparam ADDR_WIDTH = 32;
    localparam DATA_WIDTH = 32;

    localparam MAX_TRANS = 7;

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

    typedef struct packed {
        int unsigned idx;
        addr_t start_addr;
        addr_t end_addr;
    } rule_t;

    ADAM_SEQ   seq   ();
    ADAM_PAUSE pause ();
        
    rule_t [4:0] map;
    assign map = '{
        '{ idx: 4, start_addr: 32'h0008_0000, end_addr: 32'hFFFF_FFFF},
        '{ idx: 3, start_addr: 32'h0001_8000, end_addr: 32'h0002_0000},
        '{ idx: 2, start_addr: 32'h0001_0000, end_addr: 32'h0001_8000},
        '{ idx: 1, start_addr: 32'h0000_8000, end_addr: 32'h0000_8400},
        '{ idx: 0, start_addr: 32'h0000_0000, end_addr: 32'h0000_8000} 
    };

    `MST_FACTORY(lpu0);
    `MST_FACTORY(lpu1);
    `MST_FACTORY(from_hsdom);
    
    `SLV_FACTORY(mem     , 0, 32'h0000_0000, 32'h0000_8000);
    `SLV_FACTORY(syscfg  , 1, 32'h0000_0000, 32'h0000_0400);
    `SLV_FACTORY(lsbp    , 2, 32'h0000_0000, 32'h0001_8000);
    `SLV_FACTORY(lsip    , 3, 32'h0000_0000, 32'h0000_8000);
    `SLV_FACTORY(to_hsdom, 4, 32'h0008_0000, 32'hFFFF_FFFF);

    adam_fabric_lsdom #(
        .ADDR_WIDTH (ADDR_WIDTH),
        .DATA_WIDTH (DATA_WIDTH),
        
        .MAX_TRANS (MAX_TRANS),

        .EN_LPU  (1),
        .EN_MEM  (1),
        .EN_LSBP (1),
        .EN_LSIP (1)
    ) dut (
        .seq   (seq),
        .pause (pause),
        
        .lpu ('{lpu0, lpu1}),
        .from_hsdom (from_hsdom),

        .mem (mem),
        .syscfg (syscfg),
        .lsbp (lsbp),
        .lsip (lsip),
        .to_hsdom (to_hsdom)
    );

    adam_clk_rst_bhv #(
        .CLK_PERIOD (CLK_PERIOD),
        .RST_CYCLES (RST_CYCLES),

        .TA (TA),
        .TT (TT)
    ) adam_clk_rst_bhv (
        .seq (seq)
    );

    adam_pause_bhv #(
        .DELAY    (10us),
        .DURATION (10us),

        .TA (TA),
        .TT (TT)
    ) adam_pause_bhv (
        .seq   (seq),
        .pause (pause)
    );
    
    `TEST_SUITE begin
        `TEST_CASE("test") begin
            @(negedge seq.rst);
            @(posedge seq.clk);
            
            `MST_TEST(lpu0);
            `MST_TEST(lpu1);
            `MST_TEST(from_hsdom);
        end
    end
endmodule
