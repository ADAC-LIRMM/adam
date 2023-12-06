// `include "axi/assign.svh"

// module adam_periphs #(
//     parameter ADDR_WIDTH = 32,
//     parameter DATA_WIDTH = 32,
//     parameter GPIO_WIDTH = 16,

//     parameter NO_CORES  = 2,
//     parameter NO_MEMS   = 3,
//     parameter NO_GPIOS  = 4,
//     parameter NO_SPIS   = 1,
//     parameter NO_TIMERS = 1,
//     parameter NO_UARTS  = 1,

//     // Dependent parameters bellow, do not override.

//     parameter STRB_WIDTH  = DATA_WIDTH/8,

//     parameter type addr_t = logic [ADDR_WIDTH-1:0],
//     parameter type data_t = logic [DATA_WIDTH-1:0],
//     parameter type strb_t = logic [STRB_WIDTH-1:0]
// ) (
//     ADAM_SEQ.Slave   seq,
//     ADAM_PAUSE.Slave pause,

//     AXI_LITE.Slave axil,

//     input addr_t rst_boot_addr,

//     output logic      mem_srst  [NO_MEMS],
//     ADAM_PAUSE.Master mem_pause [NO_MEMS],

//     output logic      core_srst      [NO_CORES],
//     ADAM_PAUSE.Master core_pause     [NO_CORES],
//     output addr_t     core_boot_addr [NO_CORES],    
//     output logic      core_irq       [NO_CORES],
        
//     ADAM_IO.Master     gpio_io   [GPIO_WIDTH*NO_GPIOS],
//     output logic [1:0] gpio_func [GPIO_WIDTH*NO_GPIOS],

//     ADAM_IO.Master spi_sclk [NO_SPIS],
//     ADAM_IO.Master spi_mosi [NO_SPIS],
//     ADAM_IO.Master spi_miso [NO_SPIS],
//     ADAM_IO.Master spi_ss_n [NO_SPIS],

//     ADAM_IO.Master uart_tx [NO_UARTS],
//     ADAM_IO.Master uart_rx [NO_UARTS]
// );    

//     localparam NO_PERIPHS = 1 + NO_GPIOS + NO_SPIS + NO_TIMERS + NO_UARTS;
    
//     typedef struct packed {
//         int unsigned idx;
//         addr_t start_addr;
//         addr_t end_addr;
//     } rule_t;

//     APB #(
//         .ADDR_WIDTH(ADDR_WIDTH),
//         .DATA_WIDTH(DATA_WIDTH)
//     ) apb [NO_PERIPHS] ();

//     rule_t [NO_PERIPHS-1:0] addr_map;

//     logic bridge_pause.req;
//     logic bridge_pause.ack;

//     logic sysctrl_pause.req;
//     logic sysctrl_pause.ack;

//     logic others_pause.req;
//     logic others_pause.ack;
    
//     logic periph_pause.req [NO_PERIPHS];
//     logic periph_pause.ack [NO_PERIPHS];

//     logic periph_srst   [NO_PERIPHS];
//     logic scp_pause.req [NO_PERIPHS];
//     logic scp_pause.ack [NO_PERIPHS];
//     logic periph_irq    [NO_PERIPHS];
    
//     always_comb begin
//         for (int i = 0; i < NO_PERIPHS; i++) begin
//             addr_map[i] = '{
//                 idx: i,
//                 start_addr: i << 16,
//                 end_addr: (i + 1) << 16
//             };
//         end
//     end

//     adam_axil_apb_bridge #(
//         .ADDR_WIDTH (ADDR_WIDTH),
//         .DATA_WIDTH (DATA_WIDTH),

//         .NO_APBS (NO_PERIPHS),
    
//         .rule_t (rule_t)
//     ) adam_axil_apb_bridge (
//         .seq(seq)

//         .pause.req (bridge_pause.req),
//         .pause.ack (bridge_pause.ack),

//         .axil (axil),
        
//         .apb (apb),

//         .addr_map (addr_map)
//     );

//     generate
//         localparam SYSCTRLS_B = 0;
//         localparam SYSCTRLS_E = SYSCTRLS_B + 1;
        
//         localparam GPIOS_B = SYSCTRLS_E;
//         localparam GPIOS_E = GPIOS_B + NO_GPIOS;

//         localparam SPIS_B = GPIOS_E;
//         localparam SPIS_E = SPIS_B + NO_SPIS;

//         localparam TIMERS_B = SPIS_E;
//         localparam TIMERS_E = TIMERS_B + NO_TIMERS;

//         localparam UARTS_B = TIMERS_E;
//         localparam UARTS_E = UARTS_B + NO_UARTS;

//         for(genvar i = SYSCTRLS_B; i < SYSCTRLS_E; i++) begin
//             adam_periph_sysctrl #(
//                 .ADDR_WIDTH (ADDR_WIDTH),
//                 .DATA_WIDTH (DATA_WIDTH),

//                 .NO_CORES   (NO_CORES),
//                 .NO_MEMS    (NO_MEMS),
//                 .NO_PERIPHS (NO_PERIPHS)
//             ) adam_periph_sysctrl (
//                 .clk  (seq.clk),
//                 .rst  (rst || periph_srst[i]),
                
//                 .pause.req (mem_periph[i].req),
//                 .pause.ack (mem_periph[i].ack),

//                 .apb (apb[i]),
                
//                 .irq (periph_irq[i]),
                
//                 .rst_boot_addr (rst_boot_addr),
                
//                 .mem_srst      (mem_srst),
//                 .mem_pause.req (mem_pause.req),
//                 .mem_pause.ack (mem_pause.ack),

//                 .periph_srst      (periph_srst),
//                 .periph_pause.req (scp_pause.req),
//                 .periph_pause.ack (scp_pause.ack),
//                 .periph_irq       (periph_irq),

//                 .core_srst      (core_srst),
//                 .core_pause.req (core_pause.req),
//                 .core_pause.ack (core_pause.ack),
//                 .core_boot_addr (core_boot_addr),
//                 .core_irq       (core_irq)
//             );
//         end
    
//         for (genvar i = GPIOS_B; i < GPIOS_E; i++) begin
            
//             localparam OFFSET = (i-GPIOS_B)*GPIO_WIDTH;

//             ADAM_IO     io   [GPIO_WIDTH] ();
//             logic [1:0] func [GPIO_WIDTH];

//             for (genvar j = 0; j < GPIO_WIDTH; j++) begin
//                 assign io[j].i = gpio_io[j + OFFSET].i;

//                 assign gpio_io[j + OFFSET].o     = io[j].o;
//                 assign gpio_io[j + OFFSET].mode  = io[j].mode;
//                 assign gpio_io[j + OFFSET].otype = io[j].otype;

//                 assign gpio_func[j + OFFSET] = func[j];
//             end

//             adam_periph_gpio #(
//                 .ADDR_WIDTH (ADDR_WIDTH),
//                 .DATA_WIDTH (DATA_WIDTH),
//                 .GPIO_WIDTH (GPIO_WIDTH)
//             ) adam_periph_gpio (
//                 .clk  (seq.clk),
//                 .rst  (rst || periph_srst[i]),

//                 .pause.req (mem_periph[i].req),
//                 .pause.ack (mem_periph[i].ack),

//                 .apb (apb[i]),

//                 .irq (periph_irq[i]),

//                 .io   (io),
//                 .func (func)
//             );
//         end

//         for (genvar i = SPIS_B; i < SPIS_E; i++) begin
//             adam_periph_spi #(
//                 .ADDR_WIDTH(ADDR_WIDTH),
//                 .DATA_WIDTH(DATA_WIDTH)
//             ) adam_periph_spi (
//                 .clk  (seq.clk),
//                 .rst  (rst || periph_srst[i]),
                
//                 .pause.req (mem_periph[i].req),
//                 .pause.ack (mem_periph[i].ack),

//                 .apb (apb[i]),
                
//                 .irq (periph_irq[i]),

//                 .sclk (spi_sclk[i - SPIS_B]),
//                 .mosi (spi_mosi[i - SPIS_B]),
//                 .miso (spi_miso[i - SPIS_B]),
//                 .ss_n (spi_ss_n[i - SPIS_B])
//             );
//         end

//         for (genvar i = TIMERS_B; i < TIMERS_E; i++) begin
//             adam_periph_timer #(
//                 .ADDR_WIDTH(ADDR_WIDTH),
//                 .DATA_WIDTH(DATA_WIDTH)
//             ) adam_periph_timer (
//                 .clk  (seq.clk),
//                 .rst  (rst),

//                 .pause.req (mem_periph[i].req),
//                 .pause.ack (mem_periph[i].ack),

//                 .apb (apb[i]),
                
//                 .irq (periph_irq[i])
//             );
//         end

//         for (genvar i = UARTS_B; i < UARTS_E; i++) begin
//             adam_periph_uart #(
//                 .ADDR_WIDTH(ADDR_WIDTH),
//                 .DATA_WIDTH(DATA_WIDTH)
//             ) adam_periph_uart (
//                 .clk  (seq.clk),
//                 .rst  (rst || periph_srst[i]),

//                 .pause.req (mem_periph[i].req),
//                 .pause.ack (mem_periph[i].ack),

//                 .apb (apb[i]),
                
//                 .irq (periph_irq[i]),

//                 .tx (uart_tx[i - UARTS_B]),
//                 .rx (uart_rx[i - UARTS_B])
//             );
//         end
//     endgenerate

//     /* 
//      * The following always_comb block might seem complex at first glance.
//      * However, its primary purpose is to simplify the always_ff block that
//      * follows. To truly understand the logic and purpose of this block, please
//      * refer to the always_ff block.
//      */
//     always_comb begin
//         periph_pause.req[0] = sysctrl_pause.req || scp_pause.req[0];

//         if (periph_pause.req[0]) begin
//             sysctrl_pause.ack = periph_pause.ack[0];
//         end
//         else begin
//             sysctrl_pause.ack = (periph_pause.ack[0] && !scp_pause.req[0]);
//         end

//         for (int i = 1; i < NO_PERIPHS; i++) begin
//             mem_periph[i].req = others_pause.req || scp_pause[i].req;
//         end

//         if (others_pause.req) begin
//             others_pause.ack = 1;
//             for (int i = 1; i < NO_PERIPHS; i++) begin
//                 // TODO: remove periph_srst[i]
//                 others_pause.ack &= (mem_periph[i].ack || periph_srst[i]);
//             end
//         end
//         else begin
//             others_pause.ack = 0;
//             for (int i = 1; i < NO_PERIPHS; i++) begin
//                 others_pause.ack |= (mem_periph[i].ack && !scp_pause[i].req);
//             end
//         end

//         for (int i = 0; i < NO_PERIPHS; i++) begin
//             scp_pause[i].ack = mem_periph[i].ack;
//         end
//     end

//     always_ff @(posedge seq.clk) begin
//         if (seq.rst) begin
//             pause.ack <= 0;

//             bridge_pause.req  <= 0;
//             sysctrl_pause.req <= 0;
//             others_pause.req  <= 0;
//         end
//         else if (pause.req && pause.ack) begin
//             // PAUSED
//         end
//         else if (pause.req && !pause.ack) begin
//             // pausing

//             if (!bridge_pause.req || !bridge_pause.ack) begin
//                 // 1. pause bridge
//                 bridge_pause.req <= 1;
//             end
//             else if (!sysctrl_pause.req || !sysctrl_pause.ack) begin
//                 // 2. pause SYSCTRL
//                 sysctrl_pause.req <= 1;
//             end
//             else if (!others_pause.req || !others_pause.ack) begin
//                 // 3. pause other peripherals
//                 others_pause.req <= 1;
//             end
//             else begin
//                 // 4. end
//                 pause.ack <= 1;
//             end
//         end
//         else if (!pause.req && pause.ack) begin
//             // resuming

//             if (others_pause.req || others_pause.ack) begin
//                 // 1. resume other peripherals (if running before pause)
//                 others_pause.req <= 0;
//             end
//             else if (sysctrl_pause.req || others_pause.ack) begin
//                 // 2. resume SYSCTRL (if running before pause)
//                 sysctrl_pause.req <= 0;
//             end
//             else if (bridge_pause.req || bridge_pause.ack) begin
//                 // 3. resume bridge
//                 bridge_pause.req <= 0;
//             end
//             else begin
//                 // 4. end
//                 pause.ack <= 0;
//             end
//         end
//     end

// endmodule