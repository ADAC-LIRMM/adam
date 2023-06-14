module adam_power_tb;

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
    
    localparam integer MEM_SIZE [NO_MEMS] = '{32768, 32768, 32768};
    
    localparam BOOT_ADDR = 32'h1100_0000;
    localparam BAUD_RATE = 1000000;

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
    
    logic [ADDR_WIDTH-1:0] rst_boot_addr;

    logic mem_srst      [NO_MEMS];
	logic mem_pause_req [NO_MEMS];
	logic mem_pause_ack [NO_MEMS];
	
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

    assign test          = 0;
    assign pause_req     = 0;
    assign rst_boot_addr = BOOT_ADDR;

    generate
        for (genvar i = 0; i < NO_GPIOS; i++) begin
            assign gpio_io[i].i = 0;
        end

        for (genvar i = 0; i < NO_SPIS; i++) begin
            assign spi_sclk[i].i = 0;
            assign spi_mosi[i].i = 0;
            assign spi_miso[i].i = 0;
            assign spi_ss_n[i].i = 0;
        end

        for (genvar i = 0; i < NO_UARTS; i++) begin
            assign uart_tx[i].i = 0;
            assign uart_rx[i].i = 0;
        end
    endgenerate

    adam_clk_rst_bhv #(
        .CLK_PERIOD (CLK_PERIOD),
        .RST_CYCLES (RST_CYCLES),

        .TA (TA),
        .TT (TT)
    ) adam_clk_rst_bhv (
        .clk (clk),
        .rst (rst)
    );

    adam_power_intf adam_power_intf (
        .clk  (clk),
        .rst  (rst),
        .test (test),

        .pause_req (pause_req),
        .pause_ack (pause_ack),

        .rst_boot_addr (rst_boot_addr),

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
            .rst  (rst), // ignores soft reset
            .test (test),

            .pause_req (mem_pause_req[0]),
            .pause_ack (mem_pause_ack[0]),

            .axil (mem_axil[0])
        );

        coremark coremark (
            .clk  (clk),
            .rst  (rst), // ignores soft reset
            .test (test),

            .pause_req (mem_pause_req[1]),
            .pause_ack (mem_pause_ack[1]),

            .axil (mem_axil[1])
        );

        for (genvar i = 2; i < NO_MEMS; i++) begin
            adam_axil_ram #(
                .ADDR_WIDTH (ADDR_WIDTH),
                .DATA_WIDTH (DATA_WIDTH),

                .SIZE (MEM_SIZE[i])
            ) adam_axil_ram (
                .clk  (clk),
                .rst  (rst), // || mem_srst[i]),
                .test (test),

                .pause_req (mem_pause_req[i]),
                .pause_ack (mem_pause_ack[i]),

                .axil (mem_axil[i])
            );
        end
    endgenerate

    logic rx;

    assign rx = uart_tx[0].o;

    initial begin
        automatic int uart_file;
        automatic logic [7:0] data; 
        
        uart_file = $fopen("uart.txt", "w");

        assert (uart_file) else $finish(1); 

        @(negedge rst);
        @(posedge clk);

        forever begin
            @(negedge rx);
            #(1.5s / BAUD_RATE);

            for (int i = 0; i < 8; i++) begin
                data[i] = rx;
                #(1s / BAUD_RATE);
            end

            $fwrite(uart_file, "%c", data);
            $fflush(uart_file);
        end

        $fclose(uart_file);
    end

    initial begin
        #1us;
        $stop();
    end

endmodule
