`include "axi/assign.svh"

module axi_lite_xbar_perf_tb;

    localparam MASTER_COUNT = 2;
    localparam SLAVE_COUNT  = 2;

    localparam CP = 10ns;
    localparam APPL_TIME =  2ns;
    localparam TEST_TIME =  8ns;

    localparam ADDR_WIDTH = 16;   
    localparam DATA_WIDTH = 32;   
    localparam STRB_WIDTH = DATA_WIDTH/8;

    localparam axi_pkg::xbar_cfg_t XBAR_CFG = '{
        NoSlvPorts: MASTER_COUNT,
        NoMstPorts: SLAVE_COUNT,
        MaxMstTrans: 10,
        MaxSlvTrans: 10,
        FallThrough: 0,
        LatencyMode: axi_pkg::CUT_ALL_AX,
        AxiAddrWidth: ADDR_WIDTH,
        AxiDataWidth: DATA_WIDTH,
        NoAddrRules: 2,
        default: 0
    };

    typedef axi_test::axi_lite_driver #(
        .AW(ADDR_WIDTH),
        .DW(DATA_WIDTH),
        .TA(APPL_TIME),
        .TT(TEST_TIME)
    ) axi_lite_driver_t;

    typedef logic [7:0]            byte_t;
    typedef logic [ADDR_WIDTH-1:0] addr_t;
    typedef logic [1:0]            prot_t;       
    typedef logic [DATA_WIDTH-1:0] data_t;
    typedef logic [STRB_WIDTH-1:0] strb_t;
    typedef logic [1:0]            resp_t;

    typedef struct packed {
        int unsigned idx;
        logic [DATA_WIDTH-1:0] start_addr;
        logic [DATA_WIDTH-1:0] end_addr;
    } rule_t;

    localparam rule_t [XBAR_CFG.NoAddrRules-1:0] ADDR_MAP = '{
        '{idx: 1, start_addr: 16'h1000, end_addr: 16'h1111},
        '{idx: 0, start_addr: 16'h0000, end_addr: 16'h0111}
    };

    logic clk;
    logic rst_n;

    logic  wen;
    addr_t addr;
    strb_t strb;
    data_t din;
    data_t dout;

    AXI_LITE #(
        .AXI_ADDR_WIDTH(ADDR_WIDTH),
        .AXI_DATA_WIDTH(DATA_WIDTH)
    ) master [MASTER_COUNT-1:0] ();

    AXI_LITE_DV #(
        .AXI_ADDR_WIDTH(ADDR_WIDTH),
        .AXI_DATA_WIDTH(DATA_WIDTH)
    ) master_dv (clk);

    `AXI_LITE_ASSIGN(master[0], master_dv)

    AXI_LITE #(
        .AXI_ADDR_WIDTH(ADDR_WIDTH),
        .AXI_DATA_WIDTH(DATA_WIDTH)
    ) slave [SLAVE_COUNT-1:0] ();
    
    axi_lite_driver_t mst_drv = new(master_dv);

    axi_lite_xbar_intf #(
        .Cfg(XBAR_CFG),
        .rule_t(rule_t)
    ) dut (
        .clk_i(clk),
        .rst_ni(rst_n),
        .test_i(0),
        .slv_ports(master),
        .mst_ports(slave),
        .addr_map_i(ADDR_MAP),
        .en_default_mst_port_i(0),
        .default_mst_port_i(0)
    );

    clk_rst_gen #(
        .ClkPeriod(CP),
        .RstClkCycles(5)
    ) i_clk_gen (
        .clk_o(clk),
        .rst_no(rst_n)
    );

    axil_to_mem #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH)
    ) axil_to_mem (
        .clk(clk),
        .rst_n(rst_n),
    
        .slave(slave[0]),

        .wen(wen),
        .addr(addr),
        .strb(strb),
        .din(din),
        .dout(dout)
    );

    ram #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH),
        .STRB_WIDTH(DATA_WIDTH/8)
    ) ram (
        .clk(clk),
        .wen(wen),
        .addr(addr),
        .strb(strb),
        .din(din),
        .dout(dout)
    );

    initial begin
        resp_t resp;
        data_t data;
        
        master[0].aw_valid = 0;
        master[0].aw_addr = 0;
        master[0].aw_prot = 0;
        master[0].w_data = 0;
        master[0].w_strb = 4'b1111;
        master[0].w_valid = 0;
        master[0].b_ready = 0;
        master[0].ar_addr = 0;
        master[0].ar_prot = 0;
        master[0].ar_valid = 0;
        master[0].r_ready = 0;

        master[1].aw_valid = 0;
        master[1].aw_addr = 0;
        master[1].aw_prot = 0;
        master[1].w_data = 0;
        master[1].w_strb = 0;
        master[1].w_valid = 0;
        master[1].b_ready = 0;
        master[1].ar_addr = 0;
        master[1].ar_prot = 0;
        master[1].ar_valid = 0;
        master[1].r_ready = 0;

        slave[1].aw_ready = 0;
        slave[1].w_ready = 0;
        slave[1].b_resp = 0;
        slave[1].b_valid = 0;
        slave[1].ar_ready = 0;
        slave[1].r_data = 0;
        slave[1].r_resp = 0;
        slave[1].r_valid = 0;

        @(posedge rst_n);
        repeat (5) @(posedge clk);

        // Test 1 (write at max throuput)
        fork
            for (int i = 0; i < 10; i++) mst_drv.send_aw(i, 0);
            for (int i = 0; i < 10; i++) mst_drv.send_w(i, 4'b1111);
            for (int i = 0; i < 10; i++) mst_drv.recv_b(resp);
        join
        
        // Test 2 (write at max throuput)
        fork
            for (int i = 0; i < 10; i++) mst_drv.send_ar(i, 0);
            for (int i = 0; i < 10; i++) begin
                mst_drv.recv_r(data, resp);
                assert(data == i);
            end
        join

        repeat (5) @(posedge clk);

        $finish();

        // // Test 2 (read at max throuput)
        // @(posedge clk);
        // master[0].ar_addr = 0;
        // master[0].ar_valid = 1;
        // master[0].r_ready = 1;

        // for(int i = 0; i < 10; i++) begin    
        //     master[0].ar_addr = i;
            
        //     //assert (master[0].ar_ready == 1) else $finish();
            
        //     @(posedge clk);
            
        //     //assert (master[0].r_valid == 1) else $finish();
        //     //assert (master[0].r_data == i) else $finish();
        // end

        // master[0].ar_valid = 0;
        // master[0].r_ready = 0;

        // $finish();
    end

endmodule