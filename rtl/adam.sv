`include "adam/macros.svh"
`include "apb/assign.svh"
`include "axi/assign.svh"

`define APB_I APB #( \
    .ADDR_WIDTH (ADDR_WIDTH), \
    .DATA_WIDTH (DATA_WIDTH) \
)

`define AXIL_I AXI_LITE #( \
    .AXI_ADDR_WIDTH (ADDR_WIDTH), \
    .AXI_DATA_WIDTH (DATA_WIDTH) \
)

module adam #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32,
    parameter GPIO_WIDTH = 16,

    parameter NO_CPUS = 2,
    parameter NO_DMAS = 2,
    parameter NO_MEMS = 2,
    
    parameter EN_LPCPU = 1,
    parameter EN_LPMEM = 1,
    parameter EN_DEBUG = 1,

    parameter NO_LSBP_GPIOS  = 2,
    parameter NO_LSBP_SPIS   = 2,
    parameter NO_LSBP_TIMERS = 2,
    parameter NO_LSBP_UARTS  = 2,

    parameter BOOT_ADDR = 32'h0000_0000;

    // Dependent parameters bellow, do not override.

    parameter STRB_WIDTH  = DATA_WIDTH/8,

    parameter type addr_t = logic [ADDR_WIDTH-1:0],
    parameter type data_t = logic [DATA_WIDTH-1:0],
    parameter type strb_t = logic [STRB_WIDTH-1:0]
) (
    // lsdom ==================================================================

    ADAM_SEQ.Slave   lsdom_seq,
    ADAM_PAUSE.Slave lsdom_pause,

    ADAM_SEQ.Master   lsdom_mem_seq,
    ADAM_PAUSE.Master lsdom_mem_pause,
    AXI_LITE.Master   lsdom_mem_axil,

    // hsdom ==================================================================

    ADAM_SEQ.Slave hsdom_seq,

    ADAM_SEQ.Master   hsdom_mem_seq   [NO_MEMS],
    ADAM_PAUSE.Master hsdom_mem_pause [NO_MEMS],
    AXI_LITE.Master   hsdom_mem_axil  [NO_MEMS],

    // async ==================================================================
    
    ADAM_IO.Master     gpio_io   [NO_GPIOS*GPIO_WIDTH],
    output logic [1:0] gpio_func [NO_GPIOS*GPIO_WIDTH],
    
    ADAM_IO.Master spi_sclk [NO_SPIS],
    ADAM_IO.Master spi_mosi [NO_SPIS],
    ADAM_IO.Master spi_miso [NO_SPIS],
    ADAM_IO.Master spi_ss_n [NO_SPIS],

    ADAM_IO.Master uart_tx [NO_UARTS],
    ADAM_IO.Master uart_rx [NO_UARTS]
);

    localparam NO_DMAS = 0;
    localparam NO_HSIP = 0;
    localparam NO_LSIP = 0;

    localparam NO_LSBP = NO_LSBP_GPIOS + NO_LSBP_SPIS + NO_LSBP_TIMERS +
        NO_LSBP_UARTS;
    
    // lsdom - lpcpu ==========================================================

    `AXIL_I lsdom_lpcpu_axil [2] ();

    ADAM_SEQ   lsdom_lpcpu_seq ();
    ADAM_PAUSE lsdom_lpcpu_pause ();
    
    logic lsdom_lpcpu_irq;

    generate
        if (EN_LPCPU) begin
            `ADAM_CORE_LPCPU lsdom_lpcpu (
                .seq   (lsdom_lpcpu_seq),
                .pause (lsdom_lpcpu_pause),

                .boot_addr (BOOT_ADDR),
                .hart_id   ('0),

                .inst_axil (lsdom_lpcpu[0]),
                .data_axil (lsdom_lpcpu[1]),

                .irq (lsdom_lpcpu_irq),
            );
        end
    endgenerate

    // lsdom - syscfg =========================================================

    `AXIL_I lsdom_syscfg_axil ();

    `ADAM_AXIL_SLV_TIE_OFF(lsdom_syscfg);

    // lsdom - lsbp ===========================================================

    ADAM_SEQ   lsdom_lsbp_seq   [NO_LSIP] ();
    ADAM_PAUSE lsdom_lsbp_pause [NO_LSIP] ();

    `AXIL_I lsdom_lsbp_apb [NO_LSIP] ();
    
    logic lsdom_lsbp_irq [NO_LSIP];

    generate
        localparam LSBP_GPIOS_S = 0;
        localparam LSBP_GPIOS_E = LSBP_GPIOS_S + NO_LSBP_GPIOS;

        localparam LSBP_SPIS_S = LSBP_GPIOS_E;
        localparam LSBP_SPIS_E = LSBP_SPIS_S + NO_LSBP_SPIS;

        localparam LSBP_TIMERS_S = LSBP_SPIS_E;
        localparam LSBP_TIMERS_E = LSBP_TIMERS_S + NO_LSBP_TIMERS;

        localparam LSBP_UARTS_S = LSBP_TIMERS_E;
        localparam LSBP_UARTS_E = LSBP_UARTS_S + NO_LSBP_UARTS;

        for (genvar i = LSBP_GPIOS_S; i < LSBP_GPIOS_S; i++) begin
            localparam OFFSET = GPIO_WIDTH*(i - LSBP_GPIOS_S);

            ADAM_IO     io   [GPIO_WIDTH] ();
            logic [1:0] func [GPIO_WIDTH];

            for (genvar j = 0; j < GPIO_WIDTH; j++) begin
                `ADAM_IO_ASSIGN(gpio_io[j + OFFSET], io[j]);
                assign gpio_func[j + OFFSET] = func[j];
            end

            adam_periph_gpio #(
                .ADDR_WIDTH (ADDR_WIDTH),
                .DATA_WIDTH (DATA_WIDTH),
                .GPIO_WIDTH (GPIO_WIDTH)
            ) lsbp_gpio (
                .seq   (lsdom_lsbp_seq[i]),
                .pause (lsdom_lsbp_pause[i]),
                
                .apb (lsdom_lsbp_apb[i]),

                .irq (lsdom_lsbp_irq[i]),

                .io   (io),
                .func (func)
            );
        end

        for (genvar i = LSBP_SPIS_S; i < LSBP_SPIS_E; i++) begin
            adam_periph_spi #(
                .ADDR_WIDTH (ADDR_WIDTH),
                .DATA_WIDTH (DATA_WIDTH)
            ) lsbp_spi (
                .seq   (lsdom_lsbp_seq[i]),
                .pause (lsdom_lsbp_pause[i]),
                
                .apb (lsdom_lsbp_apb[i]),

                .irq (lsdom_lsbp_irq[i]),

                .sclk (spi_sclk[i - LSBP_SPIS_S]),
                .mosi (spi_mosi[i - LSBP_SPIS_S]),
                .miso (spi_miso[i - LSBP_SPIS_S]),
                .ss_n (spi_ss_n[i - LSBP_SPIS_S])
            );
        end

        for (genvar i = LSBP_TIMERS_S; i < LSBP_TIMERS_E; i++) begin
            adam_periph_timer #(
                .ADDR_WIDTH (ADDR_WIDTH),
                .DATA_WIDTH (DATA_WIDTH)
            ) lsbp_timer (
                .seq   (lsdom_lsbp_seq[i]),
                .pause (lsdom_lsbp_pause[i]),
                
                .apb   (lsdom_lsbp_apb[i]),

                .irq (lsdom_lsbp_irq[i])
            );
        end

        for (genvar i = LSBP_UARTS_S; i < LSBP_UARTS_E; i++) begin
            adam_periph_uart #(
                .ADDR_WIDTH(ADDR_WIDTH),
                .DATA_WIDTH(DATA_WIDTH)
            ) lsbp_uart (
                .seq   (lsdom_lsbp_seq[i]),
                .pause (lsdom_lsbp_pause[i]),
                .apb   (lsdom_lsbp_apb[i]),

                .irq (lsdom_lsbp_irq[i]),

                .tx (uart_tx[i - LSBP_UARTS_S]),
                .rx (uart_rx[i - LSBP_UARTS_S])
            );
        end
    endgenerate

    // lsdom - lsip ===========================================================

    `AXIL_I lsdom_lsip_apb [NO_LSIP] ();

    generate
        for (genvar i = 0; i < NO_LSIP; i++) begin
            `ADAM_AXIL_SLV_TIE_OFF(lsdom_lsip_apb[i]);
        end
    endgenerate

    // hsdom - cpus ===========================================================

    `AXIL_I hsdom_cpus [2*NO_CPUS] ();

    ADAM_SEQ   hsdom_cpus_seq   [NO_CPUS] ();
    ADAM_PAUSE hsdom_cpus_pause [NO_CPUS] ();

    generate
        for (genvar i = 0; i < NO_CPUS; i++) begin
            `ADAM_CORE_CPU hsdom_cpu (
                .seq   (hsdom_cpus_seq),
                .pause (hsdom_cpus_pause),

                .boot_addr ('0),
                .hart_id   ('0),

                .inst_axil (hsdom_cpus[2*i + 0]),
                .data_axil (hsdom_cpus[2*i + 1]),

                .irq ('0),
            );
        end
    endgenerate

    // hsdom - cpus ===========================================================

    `AXIL_I hsdom_dmas [NO_DMAS] ();

    generate
        for (int i = 0; i < NO_DMAS; i++) begin
            `ADAM_PAUSE_SLV_TIE_OFF(hsdom_dmas[i]);
        end
    endgenerate

    // hsdom - debug ==========================================================

    `AXIL_I hsdom_debug_slv ();
    `AXIL_I hsdom_debug_mst ();

    `ADAM_PAUSE_MST_TIE_OFF(hsdom_debug_slv);
    `ADAM_PAUSE_SLV_TIE_OFF(hsdom_debug_mst);

    // adam_fabric ============================================================

    adam_fabric #(
        .ADDR_WIDTH (ADDR_WIDTH),
        .DATA_WIDTH (DATA_WIDTH),

        .MAX_TRANS (MAX_TRANS),
        
        .NO_CPUS (NO_CPUS),
        .NO_DMAS (NO_DMAS),
        .NO_MEMS (NO_MEMS),
        .NO_HSIP (NO_HSIP),
        .NO_LSBP (NO_LSBP),
        .NO_LSIP (NO_LSIP),

        .EN_LPCPU (EN_LPCPU),
        .EN_LPMEM (EN_LPMEM),
        .EN_LSBP  (EN_LSBP),
        .EN_LSIP  (EN_LSIP),
        .EN_DEBUG (EN_DEBUG)
    ) adam_fabric (
        .lsdom_seq        (lsdom_seq),
        .lsdom_pause      (lsdom_pause),
        .lsdom_pause_lsbp (lsdom_pause_lsbp),
        .lsdom_pause_lsip (lsdom_pause_lsip),
    
        .lsdom_lpcpu  (lsdom_lpcpu),

        .lsdom_lpmem  (lsdom_lpmem),
        .lsdom_syscfg (lsdom_syscfg),
        .lsdom_lsbp   (lsdom_lsbp),
        .lsdom_lsip   (lsdom_lsip),

        .hsdom_seq   (hsdom_seq),
        .hsdom_pause (hsdom_pause),

        .hsdom_cpus      (hsdom_cpus),
        .hsdom_dmas      (hsdom_dmas),
        .hsdom_debug_slv (hsdom_debug_slv),

        .hsdom_mems      (hsdom_mems),
        .hsdom_hsip      (hsdom_hsip),
        .hsdom_debug_mst (hsdom_debug_mst)
    );

endmodule