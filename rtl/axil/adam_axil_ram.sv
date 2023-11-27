module adam_axil_ram #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32,

    parameter SIZE = 4096
) (
    ADAM_SEQ.Slave   seq,
    ADAM_PAUSE.Slave pause,

    AXI_LITE.Slave axil
);

    localparam STRB_WIDTH      = DATA_WIDTH/8;
    localparam UNALIGNED_WIDTH = $clog2(STRB_WIDTH);
    localparam ALIGNED_WIDTH   = ADDR_WIDTH - UNALIGNED_WIDTH;
    localparam ALIGNED_SIZE    = SIZE / STRB_WIDTH;

    typedef logic [ADDR_WIDTH-1:0] addr_t;
    typedef logic [DATA_WIDTH-1:0] data_t;
    typedef logic [STRB_WIDTH-1:0] strb_t;
    
    typedef logic [UNALIGNED_WIDTH-1:0] unaligned_t;
    typedef logic [ALIGNED_WIDTH-1:0]   aligned_t;

    // (* RAM_STYLE="BLOCK" *)
    data_t mem [ALIGNED_SIZE-1:0];

    addr_t waddr;
    data_t wdata;
    strb_t wstrb;
    addr_t raddr;

    // TODO: implement pause
    assign pause.ack = 0;

    always_ff @(posedge seq.clk) begin
        automatic unaligned_t unaligned;
        automatic aligned_t   aligned;
        
        if (seq.rst) begin
            axil.aw_ready = 1;
            axil.w_ready  = 1;
            axil.b_resp   = 0;
            axil.b_valid  = 0;

            axil.ar_ready = 1;
            axil.r_data   = 0;
            axil.r_resp   = 0;
            axil.r_valid  = 0;
        end
        else begin
            if(axil.r_valid && axil.r_ready) begin
                axil.r_valid = 0;
            end

            if(axil.b_valid && axil.b_ready) begin
                axil.b_valid = 0;
            end

            if(axil.aw_valid && axil.aw_ready) begin
                waddr = axil.aw_addr;
                axil.aw_ready = 0;
            end

            if(axil.w_valid && axil.w_ready) begin
                wdata = axil.w_data;
                wstrb = axil.w_strb;
                axil.w_ready = 0;
            end

            if(axil.ar_valid && axil.ar_ready) begin
                raddr = axil.ar_addr;
                axil.ar_ready = 0;
            end

            if(!axil.aw_ready && !axil.w_ready && !axil.b_valid) begin
                unaligned = waddr[UNALIGNED_WIDTH-1:0];
                aligned   = waddr[DATA_WIDTH-1:UNALIGNED_WIDTH];

                if (unaligned == 0 && aligned < ALIGNED_SIZE) begin
                    for (int i = 0; i < STRB_WIDTH; i++) begin
                        if (wstrb[i]) begin
                            mem[aligned][i*8 +: 8] = wdata[i*8 +: 8]; 
                        end
                    end
                    axil.b_resp = axi_pkg::RESP_OKAY;
                end
                else begin
                    axil.b_resp = axi_pkg::RESP_DECERR;
                end
                axil.b_valid  = 1;
                axil.aw_ready = 1;
                axil.w_ready  = 1;
            end
            else if(!axil.ar_ready && !axil.r_valid) begin
                unaligned = raddr[UNALIGNED_WIDTH-1:0];
                aligned   = raddr[DATA_WIDTH-1:UNALIGNED_WIDTH];

                if (unaligned == 0 && aligned < ALIGNED_SIZE) begin 
                    axil.r_data = mem[aligned];
                    axil.r_resp = axi_pkg::RESP_OKAY;
                end
                else begin
                    axil.r_data = 0;
                    axil.r_resp = axi_pkg::RESP_DECERR;
                end
                axil.r_valid  = 1;
                axil.ar_ready = 1;
            end
        end
    end

endmodule

