// /*
//  * Conduct tests on the GPIO with the highest index to perform a
//  * minimal verification of the address routing. After testing, ensure
//  * that the system responds to an incoming pause request, eventually
//  * pausing when certain peripherals are active and others are not.
//  * Before utilizing the GPIO, it must be resumed, as by default, all
//  * normal peripherals are not running.
//  */

// `include "axi/assign.svh"
// `include "vunit_defines.svh"

// module adam_periphs_tb;
//     import adam_axil_master_bhv::*;

//     localparam ADDR_WIDTH = 32;
//     localparam DATA_WIDTH = 32;
//     localparam GPIO_WIDTH = 16;

//     localparam NO_CORES  = 2;
//     localparam NO_MEMS   = 3;
//     localparam NO_GPIOS  = 4;
//     localparam NO_SPIS   = 1;
//     localparam NO_TIMERS = 1;
//     localparam NO_UARTS  = 1;

//     localparam STRB_WIDTH = DATA_WIDTH/8;

//     localparam CLK_PERIOD = 20ns;
//     localparam RST_CYCLES = 5;

//     localparam TA = 2ns;
//     localparam TT = CLK_PERIOD - TA;
    
//     localparam MAX_TRANS = 7;
    
//     typedef logic [ADDR_WIDTH-1:0] addr_t;
//     typedef logic [2:0]            prot_t;       
//     typedef logic [DATA_WIDTH-1:0] data_t;
//     typedef logic [STRB_WIDTH-1:0] strb_t;
//     typedef logic [1:0]            resp_t;

//     logic clk;
//     logic rst;
        
//     logic pause.req;
//     logic pause.ack;

//     addr_t rst_boot_addr;

//     logic mem_srst      [NO_MEMS];
//     logic mem_pause.req [NO_MEMS];
//     logic mem_pause.ack [NO_MEMS];

//     logic  core_srst      [NO_CORES];
//     logic  core_pause.req [NO_CORES];
//     logic  core_pause.ack [NO_CORES];
//     addr_t core_boot_addr [NO_CORES];
//     logic  core_irq       [NO_CORES];
            
//     ADAM_IO     gpio_io   [GPIO_WIDTH*NO_GPIOS] ();
//     logic [1:0] gpio_func [GPIO_WIDTH*NO_GPIOS];

//     ADAM_IO spi_sclk [NO_SPIS] ();
//     ADAM_IO spi_mosi [NO_SPIS] ();
//     ADAM_IO spi_miso [NO_SPIS] ();
//     ADAM_IO spi_ss_n [NO_SPIS] ();

//     ADAM_IO uart_tx [NO_UARTS] ();
//     ADAM_IO uart_rx [NO_UARTS] ();

//     AXI_LITE #(
//         .AXI_ADDR_WIDTH (ADDR_WIDTH),
//         .AXI_DATA_WIDTH (DATA_WIDTH)
//     ) axil ();
    
//     AXI_LITE_DV #(
//         .AXI_ADDR_WIDTH(ADDR_WIDTH),
//         .AXI_DATA_WIDTH(DATA_WIDTH)
//     ) axil_dv (seq.clk);

//     `AXI_LITE_ASSIGN(axil, axil_dv);

//     adam_axil_master_bhv #(
//         .ADDR_WIDTH (ADDR_WIDTH),
//         .DATA_WIDTH (DATA_WIDTH),
    
//         .TA (TA),
//         .TT (TT),

//         .MAX_TRANS (MAX_TRANS)
//     ) axil_bhv = new(axil_dv);

//     adam_clk_rst_bhv #(
//         .CLK_PERIOD (CLK_PERIOD),
//         .RST_CYCLES (RST_CYCLES),

//         .TA (TA),
//         .TT (TT)
//     ) adam_clk_rst_bhv (
//         .clk (seq.clk),
//         .rst (rst)
//     );

//     generate
//         assign rst_boot_addr = 32'hBADCAB1E;

//         assign mem_pause.ack[0] = 0;
//         for (genvar i = 1; i < NO_MEMS; i++) begin
//             assign mem_pause[i].ack = 1;
//         end

//         assign core_pause.ack[0] = 0;
//         for (genvar i = 1; i < NO_CORES; i++) begin
//             assign mem_core[i].ack = 1;
//         end

//         for (genvar i = 0; i < GPIO_WIDTH*NO_GPIOS; i++) begin
//             assign gpio_io[i].i = 0;
//         end

//         for (genvar i = 0; i < NO_SPIS; i++) begin
//             assign spi_sclk[i].i = 0;
//             assign spi_mosi[i].i = 0;
//             assign spi_miso[i].i = 0;
//             assign spi_ss_n[i].i = 0;
//         end
        
//         for (genvar i = 0; i < NO_UARTS; i++) begin
//             assign uart_tx[i].i = 0;
//             assign uart_rx[i].i = 0;
//         end
//     endgenerate

//     adam_periphs #(
//         .ADDR_WIDTH (ADDR_WIDTH),
//         .DATA_WIDTH (DATA_WIDTH),
//         .GPIO_WIDTH (GPIO_WIDTH),

//         .NO_CORES  (NO_CORES),
//         .NO_MEMS   (NO_MEMS),
//         .NO_GPIOS  (NO_GPIOS),
//         .NO_SPIS   (NO_SPIS),
//         .NO_TIMERS (NO_TIMERS),
//         .NO_UARTS  (NO_UARTS)
//     ) dut (
//         .seq   (seq),
//         .pause (pause),

//         .axil (axil),

//         .rst_boot_addr (rst_boot_addr),

//         .mem_srst (mem_srst),
//         .mem_pause (mem_pause),

//         .core_srst      (core_srst),
//         .core_pause.req (core_pause.req),
//         .core_pause.ack (core_pause.ack),
//         .core_boot_addr (core_boot_addr),    
//         .core_irq       (core_irq),
            
//         .gpio_io   (gpio_io),
//         .gpio_func (gpio_func),

//         .spi_sclk (spi_sclk),
//         .spi_mosi (spi_mosi),
//         .spi_miso (spi_miso),
//         .spi_ss_n (spi_ss_n),

//         .uart_tx (uart_tx),
//         .uart_rx (uart_rx)
//     );

//     initial axil_bhv.loop();

//     `TEST_SUITE begin
//         `TEST_CASE("test") begin
//             addr_t addr;
//             data_t data;
//             resp_t resp;
            
//             pause.req = 0;

//             @(negedge seq.rst);
//             #1us;
//             @(posedge seq.clk);
            
//             // Resume GPIO
//             addr = 32'h0000_0838; // PMRx
//             data = 1;        // resume
//             fork
//                 axil_bhv.send_aw(addr, 3'b000);
//                 axil_bhv.send_w(data, 4'b1111);
//                 axil_bhv.recv_b(resp);
//             join
//             assert (resp == axi_pkg::RESP_OKAY);

//             // Wait for Maestro
//             do begin
//                 fork
//                     axil_bhv.send_ar(addr, 3'b000);
//                     axil_bhv.recv_r(data, resp);
//                 join
//                 assert (resp == axi_pkg::RESP_OKAY);
//             end while (data == 1);

//             // Configure GPIO to output mode
//             addr = 32'h0004_0008; // MODER
//             data = 32'h0001;
//             fork
//                 axil_bhv.send_aw(addr, 3'b000);
//                 axil_bhv.send_w(data, 4'b1111);
//                 axil_bhv.recv_b(resp);
//             join
//             assert (resp == axi_pkg::RESP_OKAY);

//             // Set GPIO to logic level high
//             addr = 32'h0004_0004; // ODR
//             data = 32'h0001; // First IO to 1
//             fork
//                 axil_bhv.send_aw(addr, 3'b000);
//                 axil_bhv.send_w(data, 4'b1111);
//                 axil_bhv.recv_b(resp);
//             join
//             assert (resp == axi_pkg::RESP_OKAY);

//             // Verify GPIO logic level
//             assert (gpio_io[GPIO_WIDTH*(NO_GPIOS-1)].o == 1);

//             // Pause
//             pause.req <= #TA 1;
//             cycle_start();
//             while (pause.ack != 1) begin
//                 cycle_end();
//                 cycle_start();
//             end
//             cycle_end();
//         end
//     end

//     task cycle_start();
//         #TT;
//     endtask

//     task cycle_end();
//         @(posedge seq.clk);
//     endtask

// endmodule