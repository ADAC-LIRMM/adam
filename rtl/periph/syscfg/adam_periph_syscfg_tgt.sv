`include "adam/macros.svh"

module adam_periph_syscfg_tgt #(
    `ADAM_CFG_PARAMS,

    parameter EN_BOOTSTRAP = 0,
    parameter EN_BOOT_ADDR = 0,
    parameter EN_IRQ       = 0
) (
    ADAM_SEQ.Slave   seq,
    ADAM_PAUSE.Slave pause,

    APB.Slave slv,

    input  DATA_T irq_vec,

    output logic      tgt_rst,        
    ADAM_PAUSE.Master tgt_pause,
    output ADDR_T     tgt_boot_addr,
    output logic      tgt_irq
);
  
    typedef enum logic [3:0] {
        IDLE   = 0, // No Action (Default) 
        RESUME = 1,
        PAUSE  = 2,
        STOP   = 3,
        RESET  = 4
    } action_t;

    // Registers ==============================================================
    
    DATA_T mr;  // Maestro Register
    DATA_T sr;  // Status Register
    DATA_T bar; // Boot Address Register
    DATA_T ier; // Interrupt Enable Register

    generate
        if (!EN_BOOT_ADDR) assign bar = '0;
        if (!EN_IRQ)       assign ier = '0;
    endgenerate

    assign tgt_boot_addr = bar;

    // Flags ==================================================================
    
    action_t action;
    logic    paused;
    logic    stopped;

    assign mr = {{(DATA_WIDTH-4){1'b0}}, action};
    assign sr = {{(DATA_WIDTH-2){1'b0}}, stopped, paused};

    action_t state;

    // Interrupt Logic ========================================================
    
    generate
        if (EN_IRQ) begin
            always_comb begin
                tgt_irq = '0;
                for (int i = 0; i < DATA_WIDTH; i++) begin
                    tgt_irq |= ier[i] & irq_vec[i];
                end
            end
        end
        else begin
            assign tgt_irq = '0;
        end
    endgenerate

    // APB Signals ============================================================

    ADAM_PAUSE apb_pause ();

    ADDR_T paddr;
    logic  psel;
    logic  penable;
    logic  pwrite;
    DATA_T pwdata;
    STRB_T pstrb;
    logic  pready;
    DATA_T prdata;
    logic  pslverr;

    ADDR_T index;
    DATA_T mask;

    always_comb begin
        // APB inputs
        paddr   = slv.paddr;
        psel    = slv.psel;
        penable = slv.penable;
        pwrite  = slv.pwrite;
        pwdata  = slv.pwdata;
        pstrb   = slv.pstrb;
        
        // APB outputs
        slv.pready  = pready;
        slv.prdata  = prdata;
        slv.pslverr = pslverr;

        // APB address
        index = paddr[ADDR_WIDTH-1:$clog2(STRB_WIDTH)];

        // APB strobe
        for (int i = 0; i < DATA_WIDTH/8; i++) begin
            mask[i*8 +: 8] = (slv.pstrb[i]) ? 8'hFF : 8'h00; 
        end
    end

    // APB Logic ==============================================================

    always_ff @(posedge seq.clk) begin
        if (seq.rst) begin
            apb_pause.ack <= '1;

            action <= IDLE;

            if (EN_BOOT_ADDR) bar <= RST_BOOT_ADDR;
            if (EN_IRQ)       ier <= '0;

            prdata  <= '0;
            pready  <= '0;
            pslverr <= '0;
        end
        else if (apb_pause.req && apb_pause.ack) begin
            // Paused
        end
        else if (
            (apb_pause.req != apb_pause.ack) &&
            (!pready)
        ) begin
            // Pause or resume
            apb_pause.ack <= apb_pause.req;
        end
        else if (psel && !pready) case (index)    
            // Handle APB transaction

            default: begin // Error: Invalid address
                pslverr <= '1;
                pready  <= '1;
            end

            12'h000: begin // Status Register (SR)
                if (pwrite) begin
                    // Error: Read-only.
                    pslverr <= '1;
                    pready  <= '1;  
                end
                else begin
                    // Read
                    prdata <= sr;
                    pready <= '1;
                end             
            end

            12'h001: begin // Maestro Register (MR)
                if (pwrite) begin
                    if (state == IDLE && action == IDLE) begin
                        // Write
                        action <= action_t'(pwdata[3:0] & mask[3:0]);
                        pready <= '1;
                    end
                    else begin
                        // Error: Maestro is busy
                        pslverr <= '1;
                        pready  <= '1;
                    end
                end
                else begin
                    // Read
                    prdata <= mr;
                    pready <= '1;
                end
            end

            12'h002: begin // Boot Address Register (BAR)
                if (EN_BOOT_ADDR) begin
                    if (pwrite) begin
                        if (state == IDLE && action == IDLE) begin
                            // Write
                            bar <= (pwdata & mask) | (bar & ~mask);
                            pready <= '1;
                        end
                        else begin
                            // Error: Maestro is busy.
                            pslverr <= '1;
                            pready  <= '1;
                        end
                    end
                    else begin
                        // Read
                        prdata <= bar;
                        pready <= '1;
                    end
                end
                else begin
                    // Error: Invalid Address
                    pslverr <= '1;
                    pready  <= '1;
                end              
            end

            12'h003: begin // Interrupt Enable Register (IER)
                if (EN_IRQ) begin
                    if (pwrite) begin
                        // Write
                        ier <= (pwdata & mask) | (ier & ~mask);
                        pready <= '1;
                    end
                    else begin
                        // Read
                        prdata <= ier;
                        pready <= '1;
                    end
                end   
                else begin
                    // Error: Invalid Address
                    pslverr <= '1;
                    pready  <= '1;
                end  
            end
        endcase
        else if (psel && penable && pready) begin
            // Transaction completed.
            prdata  <= '0;
            pready  <= '0;
            pslverr <= '0;

            action <= IDLE;
        end
    end

    // Maestro Logic ==========================================================

    ADAM_PAUSE maestro_pause ();

    always_ff @(posedge seq.clk) begin
        if (seq.rst) begin
            maestro_pause.ack <= '1;

            tgt_rst       <= '1;
            tgt_pause.req <= '1;

            state <= (EN_BOOTSTRAP) ? RESUME : IDLE;

            paused  <= '1;
            stopped <= '1;
        end
        else if (maestro_pause.req && maestro_pause.ack) begin
            // paused
        end
        else if (
            (maestro_pause.req != maestro_pause.ack) &&
            ((state == IDLE || maestro_pause.ack) && action == IDLE)
        ) begin
            // pause or resume
            maestro_pause.ack <= maestro_pause.req;
        end
        else case (state)
            default: begin // IDLE
                state <= action;
            end

            RESUME: begin 
                if (!tgt_pause.req && !tgt_pause.ack) begin
                    paused  <= '0;
                    stopped <= '0;
                    state   <= IDLE;
                end

                tgt_rst       <= '0;
                tgt_pause.req <= '0;
            end

            PAUSE: begin 
                if (tgt_pause.req && tgt_pause.ack) begin
                    paused <= '1;
                    state  <= IDLE;
                end

                tgt_pause.req <= '1;
            end

            STOP: begin 
                if (tgt_pause.req && tgt_pause.ack) begin
                    tgt_rst <= '1;
                    paused  <= '1;
                    stopped <= '1;
                    state   <= IDLE;
                end

                tgt_pause.req <= '1;
            end

            RESET: begin 
                if (tgt_pause.req && tgt_pause.ack) begin
                    tgt_rst <= '1;
                    paused  <= '1;
                    stopped <= '1;
                    state   <= RESUME;
                end

                tgt_pause.req <= '1;
            end
        endcase
    end

    // pause demux ============================================================

    ADAM_PAUSE pause_null ();

    adam_pause_demux #(
        .NO_MSTS  (2),
        .PARALLEL (0)
    ) adam_pause_demux (
        .seq (seq),

        .slv (pause),
        .mst ('{apb_pause, maestro_pause, pause_null})
    );

endmodule