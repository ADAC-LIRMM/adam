`include "adam/macros.svh"

module adam_mem #(
    `ADAM_CFG_PARAMS,

    parameter SIZE = 4096

`ifndef SYNTHESIS
    , parameter string HEXFILE = ""
`endif
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

    (* ram_style = "block" *)
    reg [DATA_WIDTH-1:0] mem [ALIGNED_SIZE-1:0];

`ifndef SYNTHESIS
    initial $readmemh(HEXFILE, mem);
`endif

    logic [ALIGNED_WIDTH-1:0] aligned;

    assign aligned = addr[ADDR_WIDTH-1:UNALIGNED_WIDTH];

    always_ff @(posedge seq.clk) begin
        if (we) begin
            for (int i = 0; i < STRB_WIDTH; i++) begin
                if (be[i]) begin
                    mem[aligned][i*8 +: 8] <= wdata[i*8 +: 8];
                end
            end
            rdata <= mem[aligned];
        end
        else begin
            rdata <= mem[aligned];
        end
    end

endmodule
