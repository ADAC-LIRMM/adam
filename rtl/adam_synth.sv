module adam_synth #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32,
    parameter GPIO_WIDTH = 16,

    parameter NO_MEMS   = 5,
    parameter NO_GPIOS  = 4,
    parameter NO_SPIS   = 1,
    parameter NO_TIMERS = 1,
    parameter NO_UARTS  = 2,
    parameter NO_CPUS   = 1,
    parameter NO_LPUS   = 1,

    // Dependent parameters bellow, do not override.

    parameter PROT_WIDTH = 3,
    parameter STRB_WIDTH = DATA_WIDTH/8,
    parameter RESP_WIDTH = 2,

    parameter FUNC_WIDTH = 2
) (
    input logic clk,
    input logic rst,

    input  logic pause.req,
    output logic pause.ack,

    input logic [ADDR_WIDTH-1:0] rst_boot_addr,

    output logic [NO_MEMS-1:0] mem_srst,
    output logic [NO_MEMS-1:0] mem_pause.req,
    input  logic [NO_MEMS-1:0] mem_pause.ack,
    
    output logic [ADDR_WIDTH*NO_MEMS-1:0] mem_axil_aw_addr,
    output logic [PROT_WIDTH*NO_MEMS-1:0] mem_axil_aw_prot,
    output logic [NO_MEMS-1:0]            mem_axil_aw_valid,
    input  logic [NO_MEMS-1:0]            mem_axil_aw_ready,
    output logic [DATA_WIDTH*NO_MEMS-1:0] mem_axil_w_data,
    output logic [STRB_WIDTH*NO_MEMS-1:0] mem_axil_w_strb,
    output logic [NO_MEMS-1:0]            mem_axil_w_valid,
    input  logic [NO_MEMS-1:0]            mem_axil_w_ready,
    input  logic [RESP_WIDTH*NO_MEMS-1:0] mem_axil_b_resp,
    input  logic [NO_MEMS-1:0]            mem_axil_b_valid,
    output logic [NO_MEMS-1:0]            mem_axil_b_ready,
    output logic [ADDR_WIDTH*NO_MEMS-1:0] mem_axil_ar_addr,
    output logic [PROT_WIDTH*NO_MEMS-1:0] mem_axil_ar_prot,
    output logic [NO_MEMS-1:0]            mem_axil_ar_valid,
    input  logic [NO_MEMS-1:0]            mem_axil_ar_ready,
    input  logic [DATA_WIDTH*NO_MEMS-1:0] mem_axil_r_data,
    input  logic [RESP_WIDTH*NO_MEMS-1:0] mem_axil_r_resp,
    input  logic [NO_MEMS-1:0]            mem_axil_r_valid,
    output logic [NO_MEMS-1:0]            mem_axil_r_ready,

    input  logic [NO_GPIOS*GPIO_WIDTH-1:0] gpio_io_i,
    output logic [NO_GPIOS*GPIO_WIDTH-1:0] gpio_io_o,
    output logic [NO_GPIOS*GPIO_WIDTH-1:0] gpio_io_mode,
    output logic [NO_GPIOS*GPIO_WIDTH-1:0] gpio_io_otype,

    output logic [FUNC_WIDTH*NO_GPIOS*GPIO_WIDTH-1:0] gpio_func,
    
    input  logic [NO_SPIS-1:0] spi_sclk_i,
    output logic [NO_SPIS-1:0] spi_sclk_o,
    output logic [NO_SPIS-1:0] spi_sclk_mode,
    output logic [NO_SPIS-1:0] spi_sclk_otype,

    input  logic [NO_SPIS-1:0] spi_mosi_i,
    output logic [NO_SPIS-1:0] spi_mosi_o,
    output logic [NO_SPIS-1:0] spi_mosi_mode,
    output logic [NO_SPIS-1:0] spi_mosi_otype,

    input  logic [NO_SPIS-1:0] spi_miso_i,
    output logic [NO_SPIS-1:0] spi_miso_o,
    output logic [NO_SPIS-1:0] spi_miso_mode,
    output logic [NO_SPIS-1:0] spi_miso_otype,

    input  logic [NO_SPIS-1:0] spi_ss_n_i,
    output logic [NO_SPIS-1:0] spi_ss_n_o,
    output logic [NO_SPIS-1:0] spi_ss_n_mode,
    output logic [NO_SPIS-1:0] spi_ss_n_otype,

    input  logic [NO_UARTS-1:0] uart_tx_i,
    output logic [NO_UARTS-1:0] uart_tx_o,
    output logic [NO_UARTS-1:0] uart_tx_mode,
    output logic [NO_UARTS-1:0] uart_tx_otype,

    input  logic [NO_UARTS-1:0] uart_rx_i,
    output logic [NO_UARTS-1:0] uart_rx_o,
    output logic [NO_UARTS-1:0] uart_rx_mode,
    output logic [NO_UARTS-1:0] uart_rx_otype
);

    logic _mem_srst      [NO_MEMS];
    logic _mem_pause.req [NO_MEMS];
    logic _mem_pause.ack [NO_MEMS];
    
    AXI_LITE #(
        .AXI_ADDR_WIDTH (ADDR_WIDTH),
        .AXI_DATA_WIDTH (DATA_WIDTH)
    ) mem_axil [NO_MEMS] ();

    ADAM_IO                gpio_io    [GPIO_WIDTH*NO_GPIOS] ();
    logic [FUNC_WIDTH-1:0] _gpio_func [NO_GPIOS*GPIO_WIDTH];

    ADAM_IO spi_sclk [NO_SPIS] ();
    ADAM_IO spi_mosi [NO_SPIS] ();
    ADAM_IO spi_miso [NO_SPIS] ();
    ADAM_IO spi_ss_n [NO_SPIS] ();

    ADAM_IO uart_tx [NO_UARTS] ();
    ADAM_IO uart_rx [NO_UARTS] ();

    generate
        for (genvar i = 0; i < NO_MEMS; i++) begin
            assign mem_srst     [i] = _mem_srst[i];
            assign mem_pause[i].req = _mem_pause[i].req;
            
            assign _mem_pause[i].ack = mem_pause[i].ack;
            
            assign mem_axil_aw_addr[i*ADDR_WIDTH +: ADDR_WIDTH] =
                mem_axil[i].aw_addr;
            assign mem_axil_aw_prot[i*PROT_WIDTH +: PROT_WIDTH] =
                mem_axil[i].aw_prot;
            assign mem_axil_w_data[i*DATA_WIDTH +: DATA_WIDTH] =
                mem_axil[i].w_data;
            assign mem_axil_w_strb[i*STRB_WIDTH +: STRB_WIDTH] =
                mem_axil[i].w_strb;
            assign mem_axil_ar_addr[i*ADDR_WIDTH +: ADDR_WIDTH] =
                mem_axil[i].ar_addr;
            assign mem_axil_ar_prot[i*PROT_WIDTH +: PROT_WIDTH] =
                mem_axil[i].ar_prot;

            assign mem_axil_aw_valid[i] = mem_axil[i].aw_valid;
            assign mem_axil_w_valid [i] = mem_axil[i].w_valid;
            assign mem_axil_b_ready [i] = mem_axil[i].b_ready;
            assign mem_axil_ar_valid[i] = mem_axil[i].ar_valid;
            assign mem_axil_r_ready [i] = mem_axil[i].r_ready;

            assign mem_axil[i].b_resp =
                mem_axil_b_resp[i*RESP_WIDTH +: RESP_WIDTH];
            assign mem_axil[i].r_data =
                mem_axil_r_data[i*DATA_WIDTH +: DATA_WIDTH];
            assign mem_axil[i].r_resp =
                mem_axil_r_resp[i*RESP_WIDTH +: RESP_WIDTH];

            assign mem_axil[i].aw_ready = mem_axil_aw_ready[i];
            assign mem_axil[i].w_ready  = mem_axil_w_ready [i];
            assign mem_axil[i].b_valid  = mem_axil_b_valid [i];
            assign mem_axil[i].ar_ready = mem_axil_ar_ready[i];
            assign mem_axil[i].r_valid  = mem_axil_r_valid [i];
        end

        for (genvar i = 0; i < GPIO_WIDTH*NO_GPIOS; i++) begin
            assign gpio_io[i].i     = gpio_io_i[i];
            assign gpio_io_o    [i] = gpio_io[i].o;
            assign gpio_io_mode [i] = gpio_io[i].mode;
            assign gpio_io_otype[i] = gpio_io[i].otype; 

            assign gpio_func[i*FUNC_WIDTH +: FUNC_WIDTH] =
                _gpio_func[i];
        end

        for (genvar i = 0; i < NO_SPIS; i++) begin
            assign spi_sclk[i].i     = spi_sclk_i[i];
            assign spi_sclk_o    [i] = spi_sclk[i].o;
            assign spi_sclk_mode [i] = spi_sclk[i].mode;
            assign spi_sclk_otype[i] = spi_sclk[i].otype; 

            assign spi_mosi[i].i     = spi_mosi_i[i];
            assign spi_mosi_o    [i] = spi_mosi[i].o;
            assign spi_mosi_mode [i] = spi_mosi[i].mode;
            assign spi_mosi_otype[i] = spi_mosi[i].otype;

            assign spi_miso[i].i     = spi_miso_i[i];
            assign spi_miso_o    [i] = spi_miso[i].o;
            assign spi_miso_mode [i] = spi_miso[i].mode;
            assign spi_miso_otype[i] = spi_miso[i].otype; 

            assign spi_ss_n[i].i     = spi_ss_n_i[i];
            assign spi_ss_n_o    [i] = spi_ss_n[i].o;
            assign spi_ss_n_mode [i] = spi_ss_n[i].mode;
            assign spi_ss_n_otype[i] = spi_ss_n[i].otype;  
        end

        for (genvar i = 0; i < NO_UARTS; i++) begin
            assign uart_tx[i].i     = uart_tx_i[i];
            assign uart_tx_o    [i] = uart_tx[i].o;
            assign uart_tx_mode [i] = uart_tx[i].mode;
            assign uart_tx_otype[i] = uart_tx[i].otype;

            assign uart_rx[i].i     = uart_rx_i[i];
            assign uart_rx_o    [i] = uart_rx[i].o;
            assign uart_rx_mode [i] = uart_rx[i].mode;
            assign uart_rx_otype[i] = uart_rx[i].otype;
        end
    endgenerate

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
        .seq   (seq),
        .pause (pause),

        .rst_boot_addr (rst_boot_addr),

        .mem_srst      (_mem_srst),
        .mem_pause.req (_mem_pause.req),
        .mem_pause.ack (_mem_pause.ack),
        .mem_axil      (mem_axil),

        .gpio_func (_gpio_func),
        .gpio_io   (gpio_io),
        
        .spi_sclk (spi_sclk),
        .spi_mosi (spi_mosi),
        .spi_miso (spi_miso),
        .spi_ss_n (spi_ss_n),
        
        .uart_tx (uart_tx),
        .uart_rx (uart_rx)
    );

endmodule