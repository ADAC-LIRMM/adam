`include "adam/macros.svh"

module adam_axil_ram #(
    `ADAM_CFG_PARAMS,

    parameter SIZE = 4096,

    // Dependent parameters bellow, do not override.

    parameter UNALIGNED_WIDTH = $clog2(STRB_WIDTH),         
    parameter ALIGNED_WIDTH   = ADDR_WIDTH - UNALIGNED_WIDTH,
    parameter ALIGNED_SIZE    = SIZE / STRB_WIDTH,

    parameter type ALIGNED_T = logic [ALIGNED_WIDTH-1:0]
) (
    ADAM_SEQ.Slave   seq,
    ADAM_PAUSE.Slave pause,

    AXI_LITE.Slave slv
);
          
    // phy ====================================================================
 
    // (* RAM_STYLE="BLOCK" *)
    DATA_T mem [ALIGNED_SIZE-1:0];

    ADDR_T addr;
    DATA_T wdata;
    STRB_T wstrb;
    DATA_T rdata;
    
    ALIGNED_T aligned;
    logic     valid_addr;

    assign aligned = addr[ADDR_WIDTH-1:UNALIGNED_WIDTH];
    assign valid_addr = (addr[UNALIGNED_WIDTH-1:0] == 0 || addr < SIZE);

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
    
    `ADAM_AXIL_I axil_pause ();
    `ADAM_AXIL_I skid ();

    adam_axil_pause #(
        `ADAM_CFG_PARAMS_MAP,

        .MAX_TRANS  (3)
    ) adam_axil_pause (
        .seq   (seq),
        .pause (pause),

        .slv (slv),
        .mst (axil_pause)
    );

    adam_axil_skid #(
        `ADAM_CFG_PARAMS_MAP,

        .BYPASS_B  (1),
        .BYPASS_R  (1)
    ) adam_axil_skid (
        .seq (seq),

        .slv (axil_pause),
        .mst (skid)
    );

    // axil logic =============================================================

    logic write;
    logic read;

    assign skid.r_data = rdata;

    always_comb begin

        // First, set default values

        skid.aw_ready = '0;
        skid.w_ready  = '0;
        skid.ar_ready = '0;

        addr  = '0;
        wstrb = '0;
        wdata = '0;

        // Then, make changes as required.  

        write = skid.aw_valid && skid.w_valid &&
            (!skid.b_valid || skid.b_ready);

        read = skid.ar_valid &&
            (!skid.r_valid || skid.r_ready);

        if (write) begin
            if (valid_addr) begin
                addr  = skid.aw_addr;
                wstrb = skid.w_strb;
                wdata = skid.w_data;
            end
            skid.aw_ready = 1;
            skid.w_ready  = 1;
        end
        else if (read) begin
            if (valid_addr) begin
                addr = skid.ar_addr;
            end
            skid.ar_ready = 1;
        end
    end

    always_ff @(posedge seq.clk) begin

        // First, set default values

        skid.b_resp  <= '0;
        skid.b_valid <= '0;
        skid.r_resp  <= '0;
        skid.r_valid <= '0;

        // Then, make changes as required. 

        if (seq.rst) begin
            // EMPTY
        end
        else if (write) begin
            if (!valid_addr) skid.b_resp <= axi_pkg::RESP_DECERR;
            skid.b_valid <= 1;
        end
        else if (read) begin
            if (!valid_addr) skid.r_resp <= axi_pkg::RESP_DECERR;
            // r_data has continuous assignment
            skid.r_valid <= 1; 
        end
        
    end

endmodule