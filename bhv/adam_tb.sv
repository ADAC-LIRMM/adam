`include "vunit_defines.svh"

module adam_tb;

    localparam ADDR_WIDTH = 32;
    localparam DATA_WIDTH = 32;
    localparam GPIO_WIDTH = 16;

    localparam NO_MEMS   = 3;
    localparam NO_GPIOS  = 4;
    localparam NO_SPIS   = 1;
    localparam NO_TIMERS = 1;
    localparam NO_UARTS  = 1;
    localparam NO_CPUS   = 1;
    localparam NO_LPUS   = 1;
    
    localparam integer MEM_SIZE [NO_MEMS] = 
        '{32768, 32768, 32768};

    localparam STRB_WIDTH = DATA_WIDTH/8;

    localparam CLK_PERIOD = 20ns;
    localparam RST_CYCLES = 5;

    localparam TA = 2ns;
    localparam TT = CLK_PERIOD - TA;

    logic clk;
    logic rst;
    logic test;
    
    logic pause_req;
    logic pause_ack;
    
    logic  mem_srst      [NO_MEMS];
	logic  mem_pause_req [NO_MEMS];
	logic  mem_pause_ack [NO_MEMS];
	
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

    assign test = 0;

    // TODO: implement pause
    assign pause_req = 0;

    assign uart_rx[0].i = uart_tx[0].o; // loopback
    
    adam_clk_rst_bhv #(
        .CLK_PERIOD (CLK_PERIOD),
        .RST_CYCLES (RST_CYCLES),

        .TA (TA),
        .TT (TT)
    ) adam_clk_rst_bhv (
        .clk (clk),
        .rst (rst)
    );

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
    ) dut (
        .clk  (clk),
        .rst  (rst),
        .test (test),

        .pause_req (pause_req),
        .pause_ack (pause_ack),

        .rst_boot_addr (32'h1000_0000),

        .mem_srst      (mem_srst),
        .mem_pause_req (mem_pause_req),
        .mem_pause_ack (mem_pause_ack),
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
            .clk  (clk),
            .rst  (rst || mem_srst[0]),
            .test (test),

            .pause_req (mem_pause_req[0]),
            .pause_ack (mem_pause_ack[0]),

            .axil (mem_axil[0])
        );

        for (genvar i = 1; i < NO_MEMS; i++) begin
            adam_axil_ram #(
                .ADDR_WIDTH (ADDR_WIDTH),
                .DATA_WIDTH (DATA_WIDTH),

                .SIZE (MEM_SIZE[i])
            ) adam_axil_ram (
                .clk  (clk),
                .rst  (rst || mem_srst[i]),
                .test (test),

                .pause_req (mem_pause_req[i]),
                .pause_ack (mem_pause_ack[i]),

                .axil (mem_axil[i])
            );
        end
    endgenerate
    
    `TEST_SUITE begin
        `TEST_CASE("test") begin
            //@(negedge uart_tx[0].o);
            #10us;
        end
    end

endmodule