`define AXIL_I AXI_LITE #( \
    .AXI_ADDR_WIDTH (ADDR_WIDTH), \
    .AXI_DATA_WIDTH (DATA_WIDTH) \
)

module adam_axil_ram #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32,

    parameter SIZE = 4096,

    // Dependent parameters bellow, do not override.

    parameter STRB_WIDTH      = DATA_WIDTH/8,
    parameter UNALIGNED_WIDTH = $clog2(STRB_WIDTH),         
    parameter ALIGNED_WIDTH   = ADDR_WIDTH - UNALIGNED_WIDTH,
    parameter ALIGNED_SIZE    = SIZE / STRB_WIDTH,

    parameter type ADDR_T    = logic [ADDR_WIDTH-1:0],
    parameter type PROT_T    = logic [1:0],
    parameter type DATA_T    = logic [DATA_WIDTH-1:0],
    parameter type STRB_T    = logic [STRB_WIDTH-1:0],
    parameter type RESP_T    = logic [1:0],
    parameter type ALIGNED_T = logic [ALIGNED_WIDTH-1:0]
) (
    ADAM_SEQ.Slave   seq,
    ADAM_PAUSE.Slave pause,

    AXI_LITE.Slave slv
);
          
    // phy ====================================================================
 
    // (* RAM_STYLE="BLOCK" *)
    DATA_T mem [ALIGNED_SIZE-1:0];

    ALIGNED_T aligned; 
    DATA_T    wdata;
    STRB_T    wstrb;
    DATA_T    rdata;

    always_ff @(posedge seq.clk) begin
        for (int i = 0; i < STRB_WIDTH; i++) begin
            if (aligned > ALIGNED_SIZE) begin
                rdata <= '0;
            end
            else if (wstrb[i]) begin
                mem[aligned][i*8 +: 8] <= wdata[i*8 +: 8]; 
                rdata[i*8 +: 8]        <= wdata[i*8 +: 8];
            end
            else begin
                rdata[i*8 +: 8] <= mem[aligned][i*8 +: 8];
            end
        end
    end

    // axil pause and skid ====================================================
    
    `AXIL_I axil_pause ();
    `AXIL_I axil_skid  ();

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

    // axil logic =============================================================

    logic  do_write;
    logic  do_read;
    RESP_T resp;

    assign wdata = axil_skid.w_data;
    assign axil_skid.r_data = rdata;

    always_comb begin
        automatic ADDR_T addr;

        // default
        aligned  = '0;
        do_write = '0;
        do_read  = '0;
        wstrb    = '0;
        resp     = '0;
        
        if (
            (axil_skid.aw_valid && axil_skid.w_valid) &&
            (!axil_skid.b_valid || axil_skid.b_ready)
        ) begin
            // able to complete write
            addr = axil.aw_addr;
            do_write = 1;
        end
        else if (
            (axil_skid.ar_valid) &&
            (!axil_skid.r_valid || axil_skid.r_ready)
        ) begin
            // able to complete read
            addr = axil.ar_addr;
            do_read  = 1;
        end

        if (addr[UNALIGNED_WIDTH-1:0] == 0 || addr < SIZE) begin
            if (do_write) wstrb = axil_skid.w_strb;
            aligned = axil.aw_addr[ADDR_WIDTH-1:UNALIGNED_WIDTH];
        end
        else begin
            resp = axi_pkg::RESP_DECERR;
        end
    end

    always_ff @(posedge seq.clk) begin  
        if (seq.rst) begin
            axil_skid.aw_ready <= 0;
            axil_skid.w_ready  <= 0;
            axil_skid.b_resp   <= 0;
            axil_skid.b_valid  <= 0;

            axil_skid.ar_ready <= 0;
            axil_skid.r_resp   <= 0;
            axil_skid.r_valid  <= 0;
        end
        else begin
            axil_skid.aw_ready <= do_write;
            axil_skid.w_ready  <= do_write;
            axil_skid.b_resp   <= resp;
            axil_skid.b_valid  <= do_write;

            axil_skid.ar_ready <= do_read;
            axil_skid.r_resp   <= resp;
            axil_skid.r_valid  <= do_read;
            
            
        end
    end

endmodule