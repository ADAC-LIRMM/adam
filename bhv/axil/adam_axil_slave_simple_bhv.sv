`include "axi/assign.svh"

module adam_axil_slave_simple_bhv #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32,
    
    parameter ADDR_S = 32'h0000_0000,
    parameter ADDR_E = 32'hFFFF_FFFF,
    parameter DATA   = 32'h0000_FFFF,

    parameter TA = 2ns,
    parameter TT = 18ns,
    
    parameter MAX_TRANS = 4
) (
    input logic clk,
	input logic rst,

    AXI_LITE.Slave slv
);
    import adam_axil_slave_bhv::*;
    
    localparam STRB_WIDTH = DATA_WIDTH/8;

    typedef logic [ADDR_WIDTH-1:0] addr_t;
    typedef logic [2:0]            prot_t;       
    typedef logic [DATA_WIDTH-1:0] data_t;
    typedef logic [STRB_WIDTH-1:0] strb_t;
    typedef logic [1:0]            resp_t;

    AXI_LITE_DV #(
        .AXI_ADDR_WIDTH(ADDR_WIDTH),
        .AXI_DATA_WIDTH(DATA_WIDTH)
    ) slv_dv (clk);

    adam_axil_slave_bhv #(
        .ADDR_WIDTH (ADDR_WIDTH),
        .DATA_WIDTH (DATA_WIDTH),
        
        .TA (TA),
        .TT (TT),
        
        .MAX_TRANS (MAX_TRANS)
    ) slv_bhv;
    
    `AXI_LITE_ASSIGN(slv_dv, slv);
    
    initial begin
        slv_bhv = new(slv_dv);
        slv_bhv.loop();
    end

    initial begin
        addr_t addr;
        prot_t prot;
        data_t data;
        strb_t strb;
        resp_t resp;

        @(negedge rst);
        @(posedge clk);

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
                resp = axi_pkg::RESP_OKAY;
            end
            else begin
                resp = axi_pkg::RESP_DECERR;
            end
            slv_bhv.send_b(resp);
        end
    end

    initial begin
        addr_t addr;
        prot_t prot;
        data_t data;
        strb_t strb;
        resp_t resp;

        @(negedge rst);
        @(posedge clk);

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