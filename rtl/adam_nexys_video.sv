`include "adam/macros.svh"

module adam_nexys_video (
    input  logic clk,

    output logic [7:0] led,

    input  logic btnc,
    input  logic btnd,
    input  logic btnl,
    input  logic btnr,
    input  logic btnu,
    input  logic cpu_resetn,

    input  logic [7:0] sw,
    
    output logic ja1,
    output logic ja2,
    input  logic ja3,
    output logic ja4,
    output logic [7:4] ja,

    output logic [7:0] jb,
    output logic [7:0] jc,

    output logic uart_rx_out,
    input  logic uart_tx_in,

    input  logic jtag_trst_n,
    input  logic jtag_tck,
    input  logic jtag_tms,
    input  logic jtag_tdi,
    output logic jtag_tdo
);
    
    `ADAM_CFG_LOCALPARAMS;
    
    localparam integer LPMEM_SIZE = 1024;

    localparam integer MEM_SIZE [NO_MEMS+1] = 
        '{32768, 524288, 524288, 0};

    // seq ====================================================================

    logic clk50;
    logic rst;

    ADAM_SEQ src_seq   ();
    ADAM_SEQ lsdom_seq ();
    ADAM_SEQ hsdom_seq ();

    assign src_seq.clk = clk;
    assert src_seq.rst = btnc;

    adam_clk_div #(
        .WIDTH (1)
    ) adam_clk_div (
        .slv (src_seq),
        .mst (lsdom_seq)
    );

    adam_clk_div #(
        .WIDTH (1)
    ) adam_clk_div (
        .slv (src_seq),
        .mst (hsdom_seq)
    );

    lsdom_seq.



    ADAM_PAUSE lsdom_pause_ext ();

    `ADAM_PAUSE_MST_TIE_ON(lsdom_pause_ext);

    logic clk50;
    logic rst;
    
    logic pause.req;
    logic pause.ack;
    
    logic  mem_srst      [NO_MEMS];
    logic  mem_pause.req [NO_MEMS];
    logic  mem_pause.ack [NO_MEMS];
    
    AXI_LITE #(
        .AXI_ADDR_WIDTH (ADDR_WIDTH),
        .AXI_DATA_WIDTH (DATA_WIDTH)
    ) mem_axil [NO_MEMS] ();

    logic [1:0] gpio_func [NO_GPIOS*GPIO_WIDTH];
    ADAM_IO     gpio_io   [NO_GPIOS*GPIO_WIDTH] ();

    ADAM_IO spi_sclk [NO_SPIS] ();
    ADAM_IO spi_mosi [NO_SPIS] ();
    ADAM_IO spi_miso [NO_SPIS] ();
    ADAM_IO spi_ss_n [NO_SPIS] ();

    ADAM_IO uart_tx [NO_UARTS] ();
    ADAM_IO uart_rx [NO_UARTS] ();

    logic [3:0] counter = 4'b1111;

    assign pause.req = 0;

    

    adam #(
        .ADDR_WIDTH (ADDR_WIDTH),
        .DATA_WIDTH (DATA_WIDTH),
        .GPIO_WIDTH (GPIO_WIDTH),

        .NO_MEMS   (NO_MEMS),
        .NO_GPIOS  (NO_GPIOS),
        .NO_SPIS   (NO_SPIS),
        .NO_TIMERS (NO_TIMERS),
        .NO_UARTS  (NO_UARTS),
        .NO_CPUS   (NO_CPUS),
        .NO_LPUS   (NO_LPUS)
    ) adam (
        .clk  (clk50),
        .rst  (rst),

        .pause (pause),

        .rst_boot_addr (32'h1000_0000),

        .mem_srst      (mem_srst),
        .mem_pause (mem_pause),
        .mem_axil      (mem_axil),

        .gpio_func (gpio_func),
        .gpio_io   (gpio_io),
        
        .spi_sclk (spi_sclk),
        .spi_mosi (spi_mosi),
        .spi_miso (spi_miso),
        .spi_ss_n (spi_ss_n),
        
        .uart_tx (uart_tx),
        .uart_rx (uart_rx)
    );
    
    generate 
        bootloader bootloader (
            .clk  (clk50),
            .rst  (rst), // || mem_srst[0]

            .pause.req (mem_pause.req[0]),
            .pause.ack (mem_pause.ack[0]),

            .axil (mem_axil[0])
        );

        for (genvar i = 1; i < NO_MEMS; i++) begin
            adam_axil_ram #(
                .ADDR_WIDTH (ADDR_WIDTH),
                .DATA_WIDTH (DATA_WIDTH),

                .SIZE (MEM_SIZE[i])
            ) adam_axil_ram (
                .clk  (clk50),
                .rst  (rst), // || mem_srst[i]

                .pause.req (mem_pause[i].req),
                .pause.ack (mem_pause[i].ack),

                .axil (mem_axil[i])
            );
        end
    endgenerate

    generate
        for (genvar i = 0; i < 16; i++) begin
            always_comb begin
                led[i] = gpio_io[i].o;
                gpio_io[16+i].i = sw[i];
            end
        end
    endgenerate

    always_comb begin
        uart_rx_out = uart_tx[0].o;
        uart_rx[0].i = uart_tx_in;
    end

    always_comb begin
        ja1 = spi_ss_n[0].o;
        spi_miso[0].i = ja3;
        ja4 = spi_sclk[0].o;
    end

    always_ff @(posedge clk50) begin
        if (!cpu_resetn) begin
            counter <= 0;
            rst <= 1;
        end
        else begin
            if (counter == 4'b1111) begin
                rst <= 0;
            end
            else begin
                counter <= counter + 1;
            end
        end
    end

endmodule