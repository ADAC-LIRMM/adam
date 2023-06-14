module adam_power_flow (
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

    localparam NO_CORES   =  2;
    localparam NO_MEMS    =  3;
    localparam NO_GPIOS   =  4;
    localparam NO_SPIS    =  4;
    localparam NO_TIMERS  =  4;
    localparam NO_UARTS   =  4;

    logic clk50;
    logic pwron;
    logic rst_n;

    logic [3:0] counter;

    IO          gpio_io   [GPIO_WIDTH*NO_GPIOS] ();
    logic [1:0] gpio_func [GPIO_WIDTH*NO_GPIOS];

    IO spi_sclk [NO_SPIS] ();
    IO spi_mosi [NO_SPIS] ();
    IO spi_miso [NO_SPIS] ();
    IO spi_ss_n [NO_SPIS] ();

    IO uart_tx_io [NO_UARTS] ();
    IO uart_rx_io [NO_UARTS] ();

    mcu #(
        .ADDR_WIDTH (ADDR_WIDTH),
        .DATA_WIDTH (DATA_WIDTH),
        .GPIO_WIDTH (GPIO_WIDTH),

        .NO_CORES  (NO_CORES),
        .NO_MEMS   (NO_MEMS),
        .NO_GPIOS  (NO_GPIOS),
        .NO_SPIS   (NO_SPIS),
        .NO_TIMERS (NO_TIMERS),
        .NO_UARTS  (NO_UARTS)
    ) uut (
        .clk  (clk50),
        .hrst (!rst_n),

        .gpio_io   (gpio_io),
        .gpio_func (gpio_func),
        
        .spi_sclk (spi_sclk),
        .spi_mosi (spi_mosi),
        .spi_miso (spi_miso),
        .spi_ss_n (spi_ss_n),
        
        .uart_tx (uart_tx_io),
        .uart_rx (uart_rx_io)
    );
    
    simple_clk_div #(
        .WIDTH (1)
    ) simple_clk_div (
        .clk_in  (clk100),
        .clk_out (clk50)
    );

    generate
        for (genvar i = 0; i < 16; i++) begin
            always_comb begin
                led[i] = gpio_io[i].o;
                gpio_io[i+16].i = sw[i];
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
            rst_n <= 0;
        end
        else begin
            if (counter == 4'b1111) begin
                rst_n <= 1;
            end
            else begin
                counter <= counter + 1;
            end
        end
    end

endmodule