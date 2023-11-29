`include "axi/assign.svh"
`include "vunit_defines.svh"

module adam_fabric_lsxp_tb;
    import adam_axil_mst_bhv::*;

    localparam ADDR_WIDTH = 32;
    localparam DATA_WIDTH = 32;

    localparam NO_MSTS = 8;
    
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

    rule_t [NO_MSTS-1:0] addr_map;

    AXI_LITE #(
        .AXI_ADDR_WIDTH (ADDR_WIDTH),
        .AXI_DATA_WIDTH (DATA_WIDTH)
    ) mst ();

    AXI_LITE_DV #(
        .AXI_ADDR_WIDTH(ADDR_WIDTH),
        .AXI_DATA_WIDTH(DATA_WIDTH)
    ) mst_dv (seq.clk);

    APB #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH)
    ) slvs [NO_MSTS] ();

    `AXI_LITE_ASSIGN(mst, mst_dv);

    generate
        for (genvar i = 0; i < NO_MSTS; i++) begin
            assign addr_map[i] = '{
                idx: i,
                start_addr: 1024 * i,
                end_addr: 1024 * (i + 1)
            };
        end
    endgenerate

    adam_clk_rst_bhv #(
        .CLK_PERIOD (CLK_PERIOD),
        .RST_CYCLES (RST_CYCLES),

        .TA (TA),
        .TT (TT)
    ) clk_rst_gen (
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

    adam_axil_mst_bhv #(
        .ADDR_WIDTH (ADDR_WIDTH),
        .DATA_WIDTH (DATA_WIDTH),
        .TA (TA),
        .TT (TT),
        .MAX_TRANS (MAX_TRANS)
    ) mst_bhv;

    adam_fabric_lsxp #(
        .ADDR_WIDTH (ADDR_WIDTH),
        .DATA_WIDTH (DATA_WIDTH),
        
        .NO_MSTS (NO_MSTS)
    ) dut (
        .seq   (seq),
        .pause (pause),
        
        .slv  (mst),
        .msts (slvs)
    );

    initial begin
        mst_bhv = new(mst_dv);
        mst_bhv.loop();
    end

    generate
        for (genvar i = 0; i < NO_MSTS; i++) begin
            assign slvs[i].pready  = '1;
            assign slvs[i].prdata  = data_t'(i);
            assign slvs[i].pslverr = '0;
        end
    endgenerate
    
    `TEST_SUITE begin
        `TEST_CASE("test") begin
            addr_t addr;
            data_t wdata, rdata;
            resp_t wresp, rresp;

            @(negedge seq.rst);
            @(posedge seq.clk);

            for (int i = 0; i < NO_MSTS; i++) begin
                for (int j = 0; j < 2; j++) begin
                    if (j == 0) begin
                        addr = addr_map[i].start_addr;
                    end
                    else begin
                        addr = addr_map[i].end_addr - 1;
                    end

                    wdata = data_t'(i);

                    fork
                        mst_bhv.send_aw(addr, 3'b000);
                        mst_bhv.send_w(wdata, 4'b1111);
                        mst_bhv.recv_b(wresp);
                        mst_bhv.send_ar(addr, 3'b000);
                        mst_bhv.recv_r(rdata, rresp);
                    join

                    assert(wresp == axi_pkg::RESP_OKAY); 
                    assert(rresp == axi_pkg::RESP_OKAY);
                    assert(rdata == wdata);
                end
            end
        end
    end

endmodule
