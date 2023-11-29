module adam_periph_timer #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32
) (    
    ADAM_SEQ.Slave   seq,
    ADAM_PAUSE.Slave pause,

    APB.Slave apb,

    output logic irq
);
    localparam STRB_WIDTH = DATA_WIDTH/8;
    
    typedef logic [ADDR_WIDTH-1:0] addr_t;
    typedef logic [DATA_WIDTH-1:0] data_t;
    typedef logic [STRB_WIDTH-1:0] strb_t;
    typedef logic [DATA_WIDTH-1:0] reg_t;

    // Registers
    reg_t control;
    reg_t prescaler;
    reg_t value;
    reg_t auto_reload;
    reg_t events;
    reg_t interrupt_enable;

    // Control Register (CR)
    logic peripheral_enable;

    // Event Register (ER)
    logic auto_reload_event;

    // Interrupt Enable Register (IER)
    logic auto_reload_event_ie;

    // APB
    addr_t paddr;
    logic  psel;
    logic  penable;
    logic  pwrite;
    data_t pwdata;
    strb_t pstrb;
    logic  pready;
    data_t prdata;
    logic  pslverr;
    
    addr_t index;
    reg_t  mask;

    reg_t clk_count;

    always_comb begin

        // APB inputs
        paddr   = apb.paddr;
        psel    = apb.psel;
        penable = apb.penable;
        pwrite  = apb.pwrite;
        pwdata  = apb.pwdata;
        pstrb   = apb.pstrb;
        
        // APB outputs
        apb.pready  = pready;
        apb.prdata  = prdata;
        apb.pslverr = pslverr;

        // APB address
        index = paddr[ADDR_WIDTH-1:$clog2(STRB_WIDTH)];

        // APB strobe
        for (int i = 0; i < DATA_WIDTH/8; i++) begin
            mask[i*8 +: 8] = (apb.pstrb[i]) ? 8'hFF : 8'h00; 
        end
        
        // Control Register (CR) 
        peripheral_enable = control[0];

        // Event Register (ER)
        auto_reload_event = events[0];

        // Interrupt Enable Register (IER)
        auto_reload_event_ie = interrupt_enable[0];

        // IRQ
        irq = (peripheral_enable && !pause.ack) && (
            (auto_reload_event && auto_reload_event_ie)
        );
    end

    always_ff @(posedge seq.clk) begin
        if (seq.rst) begin
            control          <= 0;
            prescaler        <= 0;
            value            <= 0;
            events           <= 0;
            interrupt_enable <= 0;

            prdata  <= 0;
            pready  <= 0;
            pslverr <= 0;

            clk_count <= 0;

            pause.ack <= 1;
        end
        else if (pause.req && pause.ack) begin
            // PAUSED
        end
        else begin
            if (
                (!pause.req) &&   // no pause request
                (psel && !pready) // pending APB transaction
            ) case (index)

                12'h000: begin // Control Register (CR)
                    if (pwrite) begin
                        control <= (pwdata & mask) | (control & ~mask);
                    end
                    else begin
                        prdata  <= control;
                    end

                    pready <= 1;                  
                end

                12'h001: begin // Prescaler Register (PR)
                    if (pwrite) begin
                        prescaler <= (pwdata & mask) | (prescaler & ~mask);
                    end
                    else begin
                        prdata <= prescaler;
                    end

                    pready <= 1;
                end

                12'h002: begin // Value Register (VR)
                    if (pwrite) begin
                        value <= (pwdata & mask) | (value & ~mask);
                    end
                    else begin
                        prdata <= value;
                    end 

                    pready <= 1;
                end

                12'h003: begin // Auto Reload Register (ARR)
                    if (pwrite) begin
                        auto_reload <= (pwdata & mask) | (auto_reload & ~mask);
                    end
                    else begin
                        prdata <= auto_reload;
                    end

                    pready <= 1;
                end

                12'h004: begin // Event Register (ER)
                    if (pwrite) begin
                        // clear
                        events <= events & ~(pwdata & mask);
                    end
                    else begin
                        prdata <= events;
                    end

                    pready <= 1;
                end

                12'h005: begin // Interrupt Enable Register (IER)
                    if (pwrite) begin
                        interrupt_enable <=
                            (pwdata & mask) | (interrupt_enable & ~mask);
                    end
                    else begin
                        prdata <= interrupt_enable;
                    end

                    pready <= 1;
                end

                default: begin // Error
                    pready  <= 1;
                    pslverr <= 1;
                end
            endcase
            else if (
                (!pause.ack) &&             // not paused
                (psel && penable && pready) // transaction completed
            ) begin
                // reset APB outputs.
                prdata  <= 0;
                pready  <= 0;
                pslverr <= 0;
            end
            else if (pause.req && !pause.ack) begin
                // pause
                pause.ack <= 1;

                // tie APB interface off
                prdata  <= 0;
                pready  <= 1;
                pslverr <= 1;
            end
            else if (!pause.req && pause.ack) begin
                // resume
                pause.ack <= 0;

                // reset APB outputs
                prdata  <= 0;
                pready  <= 0;
                pslverr <= 0;
            end

            if (peripheral_enable) begin
                if (clk_count < prescaler) begin
                    clk_count <= clk_count + 1;
                end
                else begin
                    clk_count <= 0;
                
                    if (value == auto_reload) begin
                        events[0] <= 1; // Auto Reload Event
                        value     <= 0;
                    end
                    else begin
                        value <= value + 1;
                    end
                end
            end
            else begin
                clk_count <= 0;
                events    <= 0;
            end
        end
    end

endmodule
