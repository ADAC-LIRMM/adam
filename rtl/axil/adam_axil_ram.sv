`define AXIL_I AXI_LITE #( \
    .AXI_ADDR_WIDTH (ADDR_WIDTH), \
    .AXI_DATA_WIDTH (DATA_WIDTH) \
)

module adam_axil_ram #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32,

    parameter SIZE = 4096
) (
    ADAM_SEQ.Slave   seq,
    ADAM_PAUSE.Slave pause,

    AXI_LITE.Slave slv
);

    localparam STRB_WIDTH = DATA_WIDTH/8;
    localparam UNALIGNED_WIDTH = $clog2(STRB_WIDTH);         
    localparam ALIGNED_WIDTH = ADDR_WIDTH - UNALIGNED_WIDTH;
    localparam ALIGNED_SIZE  = SIZE / STRB_WIDTH;          

    typedef logic [ADDR_WIDTH-1:0] addr_t;
    typedef logic [DATA_WIDTH-1:0] data_t;
    typedef logic [STRB_WIDTH-1:0] strb_t;
    
    `AXIL_I axil_pause ();
    `AXIL_I axil_skid  ();

    logic [ALIGNED_WIDTH-1:0] addr_aligned;
    data_t wdata;
    strb_t wstrb;
    data_t rdata;

    adam_axil_pause #(
        .ADDR_WIDTH (ADDR_WIDTH),
        .DATA_WIDTH (DATA_WIDTH),

        .MAX_TRANS  (3)
    ) adam_axil_pause (
        .seq   (seq),
        .pause (pause),

        .slv (slv),
        .mst (axil_pause)
    );

    adam_axil_skid #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH),

        .BYPASS_B  (1),
        .BYPASS_R  (1)
    ) adam_axil_skid (
        .seq (seq),

        .slv (axil_pause),
        .mst (axil_skid)
    );

    adam_axil_ram__phy #(
        .ADDR_WIDTH (ALIGNED_WIDTH),
        .DATA_WIDTH (DATA_WIDTH),
        .SIZE       (ALIGNED_SIZE) 
    ) adam_axil_ram__phy (
        .clk   (seq.clk),
        .addr  (addr_aligned),
        .wdata (wdata),
        .wstrb (wstrb),
        .rdata (rdata)
    );

    always_ff @(posedge seq.clk) begin
        automatic bit write;
        automatic bit read;

        write = axil.aw_valid && axil.w_valid;

        axil.aw_ready <= ;
        axil.w_ready  <= axil.aw_valid && axil.w_valid;

    end

    always_ff @(posedge seq.clk) begin  
        automatic bit aw_ok, w_ok, b_ok, ar_ok, r_ok;
        
        if(axil.r_valid && axil.r_ready) begin
            r_ok = 0;
        end

        if(axil.b_valid && axil.b_ready) begin
            b_ok = 0;
        end

        if(axil.aw_valid && axil.aw_ready) begin
            waddr <= axil.aw_addr;
            aw_ok = 0;
        end

        if(axil.w_valid && axil.w_ready) begin
            wdata = axil.w_data;
            wstrb = axil.w_strb;
            w_ok = 0;
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

        axil.aw_ready <= aw_r;
        axil.w_ready  <= w_r;
        axil.b_valid  <= b_v;

        axil.ar_ready <= ar_r;
        axil.r_valid  <= r_v;

        if (seq.rst) begin
            axil.aw_ready <= 0;
            axil.w_ready  <= 0;
            axil.b_resp   <= 0;
            axil.b_valid  <= 0;

            axil.ar_ready <= 0;
            axil.r_data   <= 0;
            axil.r_resp   <= 0;
            axil.r_valid  <= 0;
        end
    end

endmodule

module adam_axil_ram__phy #(
    parameter ADDR_WIDTH = 10,
    parameter DATA_WIDTH = 32,
    parameter SIZE       = 1024,

    // Dependent parameters bellow, do not override.

    parameter STRB_WIDTH  = DATA_WIDTH/8,

    parameter type addr_t = logic [ADDR_WIDTH-1:0],
    parameter type data_t = logic [DATA_WIDTH-1:0],
    parameter type strb_t = logic [STRB_WIDTH-1:0]  
) (
    input  logic  clk,
    input  quot_t addr,
    input  data_t wdata,
    input  strb_t wstrb,
    output data_t rdata
);
    // (* RAM_STYLE="BLOCK" *)
    data_t mem [SIZE-1:0];

    always_ff @(posedge clk) begin
        for (int i = 0; i < STRB_WIDTH; i++) begin
            if (addr > SIZE) begin
                rdata <= '0;
            end
            else if (wstrb[i]) begin
                mem[addr][i*8 +: 8] <= wdata[i*8 +: 8]; 
                rdata[i*8 +: 8]     <= wdata[i*8 +: 8];
            end
            else begin
                rdata[i*8 +: 8] <= mem[addr][i*8 +: 8];
            end
        end
    end
endmodule
