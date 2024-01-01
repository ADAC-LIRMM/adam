`timescale 1ns/1ps

`include "adam/macros_bhv.svh"
`include "axi/assign.svh"
`include "apb/assign.svh"
`include "vunit_defines.svh"

module adam_axil_apb_bridge_tb;
    import adam_axil_mst_bhv::*;

    `ADAM_BHV_CFG_LOCALPARAMS;
    
    localparam NO_MSTS = 8;

    localparam MAX_TRANS = 7;

    localparam type RULE_T = adam_cfg_pkg::MMAP_T;
    
    ADAM_SEQ   seq   ();
    ADAM_PAUSE pause ();

    RULE_T addr_map [NO_MSTS+1];

    ADDR_T paddr   [NO_MSTS+1];
    PROT_T pprot   [NO_MSTS+1];
    logic  psel    [NO_MSTS+1];
    logic  penable [NO_MSTS+1];
    logic  pwrite  [NO_MSTS+1];
    DATA_T pwdata  [NO_MSTS+1];
    STRB_T pstrb   [NO_MSTS+1];
    logic  pready  [NO_MSTS+1];
    DATA_T prdata  [NO_MSTS+1];
    logic  pslverr [NO_MSTS+1];

    `ADAM_AXIL_I axil ();
    
    `ADAM_AXIL_DV_I axil_dv (seq.clk);

    `AXI_LITE_ASSIGN(axil, axil_dv);

    adam_axil_mst_bhv #(
        `ADAM_BHV_CFG_PARAMS_MAP,

        .MAX_TRANS (MAX_TRANS)
    ) axil_bhv = new(axil_dv);

    `ADAM_APB_I apb [NO_MSTS+1] ();

    always_comb begin
        for (int i = 0; i < NO_MSTS; i++) begin
            addr_map[i] = '{
                start : i << 16,
                end_  : (i + 1) << 16
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

        .NO_MSTS (NO_MSTS),
    
        .RULE_T (RULE_T)
    ) dut (
        .seq   (seq),
        .pause (pause),

        .slv (axil),
        .mst (apb),

        .addr_map (addr_map)
    );

    generate
        for (genvar i = 0; i < NO_MSTS; i++) begin
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

            for (int i = 0; i < NO_MSTS; i++) begin
                pready [i] = 0;
                prdata [i] = 0;
                pslverr[i] = 0;
            end

            @(negedge seq.rst);
            @(posedge seq.clk);

            for (int i = 0; i < NO_MSTS; i++) begin
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