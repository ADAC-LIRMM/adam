`timescale 1ns/1ps
`include "adam/macros_bhv.svh"
`include "vunit_defines.svh"

module adam_tb;
    import adam_jtag_mst_bhv::*;

    `ADAM_BHV_CFG_LOCALPARAMS;
    
    localparam integer LPMEM_SIZE = 1024;

    localparam integer MEM_SIZE [NO_MEMS+1] = 
        '{32768, 32768, 32768, 0};

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

    assign lsdom_lpmem_seq.clk = lsdom_seq.clk;
    assign lsdom_lpmem_seq.rst = lsdom_seq.rst || lsdom_lpmem_rst;

    adam_axil_ram #(
        `ADAM_CFG_PARAMS_MAP,

        .SIZE (LPMEM_SIZE)
    ) adam_axil_ram (
        .seq   (lsdom_lpmem_seq),
        .pause (lsdom_lpmem_pause),

        .slv (lsdom_lpmem_axil)
    );

    // mem ====================================================================
    
    logic        hsdom_mem_rst   [NO_MEMS+1];
    ADAM_SEQ     hsdom_mem_seq   [NO_MEMS+1] ();
    ADAM_PAUSE   hsdom_mem_pause [NO_MEMS+1] ();
    `ADAM_AXIL_I hsdom_mem_axil  [NO_MEMS+1] ();

    for (genvar i = 0; i < NO_MEMS; i++) begin
        assign hsdom_mem_seq[i].clk = lsdom_seq.clk;
        assign hsdom_mem_seq[i].rst = lsdom_seq.rst || hsdom_mem_rst[i];
    end

    bootloader bootloader (
        .clk   (hsdom_mem_seq[0].clk),
        .rst   (lsdom_seq.rst),
        
        .pause_req (hsdom_mem_pause[0].req),
        .pause_ack (hsdom_mem_pause[0].ack),

        .slv (hsdom_mem_axil[0])
    );

    for (genvar i = 1; i < NO_MEMS; i++) begin
        adam_axil_ram #(
            `ADAM_CFG_PARAMS_MAP,

            .SIZE (MEM_SIZE[i])
        ) adam_axil_ram (
            .seq   (hsdom_mem_seq[i]),
            .pause (hsdom_mem_pause[i]),

            .slv (hsdom_mem_axil[i])
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

    adam #(
        `ADAM_CFG_PARAMS_MAP
    ) dut (
        .lsdom_seq (lsdom_seq),

        .lsdom_pause_ext  (lsdom_pause_ext),

        .lsdom_lpmem_rst   (lsdom_lpmem_rst),
        .lsdom_lpmem_pause (lsdom_lpmem_pause),
        .lsdom_lpmem_axil  (lsdom_lpmem_axil),

        .hsdom_seq       (hsdom_seq),

        .hsdom_mem_rst   (hsdom_mem_rst),
        .hsdom_mem_pause (hsdom_mem_pause),
        .hsdom_mem_axil  (hsdom_mem_axil),
        
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

    localparam ID_WIDTH = 5;
    
    localparam IDLE  = 1;
    localparam ABITS = 7;

    localparam type DMI_ADDR_T = logic[ABITS-1:0];
    localparam type DMI_DATA_T = logic[31:0];

    localparam DMCONTROL = 'h10;
    localparam DMSTATUS  = 'h11;

    `TEST_SUITE begin
        `TEST_CASE("test") begin
            jtag_bhv = new(jtag);

            #10us;
        end
        `TEST_CASE("debug") begin
            logic [31:0] idcode;
            logic [31:0] dtmcs;
            DMI_DATA_T   data;

            jtag_bhv = new(jtag);

            if (EN_DEBUG) begin
                jtag_bhv.reset();
                jtag_bhv.tap_reset();

                jtag_bhv.tap_reg_read('h01, 5, idcode, 32);
                assert(idcode == DEBUG_IDCODE);

                jtag_bhv.tap_reg_read('h10, 5, dtmcs, 32);
                assert(dtmcs[9:4] == ABITS);
                assert(dtmcs[14:12] == IDLE);
                
                debug_init();          
                debug_select('b1 << 1); // HART 1 aka CPU0
                
                $error (0);
            end
        end
    end

    initial begin
        #10000us $error("timeout");
    end

    task debug_init();
        debug_write('h10, '1); // set dmactive at dmcontrol
    endtask

    task debug_select(
        input [19:0] hartsel
    );
        DMI_DATA_T dmcontrol;

        debug_read(DMCONTROL, dmcontrol);

        dmcontrol[25: 6] = hartsel;
        debug_write(DMCONTROL, dmcontrol);

        debug_read(DMCONTROL, dmcontrol);
        assert(dmcontrol[25:6] == hartsel);
    endtask

    task debug_halt();
        // DMI_DATA_T dmcontrol;

        // debug_read(DMCONTROL, dmcontrol);

        // dmcontrol[31] = '1;
        // debug_write(DMCONTROL, dmcontrol);

        // debug_read(DMCONTROL, dmcontrol);
        // assert(dmcontrol[25:6] == hartsel);
    endtask

    task debug_read(
        input  DMI_ADDR_T addr,
        output DMI_DATA_T data 
    );
        logic [31:0] idcode;
        logic [ABITS+33:0] dmi;
        
        dmi[1:0] = 'd1;
        dmi[33:2] = '0; 
        dmi[ABITS+33:34] = addr;
        jtag_bhv.tap_reg_write('h11, 5, dmi, ABITS+34);
        
        repeat (IDLE-1) jtag_bhv.tap_nop();
        
        jtag_bhv.tap_reg_read('h11, 5, dmi, ABITS+34);
        assert(dmi[1:0] == '0);
        data = dmi[31:2];
    endtask

    task debug_write(
        input DMI_ADDR_T addr,
        input DMI_DATA_T data 
    );
        logic [31:0] idcode;
        logic [ABITS+33:0] dmi;
        
        dmi[1:0] = 'd2;
        dmi[33:2] = data; 
        dmi[ABITS+33:34] = addr;
        jtag_bhv.tap_reg_write('h11, 5, dmi, ABITS+34);
        
        repeat (IDLE-1) jtag_bhv.tap_nop();
        
        jtag_bhv.tap_reg_read ('h11, 5, dmi, ABITS+34);
        assert(!dmi[1:0]);
    endtask

endmodule
