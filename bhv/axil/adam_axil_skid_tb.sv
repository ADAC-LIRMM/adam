`include "axi/assign.svh"
`include "vunit_defines.svh"

module adam_axil_skid_tb;
    import adam_axil_master_bhv::*;
    import adam_axil_slave_bhv::*;

    localparam ADDR_WIDTH = 32;
    localparam DATA_WIDTH = 32;

    localparam MAX_TRANS = 1;

    localparam CLK_PERIOD = 20ns;
    localparam RST_CYCLES = 5;

    localparam TA = 2ns;
    localparam TT = CLK_PERIOD - TA;

    localparam STRB_WIDTH = DATA_WIDTH / 8;

    typedef logic [ADDR_WIDTH-1:0] addr_t;
    typedef logic [2:0] prot_t;
    typedef logic [DATA_WIDTH-1:0] data_t;
    typedef logic [STRB_WIDTH-1:0] strb_t;
    typedef logic [1:0] resp_t;

    ADAM_SEQ seq();

    AXI_LITE #(
        .AXI_ADDR_WIDTH(ADDR_WIDTH),
        .AXI_DATA_WIDTH(DATA_WIDTH)
    ) mst ();

    AXI_LITE_DV #(
        .AXI_ADDR_WIDTH(ADDR_WIDTH),
        .AXI_DATA_WIDTH(DATA_WIDTH)
    ) mst_dv(seq.clk);

    `AXI_LITE_ASSIGN(mst, mst_dv);

    adam_axil_master_bhv #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH),

        .TA(TA),
        .TT(TT),
        
        .MAX_TRANS(MAX_TRANS)
    ) mst_bhv;

    AXI_LITE #(
        .AXI_ADDR_WIDTH(ADDR_WIDTH),
        .AXI_DATA_WIDTH(DATA_WIDTH)
    ) slv ();

    AXI_LITE_DV #(
        .AXI_ADDR_WIDTH(ADDR_WIDTH),
        .AXI_DATA_WIDTH(DATA_WIDTH)
    ) slv_dv(seq.clk);

    `AXI_LITE_ASSIGN(slv_dv, slv);

    adam_axil_slave_bhv #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH),

        .TA(TA),
        .TT(TT),
        
        .MAX_TRANS(MAX_TRANS)
    ) slv_bhv;

    adam_clk_rst_bhv #(
        .CLK_PERIOD(CLK_PERIOD),
        .RST_CYCLES(RST_CYCLES),
        
        .TA(TA),
        .TT(TT)
    ) adam_clk_rst_bhv (
        .seq(seq)
    );

    adam_axil_skid #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH),

        .BYPASS_AW (0),
        .BYPASS_W  (0),
        .BYPASS_B  (0),
        .BYPASS_AR (0),
        .BYPASS_R  (0)
    ) dut (
        .seq (seq),

        .slv (mst),
        .mst (slv)
    );

    initial begin
        mst_bhv = new(mst_dv);
        mst_bhv.loop();
    end

    initial begin
        slv_bhv = new(slv_dv);
        slv_bhv.loop();
    end

    `TEST_SUITE begin
        `TEST_CASE("without_backpressure") begin
            automatic addr_t addr;
            automatic prot_t prot;
            automatic data_t data;
            automatic strb_t strb;
            automatic resp_t resp;
            
            addr = $urandom();
            prot = 3'b000;
            data = $urandom();
            strb = 4'b1111;
            resp = 2'b00;

            @(negedge seq.rst);
            @(posedge seq.clk);
            
            mst_bhv.send_aw(addr, prot);
            slv_bhv.recv_aw(addr, prot);

            mst_bhv.send_w(addr, strb);
            slv_bhv.recv_w(addr, strb);
        
            slv_bhv.send_b(resp);
            mst_bhv.recv_b(resp);

            mst_bhv.send_ar(addr, prot);
            slv_bhv.recv_ar(addr, prot);

            slv_bhv.send_r(data, resp);
            mst_bhv.recv_r(data, resp);
        end

        `TEST_CASE("with_backpressure") begin            
            automatic addr_t addr;
            automatic prot_t prot;
            automatic data_t data;
            automatic strb_t strb;
            automatic resp_t resp;
            
            addr = $urandom();
            prot = 3'b000;
            data = $urandom();
            strb = 4'b1111;
            resp = 2'b00;

            @(negedge seq.rst);
            @(posedge seq.clk);

            repeat (2) mst_bhv.send_aw(addr, prot);
            @(negedge mst.aw_ready);
            repeat (2) slv_bhv.recv_aw(addr, prot);
            
            repeat (2) mst_bhv.send_w(addr, strb);
            @(negedge mst.w_ready);
            repeat (2) slv_bhv.recv_w(addr, strb);
            
            repeat (2) slv_bhv.send_b(resp);
            @(negedge slv.b_ready);
            repeat (2) mst_bhv.recv_b(resp);

            repeat (2) mst_bhv.send_ar(addr, prot);
            @(negedge mst.ar_ready);
            repeat (2) slv_bhv.recv_ar(addr, prot);

            repeat (2) slv_bhv.send_r(data, resp);
            @(negedge slv.r_ready);
            repeat (2) mst_bhv.recv_r(data, resp);
        end
    end
endmodule
