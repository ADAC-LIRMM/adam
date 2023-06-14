module adam_basys3 (
    input  logic clk100,

    input  logic [15:0] sw,
    
    output logic [15:0] led,
    
    input  logic btn_c,
    input  logic btn_u,
    input  logic btn_l,
    input  logic btn_r,
    input  logic btn_d,

    output logic [7:0] header_ja,
    output logic [7:0] header_jb,
    output logic [7:0] header_jc,

    input  logic uart_rx,
    output logic uart_tx
);
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
    
    logic clk50;
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

    ADAM_IO uart_tx_io [NO_UARTS] ();
    ADAM_IO uart_rx_io [NO_UARTS] ();

    logic [3:0] counter = 4'b1111;

    assign test = 0;
    assign pause_req = 0;

    adam_clk_div #(
        .WIDTH (1)
    ) adam_clk_div (
        .in  (clk100),
        .out (clk50)
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
    ) adam (
        .clk  (clk50),
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
        
        .uart_tx (uart_tx_io),
        .uart_rx (uart_rx_io)
    );
    
    generate 
        bootloader bootloader (
            .clk  (clk50),
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
                .clk  (clk50),
                .rst  (rst || mem_srst[i]),
                .test (test),

                .pause_req (mem_pause_req[i]),
                .pause_ack (mem_pause_ack[i]),

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
        uart_tx = uart_tx_io[0].o;
        uart_rx_io[0].i = uart_rx;
    end

    always_ff @(posedge clk50) begin
        if (btn_c) begin
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