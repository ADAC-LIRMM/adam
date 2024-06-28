`include "adam/macros.svh"

module adam_periph_spi #(
    `ADAM_CFG_PARAMS
) (
    ADAM_SEQ.Slave   seq,
    ADAM_PAUSE.Slave pause,

    APB.Slave slv,

    output logic irq,

    ADAM_IO.Master sclk,
    ADAM_IO.Master mosi,
    ADAM_IO.Master miso,
    ADAM_IO.Master ss_n
);
    
    ADAM_PAUSE phy_pause ();
    ADAM_PAUSE slv_pause ();

    // Data (TX)
    DATA_T tx_buf;
    ADAM_STREAM #(
        .T (DATA_T)
    ) tx ();
    
    // Data (RX)
    DATA_T rx_buf;
    ADAM_STREAM #(
        .T (DATA_T)
    ) rx ();

    // Normal Registers
    DATA_T control;
    DATA_T status;
    DATA_T baud_rate;
    DATA_T interrupt_enable;

    // Control Register (CR)
    logic       periph_enable;
    logic       tx_enable;
    logic       rx_enable;
    logic       mode_select;
    logic       clock_phase;
    logic       clock_polarity;
    logic       data_order;
    logic [7:0] data_length;

    // Status Register (SR)
    logic tx_buf_empty;   // Transmit Buffer Empty
    logic rx_buf_full; // Receive Buffer Full
    
    // Interrupt Enable Regiter (IER)
    logic tx_buf_empty_ie; // Transmit Buffer Empty Interrupt Enable
    logic rx_buf_full_ie;  // Receiver Buffer Full Interrupt Enable

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
    DATA_T  mask;

    adam_periph_spi_phy #(
        `ADAM_CFG_PARAMS_MAP
    ) adam_periph_spi_phy (
        .seq   (seq),
        .pause (phy_pause),
        
        .tx_enable      (tx_enable),
        .rx_enable      (rx_enable),
        .mode_select    (mode_select),
        .clock_phase    (clock_phase),
        .clock_polarity (clock_polarity),
        .data_order     (data_order),
        .data_length    (data_length),
        .baud_rate      (baud_rate),

        .tx (tx),
        .rx (rx),

        .sclk (sclk),
        .mosi (mosi),
        .miso (miso),
        .ss_n (ss_n)
    );


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
        
        // Control Register (CR)
        periph_enable  = control[0];
        tx_enable      = control[1];
        rx_enable      = control[2];
        mode_select    = control[3];
        clock_phase    = control[4];
        clock_polarity = control[5];
        data_order     = control[6];
        data_length    = control[15:8];

        // Status Register (SR)
        status[0] = tx_buf_empty;
        status[1] = rx_buf_full;
        status[DATA_WIDTH-1:2] = 0;

        // Interrupt Enable Register (IER)
        tx_buf_empty_ie  = interrupt_enable[0];
        rx_buf_full_ie   = interrupt_enable[1];

        // IRQ
        irq = (periph_enable && !pause.ack) && (
            (tx_buf_empty && tx_buf_empty_ie && tx_enable) |
            (rx_buf_full  && rx_buf_full_ie  && rx_enable)
        );

        slv_pause.req = pause.req;

        // pause.ack
        if (pause.req) begin
            pause.ack = slv_pause.ack && phy_pause.ack;
        end
        else begin
            pause.ack = slv_pause.ack || phy_pause.ack;
        end

        // Submodule transfers
        tx.valid = !tx_buf_empty;
        rx.ready = !rx_buf_full;

        tx.data = tx_buf;
    end

    always_ff @(posedge seq.clk) begin
        automatic DATA_T new_control;

        if (seq.rst) begin
            tx_buf           <= 0;
            rx_buf           <= 0;
            control          <= 0;
            baud_rate        <= 0;
            interrupt_enable <= 0;

            tx_buf_empty <= 1;
            rx_buf_full  <= 0;

            prdata  <= 0;
            pready  <= 0;
            pslverr <= 0;

            phy_pause.req <= 1;

            slv_pause.ack <= 1;
        end
        else if (slv_pause.req && slv_pause.ack) begin
            // PAUSED
        end
        else begin
            if (
                (!slv_pause.req) &&   // no pause request
                (psel && !pready) // pending APB transaction
            ) case (index)

                12'h000: begin // Data Register (DR)
                    if (pwrite) begin 
                        if (periph_enable && tx_enable && tx_buf_empty) begin
                            // Transmission
                            tx_buf <= pwdata;
                            tx_buf_empty <= 0;
                            pready <= 1;
                        end
                        else begin
                            // Transmission disabled, error
                            pslverr <= 1;
                            pready <= 1;
                        end
                    end
                    else begin
                        if(periph_enable && rx_enable && rx_buf_full) begin
                            // Reception
                            prdata <= rx_buf;
                            rx_buf_full <= 0;
                            pready <= 1;
                        end
                        else begin
                            // Reception disabled, error
                            pready <= 1;
                            pslverr <= 1;
                        end
                    end                   
                end

                12'h001: begin // Control Register (CR)
                    if (pwrite) begin
                        
                        new_control = (pwdata & mask) | (control & ~mask);
                        
                        if (new_control != control && new_control[0]) begin
                            // changes will affect the phy
                            if (phy_pause.req && phy_pause.ack) begin
                                // on phy pause forward change
                                control <= new_control;
                            end
                            else begin
                                // else request pause
                                phy_pause.req <= 1;
                            end
                        end
                        else begin
                            // phy resume (or changes wont affect it)
                            phy_pause.req <= 0;
                            control <= new_control;
                            pready <= 1;
                        end 
                    
                    end
                    else begin
                        prdata <= control;
                        pready <= 1;
                    end
                end

                12'h002: begin // Status Register (SR)
                    if (pwrite) begin
                        pslverr <= 1; // read only
                    end
                    else begin
                        prdata <= status;
                    end 

                    pready <= 1;
                end

                12'h003: begin // Baud Rate Register (BRR)
                    if (pwrite) begin
                        baud_rate <= (pwdata & mask) | (baud_rate & ~mask);
                    end
                    else begin
                        prdata <= baud_rate;
                    end

                    pready <= 1;
                end

                12'h004: begin // Interrupt Enable Register (IER)
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
                    pready <= 1;
                    pslverr <= 1;
                end
            endcase
            else if (
                (!slv_pause.ack) &&         // not paused
                (psel && penable && pready) // transaction completed
            ) begin
                // reset APB outputs.
                prdata  <= 0;
                pready  <= 0;
                pslverr <= 0;
            end
            else if (
                (pause.req && !slv_pause.ack) &&   // slv pause init
                (!phy_pause.req && !phy_pause.ack) // no phy pause
            ) begin
                // pause
                phy_pause.req <= 1;
                slv_pause.ack <= 1;

                // tie APB interface off
                prdata  <= 0;
                pready  <= 1;
                pslverr <= 1;
            end
            else if (
                (!slv_pause.req && slv_pause.ack) && // slv pause end
                (phy_pause.req && phy_pause.ack)     // phy pause
            ) begin
                // resume
                phy_pause.req <= 0;
                slv_pause.ack <= 0;

                // reset APB outputs
                prdata  <= 0;
                pready  <= 0;
                pslverr <= 0;
            end

            /*
             * Due to combinary logic, it is garanteed that the previous
             * assigments to tx_buf_empty and rx_buf_full will not be
             * overwritten by the following assigments.
             */
            
            // TX complete, buffer is empty
            if (tx.valid && tx.ready) begin
                tx_buf_empty <= 1;
            end

            // RX complete, buffer is full
            if (rx.valid && rx.ready) begin
                rx_buf <= rx.data;
                rx_buf_full <= 1;
            end
        end
    end

endmodule