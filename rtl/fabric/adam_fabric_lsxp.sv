`include "axi/assign.svh"

module adam_fabric_lsxp #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32,

    parameter N = 2,

    // Dependent parameters bellow, do not override.

    parameter STRB_WIDTH  = DATA_WIDTH/8,

    parameter type addr_t = logic [ADDR_WIDTH-1:0],
    parameter type data_t = logic [DATA_WIDTH-1:0],
    parameter type strb_t = logic [STRB_WIDTH-1:0]
) (
    input logic clk,
    input logic rst,
    
    input logic  pause_req,
    output logic pause_ack,

    AXI_LITE.Slave slv,
    APB.Master     msts
);    
    
    typedef struct packed {
        int unsigned idx;
        addr_t start_addr;
        addr_t end_addr;
    } rule_t;

    rule_t [N-1:0] addr_map;

    always_comb begin
        for (int i = 0; i < N; i++) begin
            addr_map[i] = '{
                idx: i,
                start_addr: 1024*i,
                end_addr:   1024*(i+1)
            };
        end
    end

    adam_axil_apb_bridge #(
        .ADDR_WIDTH (ADDR_WIDTH),
        .DATA_WIDTH (DATA_WIDTH),

        .NO_APBS (NO_PERIPHS),
    
        .rule_t (rule_t)
    ) adam_axil_apb_bridge (
        .clk  (clk),
        .rst  (rst),

        .pause_req (pause_req),
        .pause_ack (pause_ack),

        .axil (axil),
        
        .apb (apb),

        .addr_map (addr_map)
    );

    generate
        localparam SYSCTRLS_B = 0;
        localparam SYSCTRLS_E = SYSCTRLS_B + 1;
        
        localparam GPIOS_B = SYSCTRLS_E;
        localparam GPIOS_E = GPIOS_B + NO_GPIOS;

        localparam SPIS_B = GPIOS_E;
        localparam SPIS_E = SPIS_B + NO_SPIS;

        localparam TIMERS_B = SPIS_E;
        localparam TIMERS_E = TIMERS_B + NO_TIMERS;

        localparam UARTS_B = TIMERS_E;
        localparam UARTS_E = UARTS_B + NO_UARTS;

        for(genvar i = SYSCTRLS_B; i < SYSCTRLS_E; i++) begin
            adam_periph_sysctrl #(
                .ADDR_WIDTH (ADDR_WIDTH),
                .DATA_WIDTH (DATA_WIDTH),

                .NO_CORES   (NO_CORES),
                .NO_MEMS    (NO_MEMS),
                .NO_PERIPHS (NO_PERIPHS)
            ) adam_periph_sysctrl (
                .clk  (clk),
                .rst  (rst || periph_srst[i]),
                
                .pause_req (periph_pause_req[i]),
                .pause_ack (periph_pause_ack[i]),

                .apb (apb[i]),
                
                .irq (periph_irq[i]),
                
                .rst_boot_addr (rst_boot_addr),
                
                .mem_srst      (mem_srst),
                .mem_pause_req (mem_pause_req),
                .mem_pause_ack (mem_pause_ack),

                .periph_srst      (periph_srst),
                .periph_pause_req (scp_pause_req),
                .periph_pause_ack (scp_pause_ack),
                .periph_irq       (periph_irq),

                .core_srst      (core_srst),
                .core_pause_req (core_pause_req),
                .core_pause_ack (core_pause_ack),
                .core_boot_addr (core_boot_addr),
                .core_irq       (core_irq)
            );
        end
    
        for (genvar i = GPIOS_B; i < GPIOS_E; i++) begin
            
            localparam OFFSET = (i-GPIOS_B)*GPIO_WIDTH;

            ADAM_IO     io   [GPIO_WIDTH] ();
            logic [1:0] func [GPIO_WIDTH];

            for (genvar j = 0; j < GPIO_WIDTH; j++) begin
                assign io[j].i = gpio_io[j + OFFSET].i;

                assign gpio_io[j + OFFSET].o     = io[j].o;
                assign gpio_io[j + OFFSET].mode  = io[j].mode;
                assign gpio_io[j + OFFSET].otype = io[j].otype;

                assign gpio_func[j + OFFSET] = func[j];
            end

            adam_periph_gpio #(
                .ADDR_WIDTH (ADDR_WIDTH),
                .DATA_WIDTH (DATA_WIDTH),
                .GPIO_WIDTH (GPIO_WIDTH)
            ) adam_periph_gpio (
                .clk  (clk),
                .rst  (rst || periph_srst[i]),

                .pause_req (periph_pause_req[i]),
                .pause_ack (periph_pause_ack[i]),

                .apb (apb[i]),

                .irq (periph_irq[i]),

                .io   (io),
                .func (func)
            );
        end

        for (genvar i = SPIS_B; i < SPIS_E; i++) begin
            adam_periph_spi #(
                .ADDR_WIDTH(ADDR_WIDTH),
                .DATA_WIDTH(DATA_WIDTH)
            ) adam_periph_spi (
                .clk  (clk),
                .rst  (rst || periph_srst[i]),
                
                .pause_req (periph_pause_req[i]),
                .pause_ack (periph_pause_ack[i]),

                .apb (apb[i]),
                
                .irq (periph_irq[i]),

                .sclk (spi_sclk[i - SPIS_B]),
                .mosi (spi_mosi[i - SPIS_B]),
                .miso (spi_miso[i - SPIS_B]),
                .ss_n (spi_ss_n[i - SPIS_B])
            );
        end

        for (genvar i = TIMERS_B; i < TIMERS_E; i++) begin
            adam_periph_timer #(
                .ADDR_WIDTH(ADDR_WIDTH),
                .DATA_WIDTH(DATA_WIDTH)
            ) adam_periph_timer (
                .clk  (clk),
                .rst  (rst),

                .pause_req (periph_pause_req[i]),
                .pause_ack (periph_pause_ack[i]),

                .apb (apb[i]),
                
                .irq (periph_irq[i])
            );
        end

        for (genvar i = UARTS_B; i < UARTS_E; i++) begin
            adam_periph_uart #(
                .ADDR_WIDTH(ADDR_WIDTH),
                .DATA_WIDTH(DATA_WIDTH)
            ) adam_periph_uart (
                .clk  (clk),
                .rst  (rst || periph_srst[i]),

                .pause_req (periph_pause_req[i]),
                .pause_ack (periph_pause_ack[i]),

                .apb (apb[i]),
                
                .irq (periph_irq[i]),

                .tx (uart_tx[i - UARTS_B]),
                .rx (uart_rx[i - UARTS_B])
            );
        end
    endgenerate

    /* 
     * The following always_comb block might seem complex at first glance.
     * However, its primary purpose is to simplify the always_ff block that
     * follows. To truly understand the logic and purpose of this block, please
     * refer to the always_ff block.
     */
    always_comb begin
        periph_pause_req[0] = sysctrl_pause_req || scp_pause_req[0];

        if (periph_pause_req[0]) begin
            sysctrl_pause_ack = periph_pause_ack[0];
        end
        else begin
            sysctrl_pause_ack = (periph_pause_ack[0] && !scp_pause_req[0]);
        end

        for (int i = 1; i < NO_PERIPHS; i++) begin
            periph_pause_req[i] = others_pause_req || scp_pause_req[i];
        end

        if (others_pause_req) begin
            others_pause_ack = 1;
            for (int i = 1; i < NO_PERIPHS; i++) begin
                // TODO: remove periph_srst[i]
                others_pause_ack &= (periph_pause_ack[i] || periph_srst[i]);
            end
        end
        else begin
            others_pause_ack = 0;
            for (int i = 1; i < NO_PERIPHS; i++) begin
                others_pause_ack |= (periph_pause_ack[i] && !scp_pause_req[i]);
            end
        end

        for (int i = 0; i < NO_PERIPHS; i++) begin
            scp_pause_ack[i] = periph_pause_ack[i];
        end
    end

    always_ff @(posedge clk) begin
        if (rst) begin
            pause_ack <= 0;

            bridge_pause_req  <= 0;
            sysctrl_pause_req <= 0;
            others_pause_req  <= 0;
        end
        else if (pause_req && pause_ack) begin
            // PAUSED
        end
        else if (pause_req && !pause_ack) begin
            // pausing

            if (!bridge_pause_req || !bridge_pause_ack) begin
                // 1. pause bridge
                bridge_pause_req <= 1;
            end
            else if (!sysctrl_pause_req || !sysctrl_pause_ack) begin
                // 2. pause SYSCTRL
                sysctrl_pause_req <= 1;
            end
            else if (!others_pause_req || !others_pause_ack) begin
                // 3. pause other peripherals
                others_pause_req <= 1;
            end
            else begin
                // 4. end
                pause_ack <= 1;
            end
        end
        else if (!pause_req && pause_ack) begin
            // resuming

            if (others_pause_req || others_pause_ack) begin
                // 1. resume other peripherals (if running before pause)
                others_pause_req <= 0;
            end
            else if (sysctrl_pause_req || others_pause_ack) begin
                // 2. resume SYSCTRL (if running before pause)
                sysctrl_pause_req <= 0;
            end
            else if (bridge_pause_req || bridge_pause_ack) begin
                // 3. resume bridge
                bridge_pause_req <= 0;
            end
            else begin
                // 4. end
                pause_ack <= 0;
            end
        end
    end

endmodule