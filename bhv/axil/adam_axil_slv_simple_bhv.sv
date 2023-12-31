`timescale 1ns/1ps
`include "adam/macros_bhv.svh"
`include "axi/assign.svh"

module adam_axil_slv_simple_bhv #(
    `ADAM_BHV_CFG_PARAMS,
    
    parameter ADDR_S = 32'h0000_0000,
    parameter ADDR_E = 32'hFFFF_FFFF,
    parameter DATA   = 32'h0000_FFFF,
    
    parameter MAX_TRANS = 4
) (
    ADAM_SEQ.Slave seq,
    AXI_LITE.Slave slv
);
    import adam_axil_slv_bhv::*;
    
    AXI_LITE_DV #(
        .AXI_ADDR_WIDTH(ADDR_WIDTH),
        .AXI_DATA_WIDTH(DATA_WIDTH)
    ) slv_dv (seq.clk);

    adam_axil_slv_bhv #(
        `ADAM_BHV_CFG_PARAMS_MAP,
        
        .MAX_TRANS (MAX_TRANS)
    ) slv_bhv;
    
    `AXI_LITE_ASSIGN(slv_dv, slv);
    
    initial begin
        slv_bhv = new(slv_dv);
        slv_bhv.loop();
    end

    initial begin
        ADDR_T addr;
        PROT_T prot;
        DATA_T data;
        STRB_T strb;
        RESP_T resp;

        @(negedge seq.rst);
        @(posedge seq.clk);

        forever begin
            fork
                slv_bhv.recv_aw(addr, prot);
                slv_bhv.recv_w(data, strb);
            join
            if (
                (addr >= ADDR_S) &&
                (addr < ADDR_E) &&
                (data == DATA)
            ) begin
                $display("%x %x %x", addr, ADDR_S, ADDR_E);
                $display("%d %d", data, DATA);
                resp = axi_pkg::RESP_OKAY;
            end
            else begin
                $directly("error");
                $display("%x %x %x", addr, ADDR_S, ADDR_E);
                $display("%d %d", data, DATA);
                resp = axi_pkg::RESP_DECERR;
            end
            slv_bhv.send_b(resp);
        end
    end

    initial begin
        ADDR_T addr;
        PROT_T prot;
        DATA_T data;
        STRB_T strb;
        RESP_T resp;

        @(negedge seq.rst);
        @(posedge seq.clk);

        forever begin
            slv_bhv.recv_ar(addr, prot);
            if (addr >= ADDR_S && addr < ADDR_E) begin
                data = DATA;
                resp = axi_pkg::RESP_OKAY;
            end
            else begin
                data = '0;
                resp = axi_pkg::RESP_DECERR;
            end
            slv_bhv.send_r(data, resp);
        end
    end

endmodule