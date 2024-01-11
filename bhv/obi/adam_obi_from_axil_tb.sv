`timescale 1ns/1ps
`include "adam/macros_bhv.svh"
`include "vunit_defines.svh"

module adam_obi_from_axil_tb;
    import adam_axil_mst_bhv::*;
    import adam_axil_slv_bhv::*;
    import adam_stream_slv_bhv::*;
    import adam_stream_mst_bhv::*;

    `ADAM_BHV_CFG_LOCALPARAMS;
    
    localparam MAX_TRANS = 4; //2**$clog2(FAB_MAX_TRANS);
    localparam NO_TESTS = 1000;

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

    // axil master ============================================================

    `ADAM_AXIL_BHV_MST_FACTORY(MAX_TRANS, axil, seq.clk);

    // obi slave ==============================================================

    typedef struct {
        ADDR_T addr;
        logic  we;
        STRB_T be;
        DATA_T wdata;
    } obi_req_t;

    typedef struct {
        DATA_T rdata;
    } obi_resp_t;

    `ADAM_STREAM_BHV_SLV_FACTORY(
        obi_req_t, TA, TT, 2*MAX_TRANS,
        obi_req, seq.clk
    );

    `ADAM_STREAM_BHV_MST_FACTORY(
        obi_resp_t, TA, TT,
        obi_resp, seq.clk
    );

    // dut ====================================================================

    adam_obi_from_axil #(
        `ADAM_CFG_PARAMS_MAP,

        .MAX_TRANS (MAX_TRANS)
    ) dut (
        .seq   (seq),
        .pause (pause),

        .axil (axil),

        .req    (obi_req.valid),
        .gnt    (obi_req.ready),
        .addr   (obi_req.data.addr),
        .we     (obi_req.data.we),
        .be     (obi_req.data.be),
        .wdata  (obi_req.data.wdata),
        .rvalid (obi_resp.valid),
        .rready (obi_resp.ready),
        .rdata  (obi_resp.data.rdata)
    );

    // test ===================================================================

    typedef struct {
        logic  is_write;
        ADDR_T addr;
        STRB_T strb;
        DATA_T data;
    } test_t;

    test_t obi_wreq_queue  [$];
    test_t obi_rreq_queue  [$];
    test_t obi_resp_queue  [$];
    test_t axil_resp_queue [$];

    `TEST_SUITE begin
        `TEST_CASE("test") begin
            `ADAM_UNTIL(!seq.rst);
            fork
                axil_req_task();
                obi_req_task();
                obi_resp_task();
                axil_resp_task();
            join
        end
    end

    initial begin
        #10000us $error("timeout");
    end

    task axil_req_task();
        test_t test;

        for (int i = 0; i < NO_TESTS; i++) begin
            test.is_write = $urandom();
            test.addr     = $urandom();
            test.strb     = $urandom();
            test.data     = $urandom();
            
            $display("[%0d] is_write: %0d, addr: %x, strb: %b, data: %x",
                i, test.is_write, test.addr, test.strb, test.data);
                
            if (test.is_write) begin
                axil_bhv.send_aw(test.addr, 3'b000);
                axil_bhv.send_w(test.data, test.strb);
            end
            else begin
                axil_bhv.send_ar(test.addr, 3'b000);
            end

            while (pause.req && pause.ack) @(posedge seq.clk);
            repeat ($urandom_range(0, 3)) @(posedge seq.clk);

            if (test.is_write) begin
                obi_wreq_queue.push_front(test);
            end
            else begin
                obi_rreq_queue.push_front(test);
            end
        end
    endtask

    task obi_req_task();
        test_t    test;
        obi_req_t req;

        repeat (NO_TESTS) begin
            obi_req_bhv.recv(req);

            if (req.we) begin
                `ADAM_UNTIL(obi_wreq_queue.size() > 0);
                test = obi_wreq_queue.pop_back();
            end
            else begin
                `ADAM_UNTIL(obi_rreq_queue.size() > 0);
                test = obi_rreq_queue.pop_back();
            end
            
            assert (req.addr == test.addr);
            assert (req.we == test.is_write);
            if (test.is_write) begin
                assert (req.be    == test.strb);
                assert (req.wdata == test.data);
            end
            
            while (pause.req && pause.ack) @(posedge seq.clk);
            repeat ($urandom_range(0, 3)) @(posedge seq.clk);
            
            obi_resp_queue.push_front(test);
        end
    endtask

    task obi_resp_task();
        test_t     test;
        obi_resp_t resp;
        
        repeat (NO_TESTS) begin
            `ADAM_UNTIL(obi_resp_queue.size() > 0);
            test = obi_resp_queue.pop_back();

            if (test.is_write) begin
                resp.rdata = '0;
                obi_resp_bhv.send(resp);
            end
            else begin
                resp.rdata = test.data;
                obi_resp_bhv.send(resp);
            end
            
            while (pause.req && pause.ack) @(posedge seq.clk);
            repeat ($urandom_range(0, 3)) @(posedge seq.clk);

            axil_resp_queue.push_front(test);           
        end
    endtask

    task axil_resp_task();
        test_t test;
        DATA_T data;
        RESP_T resp;
        
        repeat (NO_TESTS) begin
            `ADAM_UNTIL(axil_resp_queue.size() > 0);
            test = axil_resp_queue.pop_back();

            if (test.is_write) begin
                axil_bhv.recv_b(resp);
                assert (resp == axi_pkg::RESP_OKAY);
            end
            else begin
                 axil_bhv.recv_r(data, resp);
                assert (resp == axi_pkg::RESP_OKAY);
                assert (data == test.data);
            end

            while (pause.req && pause.ack) @(posedge seq.clk);
            repeat ($urandom_range(0, 3)) @(posedge seq.clk);
        end
    endtask
    
    task cycle_start();
        #TT;
    endtask

    task cycle_end();
        @(posedge seq.clk);
    endtask

endmodule