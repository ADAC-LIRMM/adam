`include "axi/assign.svh"

module adam #(
	parameter ADDR_WIDTH = 32,
	parameter DATA_WIDTH = 32,
	parameter GPIO_WIDTH = 16,

	parameter NO_MEMS   = 3,
    parameter NO_GPIOS  = 4,
    parameter NO_SPIS   = 1,
    parameter NO_TIMERS = 1,
    parameter NO_UARTS  = 1,
	parameter NO_CPUS   = 1,
    parameter NO_LPUS   = 1,

	// Dependent parameters bellow, do not override.

	parameter STRB_WIDTH  = DATA_WIDTH/8,

	parameter type addr_t = logic [ADDR_WIDTH-1:0],
    parameter type data_t = logic [DATA_WIDTH-1:0],
    parameter type strb_t = logic [STRB_WIDTH-1:0]
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

	localparam NO_CORES = NO_CPUS;

	localparam NO_XBAR_SLVS = 2*NO_CPUS;
	localparam NO_XBAR_MSTS = NO_MEMS + 1;

	typedef struct packed {
        int unsigned idx;
        addr_t start_addr;
        addr_t end_addr;
    } rule_t;

	rule_t [NO_XBAR_MSTS-1:0] addr_map;

	AXI_LITE #(
        .AXI_ADDR_WIDTH (ADDR_WIDTH),
        .AXI_DATA_WIDTH (DATA_WIDTH)
    ) xbar_slv_axil [NO_XBAR_SLVS] ();
	
	AXI_LITE #(
        .AXI_ADDR_WIDTH (ADDR_WIDTH),
        .AXI_DATA_WIDTH (DATA_WIDTH)
    ) xbar_mst_axil [NO_XBAR_MSTS] ();

	AXI_LITE #(
        .AXI_ADDR_WIDTH (ADDR_WIDTH),
        .AXI_DATA_WIDTH (DATA_WIDTH)
    ) cpu_axil [2*NO_CPUS] ();

	AXI_LITE #(
        .AXI_ADDR_WIDTH (ADDR_WIDTH),
        .AXI_DATA_WIDTH (DATA_WIDTH)
    ) periphs_axil ();

	logic  core_srst      [NO_CORES];
    logic  core_pause_req [NO_CORES];
	logic  core_pause_ack [NO_CORES];
    addr_t core_boot_addr [NO_CORES];    
    logic  core_irq       [NO_CORES];

	logic xbar_pause_req;
	logic xbar_pause_ack;

	logic periphs_pause_req;
	logic periphs_pause_ack;

	always_ff @(posedge clk) begin
		if (rst) begin
			xbar_pause_req    <= 0;
			periphs_pause_req <= 0;
			pause_ack         <= 0;
		end
		else if (pause_req && pause_ack) begin
			// PAUSED
		end
		else if (pause_req && !pause_ack) begin
			// pausing
			if (!periphs_pause_req || !periphs_pause_ack) begin
				periphs_pause_req <= 1;
			end
			else if (!xbar_pause_req || !xbar_pause_ack) begin
				xbar_pause_req <= 1;
			end
			else begin
				pause_ack <= 1;
			end
		end
		else if (!pause_req && pause_ack) begin
			// resuming
			if (xbar_pause_req || xbar_pause_ack) begin
				xbar_pause_req <= 0;
			end
			else if (periphs_pause_req || periphs_pause_ack) begin
				periphs_pause_req <= 0;
			end
			else begin
				pause_ack <= 0;
			end
		end
	end

 	generate
		localparam MEMS_S = 0;
		localparam MEMS_E = MEMS_S + NO_MEMS;
		
		localparam PERIPHS_S = MEMS_E;
		localparam PERIPHS_E = PERIPHS_S + 1;

        for(genvar i = MEMS_S; i < MEMS_E; i++) begin
            
			`AXI_LITE_ASSIGN(
				mem_axil[i - MEMS_S],
				xbar_mst_axil[i]
			);

			always_comb begin
				addr_map[i] = '{
					idx:        i,
					start_addr: (32'h1000_0000) + (32'h0100_0000)*(i),
					end_addr:   (32'h1000_0000) + (32'h0100_0000)*(i+1)
				};
			end
        end

		for(genvar i = PERIPHS_S; i < PERIPHS_E; i++) begin
			`AXI_LITE_ASSIGN(periphs_axil, xbar_mst_axil[i]);

			assign addr_map[i] = '{
				idx:        i,
				start_addr: 32'h2000_0000,
				end_addr:   32'h3000_0000
			};
		end
    endgenerate

	generate
		localparam CPUS_S = 0;
		localparam CPUS_E = CPUS_S + 2*NO_CPUS;

		for(genvar i = CPUS_S; i < CPUS_E; i++) begin
			`AXI_LITE_ASSIGN(xbar_slv_axil[i], cpu_axil[i - CPUS_S]);
		end
	endgenerate

	generate
		for(genvar i = 0; i < NO_CPUS; i++) begin
			adam_cpu adam_cpu (
				.clk  (clk),
				.rst  (rst),
				.test (test),

				.pause_req (core_pause_req[i]),
				.pause_ack (core_pause_ack[i]),

				.boot_addr (core_boot_addr[i]),

				.inst_axil (cpu_axil[2*i + 0]),
				.data_axil (cpu_axil[2*i + 1]),

				.irq (core_irq[i])
			);
		end
	endgenerate

	adam_axil_xbar #(
        .ADDR_WIDTH (ADDR_WIDTH),
        .DATA_WIDTH (DATA_WIDTH),

        .NO_SLAVES  (NO_XBAR_SLVS),
        .NO_MASTERS (NO_XBAR_MSTS),
        
        .MAX_TRANS (7),

        .rule_t (rule_t)
    ) adam_axil_xbar (
        .clk  (clk),
        .rst  (rst),
        .test (test),
        
        .pause_req (xbar_pause_req),
		.pause_ack (xbar_pause_ack),

        .axil_slv (xbar_slv_axil),
        .axil_mst (xbar_mst_axil),

        .addr_map (addr_map)
    );

	adam_periphs #(
		.ADDR_WIDTH (ADDR_WIDTH),
    	.DATA_WIDTH (DATA_WIDTH),
    	.GPIO_WIDTH (GPIO_WIDTH),

		.NO_CORES  (NO_CORES),
		.NO_MEMS   (NO_MEMS),
		.NO_GPIOS  (NO_GPIOS),
    	.NO_SPIS   (NO_SPIS),
    	.NO_TIMERS (NO_TIMERS),
    	.NO_UARTS  (NO_UARTS)
	) adam_periphs (
		.clk  (clk),
		.rst  (rst),
		.test (test),
		
		.pause_req (periphs_pause_req),
		.pause_ack (periphs_pause_ack),

    	.axil (periphs_axil),

		.rst_boot_addr (rst_boot_addr),

		.mem_srst      (mem_srst),
		.mem_pause_req (mem_pause_req),
		.mem_pause_ack (mem_pause_ack),

        .core_srst      (core_srst),
        .core_pause_req (core_pause_req),
		.core_pause_ack (core_pause_ack),
   	    .core_boot_addr (core_boot_addr),    
        .core_irq       (core_irq),
    
    	.gpio_io   (gpio_io),
		.gpio_func (gpio_func),

    	.spi_sclk (spi_sclk),
    	.spi_mosi (spi_mosi),
    	.spi_miso (spi_miso),
    	.spi_ss_n (spi_ss_n),

    	.uart_tx (uart_tx),
    	.uart_rx (uart_rx)
	);

endmodule