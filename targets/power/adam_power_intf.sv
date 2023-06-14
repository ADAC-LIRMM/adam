module adam_power_intf #(
	parameter ADDR_WIDTH = 32,
	parameter DATA_WIDTH = 32,
	parameter GPIO_WIDTH = 16,

	parameter NO_MEMS   = 3,
    parameter NO_GPIOS  = 4,
    parameter NO_SPIS   = 1,
    parameter NO_TIMERS = 1,
    parameter NO_UARTS  = 1,

	// Dependent parameters below, do not override.

	parameter PROT_WIDTH = 3,
	parameter STRB_WIDTH = DATA_WIDTH/8,
    parameter RESP_WIDTH = 2,

    parameter FUNC_WIDTH = 2,
	
	parameter type addr_t = logic [ADDR_WIDTH-1:0],
    parameter type prot_t = logic [2:0],
    parameter type data_t = logic [DATA_WIDTH-1:0],
    parameter type strb_t = logic [STRB_WIDTH-1:0],
    parameter type resp_t = logic [1:0],

    parameter type func_t = logic [1:0]
) (
	input logic clk,
	input logic rst,
	input logic test,

	input  logic pause_req,
	output logic pause_ack,
	
    input addr_t rst_boot_addr,
	
    output logic    mem_srst      [NO_MEMS],
	output logic    mem_pause_req [NO_MEMS],
	input  logic    mem_pause_ack [NO_MEMS],
	AXI_LITE.Master mem_axil      [NO_MEMS],
	
    ADAM_IO.Master     gpio_io   [NO_GPIOS*GPIO_WIDTH],
	output logic [1:0] gpio_func [NO_GPIOS*GPIO_WIDTH],
    
    ADAM_IO.Master spi_sclk [NO_SPIS],
    ADAM_IO.Master spi_mosi [NO_SPIS],
    ADAM_IO.Master spi_miso [NO_SPIS],
    ADAM_IO.Master spi_ss_n [NO_SPIS],
    
    ADAM_IO.Master uart_tx [NO_UARTS],
    ADAM_IO.Master uart_rx [NO_UARTS]
);

	logic [NO_MEMS-1:0] _mem_srst;
	logic [NO_MEMS-1:0] _mem_pause_req;
	logic [NO_MEMS-1:0] _mem_pause_ack;
	
    logic [ADDR_WIDTH*NO_MEMS-1:0] mem_axil_aw_addr;
    logic [PROT_WIDTH*NO_MEMS-1:0] mem_axil_aw_prot;
    logic [NO_MEMS-1:0]            mem_axil_aw_valid;
    logic [NO_MEMS-1:0]            mem_axil_aw_ready;
    logic [DATA_WIDTH*NO_MEMS-1:0] mem_axil_w_data;
    logic [STRB_WIDTH*NO_MEMS-1:0] mem_axil_w_strb;
    logic [NO_MEMS-1:0]            mem_axil_w_valid;
    logic [NO_MEMS-1:0]            mem_axil_w_ready;
    logic [RESP_WIDTH*NO_MEMS-1:0] mem_axil_b_resp;
    logic [NO_MEMS-1:0]            mem_axil_b_valid;
    logic [NO_MEMS-1:0]            mem_axil_b_ready;
    logic [ADDR_WIDTH*NO_MEMS-1:0] mem_axil_ar_addr;
    logic [PROT_WIDTH*NO_MEMS-1:0] mem_axil_ar_prot;
    logic [NO_MEMS-1:0]            mem_axil_ar_valid;
    logic [NO_MEMS-1:0]            mem_axil_ar_ready;
    logic [DATA_WIDTH*NO_MEMS-1:0] mem_axil_r_data;
    logic [RESP_WIDTH*NO_MEMS-1:0] mem_axil_r_resp;
    logic [NO_MEMS-1:0]            mem_axil_r_valid;
    logic [NO_MEMS-1:0]            mem_axil_r_ready;

	logic [NO_GPIOS*GPIO_WIDTH-1:0] gpio_io_i;
    logic [NO_GPIOS*GPIO_WIDTH-1:0] gpio_io_o;
    logic [NO_GPIOS*GPIO_WIDTH-1:0] gpio_io_mode;
    logic [NO_GPIOS*GPIO_WIDTH-1:0] gpio_io_otype;

	logic [FUNC_WIDTH*NO_GPIOS*GPIO_WIDTH-1:0] _gpio_func;
    
    logic [NO_SPIS-1:0] spi_sclk_i;
    logic [NO_SPIS-1:0] spi_sclk_o;
    logic [NO_SPIS-1:0] spi_sclk_mode;
    logic [NO_SPIS-1:0] spi_sclk_otype;

    logic [NO_SPIS-1:0] spi_mosi_i;
    logic [NO_SPIS-1:0] spi_mosi_o;
    logic [NO_SPIS-1:0] spi_mosi_mode;
    logic [NO_SPIS-1:0] spi_mosi_otype;

    logic [NO_SPIS-1:0] spi_miso_i;
    logic [NO_SPIS-1:0] spi_miso_o;
    logic [NO_SPIS-1:0] spi_miso_mode;
    logic [NO_SPIS-1:0] spi_miso_otype;

    logic [NO_SPIS-1:0] spi_ss_n_i;
    logic [NO_SPIS-1:0] spi_ss_n_o;
    logic [NO_SPIS-1:0] spi_ss_n_mode;
    logic [NO_SPIS-1:0] spi_ss_n_otype;

    logic [NO_SPIS-1:0] uart_tx_i;
    logic [NO_SPIS-1:0] uart_tx_o;
    logic [NO_SPIS-1:0] uart_tx_mode;
    logic [NO_SPIS-1:0] uart_tx_otype;

    logic [NO_SPIS-1:0] uart_rx_i;
    logic [NO_SPIS-1:0] uart_rx_o;
    logic [NO_SPIS-1:0] uart_rx_mode;
    logic [NO_SPIS-1:0] uart_rx_otype;

	generate
        for (genvar i = 0; i < NO_MEMS; i++) begin
			assign mem_srst     [i] = _mem_srst[i];
            assign mem_pause_req[i] = _mem_pause_req[i];
            
            assign _mem_pause_ack[i] = mem_pause_ack[i];

            assign mem_axil[i].aw_addr =
				mem_axil_aw_addr[i*ADDR_WIDTH +: ADDR_WIDTH];
            assign mem_axil[i].aw_prot =
				mem_axil_aw_prot[i*PROT_WIDTH +: PROT_WIDTH];
			assign mem_axil[i].w_data =
				mem_axil_w_data[i*DATA_WIDTH +: DATA_WIDTH];
			assign mem_axil[i].w_strb =
				mem_axil_w_strb[i*STRB_WIDTH +: STRB_WIDTH];
			assign mem_axil[i].ar_addr =
				mem_axil_ar_addr[i*ADDR_WIDTH +: ADDR_WIDTH];
			assign mem_axil[i].ar_prot =
				mem_axil_ar_prot[i*PROT_WIDTH +: PROT_WIDTH];

            assign mem_axil[i].aw_valid = mem_axil_aw_valid[i];
            assign mem_axil[i].w_valid  = mem_axil_w_valid [i];
            assign mem_axil[i].b_ready  = mem_axil_b_ready [i];
            assign mem_axil[i].ar_valid = mem_axil_ar_valid[i];
            assign mem_axil[i].r_ready  = mem_axil_r_ready [i];

			assign mem_axil_b_resp[i*RESP_WIDTH +: RESP_WIDTH] =
				mem_axil[i].b_resp;
			assign mem_axil_r_data[i*DATA_WIDTH +: DATA_WIDTH] =
				mem_axil[i].r_data;
			assign mem_axil_r_resp[i*RESP_WIDTH +: RESP_WIDTH] =
				mem_axil[i].r_resp;

            assign mem_axil_aw_ready[i] = mem_axil[i].aw_ready;
            assign mem_axil_w_ready [i] = mem_axil[i].w_ready;
            assign mem_axil_b_valid [i] = mem_axil[i].b_valid;
            assign mem_axil_ar_ready[i] = mem_axil[i].ar_ready;
            assign mem_axil_r_valid [i] = mem_axil[i].r_valid;
        end

        for (genvar i = 0; i < GPIO_WIDTH*NO_GPIOS; i++) begin
            assign gpio_io_i[i]     = gpio_io[i].i;
			assign gpio_io[i].o     = gpio_io_o    [i];
            assign gpio_io[i].mode  = gpio_io_mode [i];
            assign gpio_io[i].otype = gpio_io_otype[i]; 

			assign gpio_func[i] =
				_gpio_func[i*FUNC_WIDTH +: FUNC_WIDTH];
        end

        for (genvar i = 0; i < NO_SPIS; i++) begin
            assign spi_sclk_i[i]     = spi_sclk[i].i;
			assign spi_sclk[i].o     = spi_sclk_o    [i];
            assign spi_sclk[i].mode  = spi_sclk_mode [i];
            assign spi_sclk[i].otype = spi_sclk_otype[i]; 

            assign spi_mosi_i[i]     = spi_mosi[i].i;
			assign spi_mosi[i].o     = spi_mosi_o    [i];
            assign spi_mosi[i].mode  = spi_mosi_mode [i];
            assign spi_mosi[i].otype = spi_mosi_otype[i]; 

			assign spi_miso_i[i]     = spi_miso[i].i;
			assign spi_miso[i].o     = spi_miso_o    [i];
            assign spi_miso[i].mode  = spi_miso_mode [i];
            assign spi_miso[i].otype = spi_miso_otype[i]; 

            assign spi_ss_n_i[i]     = spi_ss_n[i].i;
			assign spi_ss_n[i].o     = spi_ss_n_o    [i];
            assign spi_ss_n[i].mode  = spi_ss_n_mode [i];
            assign spi_ss_n[i].otype = spi_ss_n_otype[i]; 
        end

        for (genvar i = 0; i < NO_UARTS; i++) begin
            assign uart_tx_i[i]     = uart_tx[i].i;
			assign uart_tx[i].o     = uart_tx_o    [i];
            assign uart_tx[i].mode  = uart_tx_mode [i];
            assign uart_tx[i].otype = uart_tx_otype[i]; 

            assign uart_rx_i[i]     = uart_rx[i].i;
			assign uart_rx[i].o     = uart_rx_o    [i];
            assign uart_rx[i].mode  = uart_rx_mode [i];
            assign uart_rx[i].otype = uart_rx_otype[i]; 
        end
    endgenerate

	adam_power adam_power (
		.clk              (clk),
		.rst              (rst),
		.test             (test),

		.pause_req        (pause_req),
		.pause_ack        (pause_ack),
		
		.rst_boot_addr    (rst_boot_addr),
		
		.mem_srst         (_mem_srst),
		.mem_pause_req    (_mem_pause_req),
		.mem_pause_ack    (_mem_pause_ack),
		
		.mem_axil_aw_addr  (mem_axil_aw_addr),
		.mem_axil_aw_prot  (mem_axil_aw_prot),
		.mem_axil_aw_valid (mem_axil_aw_valid),
		.mem_axil_aw_ready (mem_axil_aw_ready),
		.mem_axil_w_data   (mem_axil_w_data),
		.mem_axil_w_strb   (mem_axil_w_strb),
		.mem_axil_w_valid  (mem_axil_w_valid),
		.mem_axil_w_ready  (mem_axil_w_ready),
		.mem_axil_b_resp   (mem_axil_b_resp),
		.mem_axil_b_valid  (mem_axil_b_valid),
		.mem_axil_b_ready  (mem_axil_b_ready),
		.mem_axil_ar_addr  (mem_axil_ar_addr),
		.mem_axil_ar_prot  (mem_axil_ar_prot),
		.mem_axil_ar_valid (mem_axil_ar_valid),
		.mem_axil_ar_ready (mem_axil_ar_ready),
		.mem_axil_r_data   (mem_axil_r_data),
		.mem_axil_r_resp   (mem_axil_r_resp),
		.mem_axil_r_valid  (mem_axil_r_valid),
		.mem_axil_r_ready  (mem_axil_r_ready),
		
		.gpio_io_i        (gpio_io_i),
		.gpio_io_o        (gpio_io_o),
		.gpio_io_mode     (gpio_io_mode),
		.gpio_io_otype    (gpio_io_otype),
		
		.gpio_func        (_gpio_func),
		
		.spi_sclk_i       (spi_sclk_i),
		.spi_sclk_o       (spi_sclk_o),
		.spi_sclk_mode    (spi_sclk_mode),
		.spi_sclk_otype   (spi_sclk_otype),
		
		.spi_mosi_i       (spi_mosi_i),
		.spi_mosi_o       (spi_mosi_o),
		.spi_mosi_mode    (spi_mosi_mode),
		.spi_mosi_otype   (spi_mosi_otype),
		
		.spi_miso_i       (spi_miso_i),
		.spi_miso_o       (spi_miso_o),
		.spi_miso_mode    (spi_miso_mode),
		.spi_miso_otype   (spi_miso_otype),
		
		.spi_ss_n_i       (spi_ss_n_i),
		.spi_ss_n_o       (spi_ss_n_o),
		.spi_ss_n_mode    (spi_ss_n_mode),
		.spi_ss_n_otype   (spi_ss_n_otype),
		
		.uart_tx_i        (uart_tx_i),
		.uart_tx_o        (uart_tx_o),
		.uart_tx_mode     (uart_tx_mode),
		.uart_tx_otype    (uart_tx_otype),
		
		.uart_rx_i        (uart_rx_i),
		.uart_rx_o        (uart_rx_o),
		.uart_rx_mode     (uart_rx_mode),
		.uart_rx_otype    (uart_rx_otype)
	);

endmodule