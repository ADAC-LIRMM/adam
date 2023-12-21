`timescale 1ns/1ps

`include "adam/macros_bhv.svh"
`include "axi/assign.svh"
`include "apb/assign.svh"
`include "vunit_defines.svh"

module adam_axil_apb_bridge_tb;
    import adam_axil_mst_bhv::*;

    `ADAM_BHV_CFG_LOCALPARAMS;
    
    localparam NO_APBS = 8;

    localparam MAX_TRANS = 7;

    typedef struct packed {
        int unsigned idx;
        ADDR_T start_addr;
        ADDR_T end_addr;
    } rule_t;
    
    ADAM_SEQ   seq   ();
    ADAM_PAUSE pause ();

    rule_t [NO_APBS-1:0] addr_map;

    ADDR_T paddr   [NO_APBS];
    PROT_T pprot   [NO_APBS];
    logic  psel    [NO_APBS];
    logic  penable [NO_APBS];
    logic  pwrite  [NO_APBS];
    DATA_T pwdata  [NO_APBS];
    STRB_T pstrb   [NO_APBS];
    logic  pready  [NO_APBS];
    DATA_T prdata  [NO_APBS];
    logic  pslverr [NO_APBS];

    `ADAM_AXIL_I axil ();
    
    AXI_LITE_DV #(
        .AXI_ADDR_WIDTH(ADDR_WIDTH),
        .AXI_DATA_WIDTH(DATA_WIDTH)
    ) axil_dv (seq.clk);

    `AXI_LITE_ASSIGN(axil, axil_dv);

    adam_axil_mst_bhv #(
        .ADDR_WIDTH (ADDR_WIDTH),
        .DATA_WIDTH (DATA_WIDTH),
    
        .TA (TA),
        .TT (TT),

        .MAX_TRANS (MAX_TRANS)
    ) axil_bhv = new(axil_dv);

    `ADAM_APB_I apb [NO_APBS] ();

    always_comb begin
        for (int i = 0; i < NO_APBS; i++) begin
            addr_map[i] = '{
                idx: i,
                start_addr: i << 16,
                end_addr: (i + 1) << 16
            };
        end
    end

    adam_seq_bhv #(
        `ADAM_BHV_CFG_PARAMS_MAP
    ) adam_seq_bhv (
        .seq (seq)
    );

    adam_pause_bhv #(
        `ADAM_BHV_CFG_PARAMS_MAP,

        .DELAY    (100ns),
        .DURATION (100ns)
    ) adam_pause_bhv (
        .seq   (seq),
        .pause (pause)
    );

    adam_axil_apb_bridge #(
        `ADAM_CFG_PARAMS_MAP,

        .NO_APBS (NO_APBS),
    
        .RULE_T (rule_t)
    ) dut (
        .seq   (seq),
        .pause (pause),

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
            ADDR_T addr;
            DATA_T data;
            RESP_T resp;

            for (int i = 0; i < NO_APBS; i++) begin
                pready [i] = 0;
                prdata [i] = 0;
                pslverr[i] = 0;
            end

            @(negedge seq.rst);
            @(posedge seq.clk);

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
                    prdata [i] <= #TA DATA_T'(i);
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

    initial begin
        #10us $error("timeout");
    end

    task cycle_start();
        #TT;
    endtask

    task cycle_end();
        @(posedge seq.clk);
    endtask

endmodule