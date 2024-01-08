`include "adam/macros.svh"

module adam_periph #(
    `ADAM_CFG_PARAMS,

    parameter NO_GPIOS  = 1,
    parameter NO_SPIS   = 1,
    parameter NO_TIMERS = 1,
    parameter NO_UARTS  = 1,

    // Dependent parameters, DO NOT OVERRIDE!

    parameter NO_PERIPHS = NO_GPIOS + NO_SPIS + NO_TIMERS + NO_UARTS
) (
    ADAM_SEQ.Slave   seq,

    logic            periph_rst   [NO_PERIPHS+1],
    ADAM_PAUSE.Slave periph_pause [NO_PERIPHS+1],
    APB.Slave        periph_apb   [NO_PERIPHS+1],
    output logic     periph_irq   [NO_PERIPHS+1],

    // IO =====================================================================

    ADAM_IO.Master     gpio_io   [NO_GPIOS*GPIO_WIDTH+1],
    output logic [1:0] gpio_func [NO_GPIOS*GPIO_WIDTH+1],
    
    ADAM_IO.Master spi_sclk [NO_SPIS+1],
    ADAM_IO.Master spi_mosi [NO_SPIS+1],
    ADAM_IO.Master spi_miso [NO_SPIS+1],
    ADAM_IO.Master spi_ss_n [NO_SPIS+1],

    ADAM_IO.Master uart_tx [NO_UARTS+1],
    ADAM_IO.Master uart_rx [NO_UARTS+1]
);

    // instatiation ===========================================================

    generate
        localparam GPIOS_S = 0;
        localparam GPIOS_E = GPIOS_S + NO_GPIOS;

        localparam SPIS_S = GPIOS_E;
        localparam SPIS_E = SPIS_S + NO_SPIS;

        localparam TIMERS_S = SPIS_E;
        localparam TIMERS_E = TIMERS_S + NO_TIMERS;

        localparam UARTS_S = TIMERS_E;
        localparam UARTS_E = UARTS_S + NO_UARTS;

        for (genvar i = GPIOS_S; i < GPIOS_E; i++) begin
            localparam offset = GPIO_WIDTH*(i-GPIOS_S);

            ADAM_IO     io   [GPIO_WIDTH] ();
            logic [1:0] func [GPIO_WIDTH];

            for (genvar j = 0; j < GPIO_WIDTH; j++) begin
                `ADAM_IO_ASSIGN(gpio_io[j+offset], io[j]);
                assign gpio_func[j+offset] = func[j];
            end

            adam_periph_gpio #(
                `ADAM_CFG_PARAMS_MAP
            ) adam_periph_gpio (
                .seq   (seq),
                .pause (periph_pause[i]),
                
                .slv (periph_apb[i]),

                .irq (periph_irq[i]),

                .io   (io),
                .func (func)
            );
        end

        for (genvar i = SPIS_S; i < SPIS_E; i++) begin
            adam_periph_spi #(
                `ADAM_CFG_PARAMS_MAP
            ) adam_periph_spi (
                .seq   (seq),
                .pause (periph_pause[i]),
                
                .slv (periph_apb[i]),

                .irq (periph_irq[i]),

                .sclk (spi_sclk[i-SPIS_S]),
                .mosi (spi_mosi[i-SPIS_S]),
                .miso (spi_miso[i-SPIS_S]),
                .ss_n (spi_ss_n[i-SPIS_S])
            );
        end

        for (genvar i = TIMERS_S; i < TIMERS_E; i++) begin
            adam_periph_timer #(
                `ADAM_CFG_PARAMS_MAP
            ) adam_periph_timer (
                .seq   (seq),
                .pause (periph_pause[i]),
                
                .slv   (periph_apb[i]),

                .irq (periph_irq[i])
            );
        end

        for (genvar i = UARTS_S; i < UARTS_E; i++) begin
            adam_periph_uart #(
                `ADAM_CFG_PARAMS_MAP
            ) adam_periph_uart (
                .seq   (seq),
                .pause (periph_pause[i]),

                .slv   (periph_apb[i]),

                .irq (periph_irq[i]),

                .tx (uart_tx[i-UARTS_S]),
                .rx (uart_rx[i-UARTS_S])
            );
        end
    endgenerate

endmodule