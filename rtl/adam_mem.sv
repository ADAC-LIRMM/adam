`include "adam/macros.svh"

module adam_mem #(
    `ADAM_CFG_PARAMS,

    parameter SIZE = 4096
) (
    ADAM_SEQ.Slave seq,

    input  logic  req,
    input  ADDR_T addr,
    input  logic  we,
    input  STRB_T be,
    input  DATA_T wdata,
    output DATA_T rdata
);
  
    localparam UNALIGNED_WIDTH = $clog2(STRB_WIDTH);         
    localparam ALIGNED_WIDTH   = ADDR_WIDTH - UNALIGNED_WIDTH;
    localparam ALIGNED_SIZE    = SIZE / STRB_WIDTH;

    // (* RAM_STYLE="BLOCK" *)
    DATA_T mem [ALIGNED_SIZE-1:0];
    
    logic [ALIGNED_WIDTH-1:0] aligned;

    initial begin
        for (int i = 0; i < ALIGNED_SIZE; i++) begin 
            mem[i] = '0;
        end       
    end

    assign aligned = addr[ADDR_WIDTH-1:UNALIGNED_WIDTH];

    always_ff @(posedge seq.clk) begin
        for (int i = 0; i < STRB_WIDTH; i++) begin
            if (!req || aligned > ALIGNED_SIZE) begin
                rdata[i*8 +: 8] <= '0;
            end
            else if (we && be[i]) begin
                mem[aligned][i*8 +: 8] <= wdata[i*8 +: 8]; 
                rdata[i*8 +: 8]        <= wdata[i*8 +: 8];
            end
            else begin
                rdata[i*8 +: 8] <= mem[aligned][i*8 +: 8];
            end
        end
    end

endmodule