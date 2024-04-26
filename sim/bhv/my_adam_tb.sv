`timescale 1ns/1ps
`include "adam/macros_bhv.svh"
`include "adam/macros.svh"
// `include "vunit_defines.svh"

module my_adam_tb;
    import adam_jtag_mst_bhv::*;

    `ADAM_BHV_CFG_LOCALPARAMS;
    localparam integer LPMEM_SIZE = 1024;

    localparam integer MEM_SIZE [NO_MEMS+1] = 
        '{524288, 524288, 0};

    // seq and pause ==========================================================

    ADAM_SEQ lsdom_seq ();
    ADAM_SEQ hsdom_seq ();

    ADAM_PAUSE lsdom_pause_ext ();

    adam_seq_bhv #(
        `ADAM_BHV_CFG_PARAMS_MAP
    ) lsdom_adam_seq_bhv (
        .seq (lsdom_seq)
    );

    adam_seq_bhv #(
        `ADAM_BHV_CFG_PARAMS_MAP
    ) hsdom_adam_seq_bhv (
        .seq (hsdom_seq)
    );

    `ADAM_PAUSE_MST_TIE_ON(lsdom_pause_ext);

    // lpmem ==================================================================

    logic        lsdom_lpmem_rst;
    ADAM_SEQ     lsdom_lpmem_seq ();
    ADAM_PAUSE   lsdom_lpmem_pause ();
    `ADAM_AXIL_I lsdom_lpmem_axil ();

    logic  lsdom_lpmem_req;
    ADDR_T lsdom_lpmem_addr;
    logic  lsdom_lpmem_we;
    STRB_T lsdom_lpmem_be;
    DATA_T lsdom_lpmem_wdata;
    DATA_T lsdom_lpmem_rdata;

    assign lsdom_lpmem_seq.clk = lsdom_seq.clk;
    assign lsdom_lpmem_seq.rst = lsdom_seq.rst || lsdom_lpmem_rst;

    if (EN_LPMEM) begin
        adam_mem #(
            `ADAM_CFG_PARAMS_MAP,

            .SIZE (LPMEM_SIZE))
         adam_mem (
            .seq (lsdom_lpmem_seq),

            .req   (lsdom_lpmem_req),
            .addr  (lsdom_lpmem_addr),
            .we    (lsdom_lpmem_we),
            .be    (lsdom_lpmem_be),
            .wdata (lsdom_lpmem_wdata),
            .rdata (lsdom_lpmem_rdata)
        );
    end
    else begin
        // TODO: tie off
    end

    // mem ====================================================================
    
    logic        hsdom_mem_rst   [NO_MEMS+1];
    ADAM_SEQ     hsdom_mem_seq   [NO_MEMS+1] ();
    ADAM_PAUSE   hsdom_mem_pause [NO_MEMS+1] ();
    
    logic  hsdom_mem_req   [NO_MEMS+1];
    ADDR_T hsdom_mem_addr  [NO_MEMS+1];
    logic  hsdom_mem_we    [NO_MEMS+1];
    STRB_T hsdom_mem_be    [NO_MEMS+1];
    DATA_T hsdom_mem_wdata [NO_MEMS+1];
    DATA_T hsdom_mem_rdata [NO_MEMS+1];


    for (genvar i = 0; i < NO_MEMS; i++) begin
        assign hsdom_mem_seq[i].clk = lsdom_seq.clk;
        assign hsdom_mem_seq[i].rst = lsdom_seq.rst || hsdom_mem_rst[i];
    end

    instr_rom #(
        `ADAM_CFG_PARAMS_MAP
    ) instr_rom (
        .seq (hsdom_mem_seq[0]),

        .req   (hsdom_mem_req[0]),
        .addr  (hsdom_mem_addr[0]),
        .we    (hsdom_mem_we[0]),
        .be    (hsdom_mem_be[0]),
        .wdata (hsdom_mem_wdata[0]),
        .rdata (hsdom_mem_rdata[0])
    );

    for (genvar i = 1; i < NO_MEMS; i++) begin
        adam_mem#(
            `ADAM_CFG_PARAMS_MAP,

            .SIZE (MEM_SIZE[i])
        ) 
        adam_mem (
            .seq (hsdom_mem_seq[i]),

            .req   (hsdom_mem_req[i]),
            .addr  (hsdom_mem_addr[i]),
            .we    (hsdom_mem_we[i]),
            .be    (hsdom_mem_be[i]),
            .wdata (hsdom_mem_wdata[i]),
            .rdata (hsdom_mem_rdata[i])
        );
    end
    
    // lspa io ================================================================

    ADAM_IO     lspa_gpio_io   [NO_LSPA_GPIOS*GPIO_WIDTH+1] ();
    logic [1:0] lspa_gpio_func [NO_LSPA_GPIOS*GPIO_WIDTH+1];

    ADAM_IO lspa_spi_sclk [NO_LSPA_SPIS+1] ();
    ADAM_IO lspa_spi_mosi [NO_LSPA_SPIS+1] ();
    ADAM_IO lspa_spi_miso [NO_LSPA_SPIS+1] ();
    ADAM_IO lspa_spi_ss_n [NO_LSPA_SPIS+1] ();

    ADAM_IO lspa_uart_tx [NO_LSPA_UARTS+1] ();
    ADAM_IO lspa_uart_rx [NO_LSPA_UARTS+1] ();

    for (genvar i = 0; i < NO_LSPA_GPIOS; i++) begin
        `ADAM_IO_SLV_TIE_OFF(lspa_gpio_io[i]);
    end
    for (genvar i = 0; i < NO_LSPA_SPIS; i++) begin
        `ADAM_IO_SLV_TIE_OFF(lspa_spi_sclk[i]);
        `ADAM_IO_SLV_TIE_OFF(lspa_spi_mosi[i]);
        `ADAM_IO_SLV_TIE_OFF(lspa_spi_miso[i]);
        `ADAM_IO_SLV_TIE_OFF(lspa_spi_ss_n[i]);
    end
    for (genvar i = 0; i < NO_LSPA_UARTS; i++) begin
        `ADAM_IO_SLV_TIE_OFF(lspa_uart_tx[i]);
        `ADAM_IO_SLV_TIE_OFF(lspa_uart_rx[i]);
    end

    // lspb io ================================================================

    ADAM_IO     lspb_gpio_io   [NO_LSPB_GPIOS*GPIO_WIDTH+1] ();
    logic [1:0] lspb_gpio_func [NO_LSPB_GPIOS*GPIO_WIDTH+1];

    ADAM_IO lspb_spi_sclk [NO_LSPB_SPIS+1] ();
    ADAM_IO lspb_spi_mosi [NO_LSPB_SPIS+1] ();
    ADAM_IO lspb_spi_miso [NO_LSPB_SPIS+1] ();
    ADAM_IO lspb_spi_ss_n [NO_LSPB_SPIS+1] ();

    ADAM_IO lspb_uart_tx [NO_LSPB_UARTS+1] ();
    ADAM_IO lspb_uart_rx [NO_LSPB_UARTS+1] ();

    for (genvar i = 0; i < NO_LSPB_GPIOS; i++) begin
        `ADAM_IO_SLV_TIE_OFF(lspb_gpio_io[i]);
    end
    for (genvar i = 0; i < NO_LSPB_SPIS; i++) begin
        `ADAM_IO_SLV_TIE_OFF(lspb_spi_sclk[i]);
        `ADAM_IO_SLV_TIE_OFF(lspb_spi_mosi[i]);
        `ADAM_IO_SLV_TIE_OFF(lspb_spi_miso[i]);
        `ADAM_IO_SLV_TIE_OFF(lspb_spi_ss_n[i]);
    end
    for (genvar i = 0; i < NO_LSPB_UARTS; i++) begin
        `ADAM_IO_SLV_TIE_OFF(lspb_uart_tx[i]);
        `ADAM_IO_SLV_TIE_OFF(lspb_uart_rx[i]);
    end

    // debug ==================================================================

    ADAM_JTAG jtag ();

    adam_jtag_mst_bhv #(
        `ADAM_BHV_CFG_PARAMS_MAP
    ) jtag_bhv;

    // dut ====================================================================

    adam_wrap# (
        `ADAM_CFG_PARAMS_MAP
    ) dut (
        .lsdom_seq (lsdom_seq),

        .lsdom_lpmem_req    (lsdom_lpmem_req  ),
        .lsdom_lpmem_addr   (lsdom_lpmem_addr ),
        .lsdom_lpmem_we     (lsdom_lpmem_we   ),
        .lsdom_lpmem_be     (lsdom_lpmem_be   ),
        .lsdom_lpmem_wdata  (lsdom_lpmem_wdata),
        .lsdom_lpmem_rdata  (lsdom_lpmem_rdata),

        .hsdom_seq       (hsdom_seq),
        .hsdom_mem_req   (hsdom_mem_req  ),
        .hsdom_mem_addr  (hsdom_mem_addr ),
        .hsdom_mem_we    (hsdom_mem_we   ),
        .hsdom_mem_be    (hsdom_mem_be   ),
        .hsdom_mem_wdata (hsdom_mem_wdata),
        .hsdom_mem_rdata (hsdom_mem_rdata),
        
        .jtag (jtag),

        .lspa_gpio_io   (lspa_gpio_io),
        .lspa_gpio_func (lspa_gpio_func),

        .lspa_spi_sclk (lspa_spi_sclk),
        .lspa_spi_mosi (lspa_spi_mosi),
        .lspa_spi_miso (lspa_spi_miso),
        .lspa_spi_ss_n (lspa_spi_ss_n),

        .lspa_uart_tx (lspa_uart_tx),
        .lspa_uart_rx (lspa_uart_rx),
        
        .lspb_gpio_io   (lspb_gpio_io),
        .lspb_gpio_func (lspb_gpio_func),

        .lspb_spi_sclk (lspb_spi_sclk),
        .lspb_spi_mosi (lspb_spi_mosi),
        .lspb_spi_miso (lspb_spi_miso),
        .lspb_spi_ss_n (lspb_spi_ss_n),

        .lspb_uart_tx (lspb_uart_tx),
        .lspb_uart_rx (lspb_uart_rx)
    );

    // test ===================================================================
    task automatic mem_rw_cnt(input string file_csv, input logic req, input logic we, input STRB_T be, input string mem_name);
        automatic int nb_bytes = 0;
        automatic int fd;
        fd = $fopen(file_csv, "a");
        @(posedge hsdom_seq.clk);
            if (req && !we) begin
                nb_bytes = 4;
                $fdisplay(fd, "%s;read;%d;%t", mem_name, nb_bytes, $time);
            end
            else if (req && we) begin
                nb_bytes = $countones(be);
                $fdisplay(fd, "%s;write;%d;%t", mem_name, nb_bytes,  $time);
            end 
    $fclose(fd);

    endtask //automatic

    initial 
    begin
        // Create a CSV file with {Memory, Operation, #bytes, #reads, #writes, time}
        int fd1;
        int fd2;
        fd1 = $fopen("/scratch/k-romdhane/mem_ops/setup_instr_mem_rw.csv", "w");
        $fdisplay(fd1, "Memory;Operation;#bytes;time(ns)");
        $fclose(fd1);
        fd2 = $fopen("/scratch/k-romdhane/mem_ops/setup_data_mem_rw.csv", "w");
        $fdisplay(fd2, "Memory;Operation;#bytes;time(ns)");
        $fclose(fd2);
        // Add 1 ms delay before starting to save
        #1000000
        forever 
        begin
            fork
                mem_rw_cnt("/scratch/k-romdhane/mem_ops/setup_instr_mem_rw.csv",hsdom_mem_req[0], hsdom_mem_we[0], hsdom_mem_be[0], "instr_rom");
                mem_rw_cnt("/scratch/k-romdhane/mem_ops/setup_data_mem_rw.csv",hsdom_mem_req[1], hsdom_mem_we[1], hsdom_mem_be[1], "data_mem");
            join
        end
    end
endmodule
