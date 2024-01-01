`include "adam/macros.svh"

module adam_periph_gpio #(
    `ADAM_CFG_PARAMS
) (    
    ADAM_SEQ.Slave   seq,
    ADAM_PAUSE.Slave pause,

    APB.Slave slv,

    output logic irq,

    ADAM_IO.Master       io [GPIO_WIDTH],
    output logic [1:0] func [GPIO_WIDTH] 
);

    // Registers
    GPIO_T idr;
    GPIO_T odr;
    GPIO_T moder;
    GPIO_T otyper;
    DATA_T fsr [2];
    GPIO_T ier;

    // APB
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

    generate
        for (genvar i = 0; i < GPIO_WIDTH; i++) begin
            always_comb begin
                idr[i]      = io[i].i;
                io[i].o     = odr[i];
                io[i].mode  = moder[i];
                io[i].otype = otyper[i];
            end  
        end
    endgenerate

    always_comb begin
        automatic int word;
        automatic int bit_;

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

        // Function Select Register (FSR)
        for (int i = 0; i < GPIO_WIDTH; i++) begin
            for (int j = 0; j < 2; j++) begin
                word = (2*i + j) / DATA_WIDTH;
                bit_ = (2*i + j) % DATA_WIDTH;
                func[i][j] = fsr[word][bit_];
            end
        end 

        // IRQ
        irq = 0;
        if (!pause.req || !pause.ack) begin 
            for (int i = 0; i < GPIO_WIDTH; i++) begin
                irq |= ier[i] & idr[i];
            end
        end
    end

    always_ff @(posedge seq.clk) begin
        if (seq.rst) begin
            odr     <= 0;
            moder   <= 0;
            otyper  <= 0;
            fsr[0]  <= 0;
            fsr[1]  <= 0;
            ier     <= 0;

            prdata  <= 0;
            pready  <= 0;
            pslverr <= 0;

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
                 
                12'h000: begin // Input Data Register (IDR)
                    if (pwrite) begin
                        // read only
                        pslverr <= 1;
                    end
                    else begin
                        prdata <= idr;
                    end

                    pready <= 1;                  
                end

                12'h001: begin // Output Data Register (ODR)
                    if (pwrite) begin
                        odr <= (pwdata & mask) | (odr & ~mask);
                    end
                    else begin
                        prdata <= odr;
                    end

                    pready <= 1;
                end

                12'h002: begin // Mode Register (MODER)
                    if (pwrite) begin
                        moder <= (pwdata & mask) | (moder & ~mask);
                    end
                    else begin
                        prdata <= moder;
                    end 

                    pready <= 1;
                end

                12'h003: begin // Output Type Register (OTYPER)
                    if (pwrite) begin
                        otyper <= (pwdata & mask) | (otyper & ~mask);
                    end
                    else begin
                        prdata <= otyper;
                    end

                    pready <= 1;
                end

                16'h004: begin // Function Select Register (FSR)
                    if (pwrite) begin
                        fsr[0] <= (pwdata & mask) | (fsr[0] & ~mask);
                    end
                    else begin
                        prdata <= fsr[0];
                    end

                    pready <= 1;
                end

                16'h005: begin // Function Select Register (FSR)
                    if (pwrite) begin
                        fsr[1] <= (pwdata & mask) | (fsr[1] & ~mask);
                    end
                    else begin
                        prdata <= fsr[1];
                    end

                    pready <= 1;
                end

                16'h006: begin // Interrupt Enable Register (IER)
                    if (pwrite) begin
                        ier <= (pwdata & mask) | (ier & ~mask);
                    end
                    else begin
                        prdata <= ier;
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
        end
    end

endmodule
