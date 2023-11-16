`include "axi/assign.svh"
`include "vunit_defines.svh"

// `define AXIL_I AXI_LITE #( \
//     .AXI_ADDR_WIDTH (ADDR_WIDTH), \
//     .AXI_DATA_WIDTH (DATA_WIDTH) \
// )

// `define AXIL_DV_I AXI_LITE_DV #( \
//     .AXI_ADDR_WIDTH(ADDR_WIDTH), \
//     .AXI_DATA_WIDTH(DATA_WIDTH) \
// )

`define MST_FACTORY(MST, LEN) \
    AXI_LITE #( \
        .AXI_ADDR_WIDTH (ADDR_WIDTH), \
        .AXI_DATA_WIDTH (DATA_WIDTH) \
    ) MST [LEN] (); \
    AXI_LITE_DV #( \
        .AXI_ADDR_WIDTH(ADDR_WIDTH), \
        .AXI_DATA_WIDTH(DATA_WIDTH) \
    ) ``MST``_dv [LEN] (clk); \
    adam_axil_master_bhv #( \
        .ADDR_WIDTH (ADDR_WIDTH), \
        .DATA_WIDTH (DATA_WIDTH), \
        .TA (TA), \
        .TT (TT), \
        .MAX_TRANS (MAX_TRANS) \
    ) ``MST``_bhv [LEN]; \
    generate \
        for (genvar i = 0; i < LEN; i++) begin \
            `AXI_LITE_ASSIGN(MST[i], ``MST``_dv[i]); \
            initial begin \
                $display(i); \
                ``MST``_bhv[i] = new(``MST``_dv[i]); \
                ``MST``_bhv[i].loop(); \
            end \
        end \
    endgenerate 
    
// `define MST_TEST(MST) \
//     `TEST_CASE("test") begin \
       
//     end

`define SLV_FACTORY(SLV, ID, _ADDR_S, _ADDR_E) \
    `AXIL_I SLV [SIZE] (); \
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
        .clk (clk), \
	    .rst (rst), \
        .slv (SLV) \
    );

module adam_fabric_hsdom_tb;
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

    logic clk;
    logic rst;

    logic pause_req;
    logic pause_ack;
    
    rule_t [5:0] map;
    assign map = '{
        '{ idx: 0, start_addr: 32'h0100_0000, end_addr: 32'h0200_0000},
        '{ idx: 1, start_addr: 32'h0200_0400, end_addr: 32'h0300_0800},
        '{ idx: 2, start_addr: 32'h0009_0000, end_addr: 32'h0009_0400},
        '{ idx: 3, start_addr: 32'h0009_0400, end_addr: 32'h0009_0800},
        '{ idx: 4, start_addr: 32'h0000_8000, end_addr: 32'h0000_0400},
        '{ idx: 5, start_addr: 32'h0000_0000, end_addr: 32'h0008_0000}
    };

    //localparam LEN = 5;

    //`MST_FACTORY;

    `MST_FACTORY(cpus, 4);
    `MST_FACTORY(dmas, 2);
    `MST_FACTORY(debug_slv, 1);
    `MST_FACTORY(from_lsdom, 1);

    // `SLV_FACTORY(mem0     , 0, 32'h0000_0000, 32'h0100_0000);
    // `SLV_FACTORY(mem1     , 1, 32'h0000_0000, 32'h0100_0000);
    // `SLV_FACTORY(hsip0    , 2, 32'h0000_0000, 32'h0000_0400);
    // `SLV_FACTORY(hsip1    , 3, 32'h0000_0000, 32'h0000_0400);
    // `SLV_FACTORY(debug_mst, 4, 32'h0000_0000, 32'h0900_0400);
    // `SLV_FACTORY(to_lsdom , 5, 32'h0000_0000, 32'h0008_0000);


    adam_fabric_hsdom #(
        .ADDR_WIDTH (ADDR_WIDTH),
        .DATA_WIDTH (DATA_WIDTH),
        
        .MAX_TRANS (MAX_TRANS),

        .NO_CPUS (2),
        .NO_DMAS (2),
        .NO_MEMS (2),
        .NO_HSIP (2),

        .EN_DEBUG (1)
    ) dut (
        .clk (clk),
        .rst (rst),
        
        .pause_req (pause_req),
        .pause_ack (pause_ack),
        
        .cpus (cpus),
        .dmas (dmas),
        .debug_slv (debug_slv[0]),
        .from_lsdom (from_lsdom[0]),

        .mems (mems),
        .hsip (hsip),
        .debug_mst (debug_mst),
        .to_lsdom (to_lsdom)
    );

    // adam_clk_rst_bhv #(
    //     .CLK_PERIOD (CLK_PERIOD),
    //     .RST_CYCLES (RST_CYCLES),

    //     .TA (TA),
    //     .TT (TT)
    // ) adam_clk_rst_bhv (
    //     .clk (clk),
    //     .rst (rst)
    // );

    // adam_pause_bhv #(
    //     .DELAY    (10us),
    //     .DURATION (10us),

    //     .TA (TA),
    //     .TT (TT)
    // ) adam_pause_bhv (
    //     .rst (rst),
    //     .clk (clk),

    //     .pause_req (pause_req),
    //     .pause_ack (pause_ack)
    // );

    `TEST_SUITE begin
        `TEST_CASE("test") begin
            addr_t addr;
            data_t data_w;
            data_t data_r; 
            resp_t resp_b;
            resp_t resp_d;
            @(negedge rst);
            @(posedge clk);
            forever begin
                for (int i = 0; i < 12; i++) begin
                    addr = (i % 2) ? map[i].start_addr : map[i].end_addr;
                    data_w = i / 2;
                    fork
                        // cpus_bhv[0].send_aw(addr, 3'b000);
                        // cpus_bhv[0].send_w(data_w, 4'b1111);
                        // cpus_bhv[0].recv_b(resp_b);
                        // cpus_bhv[0].send_ar(addr, 3'b000);
                        // cpus_bhv[0].recv_r(data_r, resp_d);
                    join
                    assert (resp_b == axi_pkg::RESP_OKAY);
                    assert (resp_d == axi_pkg::RESP_OKAY);
                    assert (data_r == data_w);
                end
            end
        end
    end
endmodule