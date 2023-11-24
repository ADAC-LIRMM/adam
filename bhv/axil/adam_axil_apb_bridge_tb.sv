`include "axi/assign.svh"
`include "apb/assign.svh"
`include "vunit_defines.svh"

module adam_axil_apb_bridge_tb;
    import adam_axil_master_bhv::*;

    localparam ADDR_WIDTH = 32;
    localparam DATA_WIDTH = 32;
    
    localparam NO_APBS = 8;

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

    rule_t [NO_APBS-1:0] addr_map;

    addr_t          paddr   [NO_APBS];
    apb_pkg::prot_t pprot   [NO_APBS];
    logic           psel    [NO_APBS];
    logic           penable [NO_APBS];
    logic           pwrite  [NO_APBS];
    data_t          pwdata  [NO_APBS];
    strb_t          pstrb   [NO_APBS];
    logic           pready  [NO_APBS];
    data_t          prdata  [NO_APBS];
    logic           pslverr [NO_APBS];

    AXI_LITE #(
        .AXI_ADDR_WIDTH (ADDR_WIDTH),
        .AXI_DATA_WIDTH (DATA_WIDTH)
    ) axil ();
    
    AXI_LITE_DV #(
        .AXI_ADDR_WIDTH(ADDR_WIDTH),
        .AXI_DATA_WIDTH(DATA_WIDTH)
    ) axil_dv (clk);

    `AXI_LITE_ASSIGN(axil, axil_dv);

    adam_axil_master_bhv #(
        .ADDR_WIDTH (ADDR_WIDTH),
        .DATA_WIDTH (DATA_WIDTH),
    
        .TA (TA),
        .TT (TT),

        .MAX_TRANS (MAX_TRANS)
    ) axil_bhv = new(axil_dv);

    APB #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH)
    ) apb [NO_APBS] ();

    always_comb begin
        for (int i = 0; i < NO_APBS; i++) begin
            addr_map[i] = '{
                idx: i,
                start_addr: i << 16,
                end_addr: (i + 1) << 16
            };
        end
    end

    adam_clk_rst_bhv #(
        .CLK_PERIOD (CLK_PERIOD),
        .RST_CYCLES (RST_CYCLES),

        .TA (TA),
        .TT (TT)
    ) adam_clk_rst_bhv (
        .clk (clk),
        .rst (rst)
    );

    adam_pause_bhv #(
        .DELAY    (100ns),
        .DURATION (100ns),

        .TA (TA),
        .TT (TT)
    ) adam_pause_bhv (
        .rst (rst),
        .clk (clk),

        .pause_req (pause_req),
        .pause_ack (pause_ack)
    );

    adam_axil_apb_bridge #(
        .ADDR_WIDTH (ADDR_WIDTH),
        .DATA_WIDTH (DATA_WIDTH),

        .NO_APBS (NO_APBS),
    
        .rule_t (rule_t)
    ) dut (
        .clk  (clk),
        .rst  (rst),

        .pause_req (pause_req),
        .pause_ack (pause_ack),

        .axil (axil),
        
        .apb (apb),

        .addr_map (addr_map)
    );

    generate
        for (genvar i = 0; i < NO_APBS; i++) begin
            assign paddr  [i] = apb[i].paddr;
            assign pprot  [i] = apb[i].pprot;
            assign psel   [i] = apb[i].psel;
            assign penable[i] = apb[i].penable;
            assign pwrite [i] = apb[i].pwrite;
            assign pwdata [i] = apb[i].pwdata;
            assign pstrb  [i] = apb[i].pstrb;
            
            assign apb[i].pready  = pready [i];
            assign apb[i].prdata  = prdata [i];
            assign apb[i].pslverr = pslverr[i];
        end
    endgenerate

    initial axil_bhv.loop();

    `TEST_SUITE begin
        `TEST_CASE("test") begin
            addr_t addr;
            data_t data;
            resp_t resp;

            for (int i = 0; i < NO_APBS; i++) begin
                pready [i] = 0;
                prdata [i] = 0;
                pslverr[i] = 0;
            end

            @(negedge rst);
            @(posedge clk);

            for (int i = 0; i < NO_APBS; i++) begin
                addr = (i << 16);
                data = $urandom();

                fork
                    axil_bhv.send_aw(addr, 3'b000);
                    axil_bhv.send_w(data, 4'b1111);
                    axil_bhv.send_ar(addr, 3'b000);
                join

                for (int j = 0; j < 2; j++) begin
                    pready [i] <= #TA 1;
                    prdata [i] <= #TA data_t'(i);
                    pslverr[i] <= #TA 0;
                    cycle_start();
                    while(!psel[i] || !penable[i] || !pready[i]) begin
                        cycle_end();
                        cycle_start();
                    end
                    cycle_end();

                    pready[i] <= #TA 0;
                    cycle_start();
                    cycle_end();
                end

                fork
                    axil_bhv.recv_b(resp);
                    axil_bhv.recv_r(data, resp);
                join
            end
        end
    end

    task cycle_start();
        #TT;
    endtask

    task cycle_end();
        @(posedge clk);
    endtask

endmodule