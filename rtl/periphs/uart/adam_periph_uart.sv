module adam_periph_uart #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32
) (
    input logic clk,
    input logic rst,
    input logic test,

    input  logic pause_req,
    output logic pause_ack,

    APB.Slave apb,

    output logic irq,

    ADAM_IO.Master tx,
    ADAM_IO.Master rx
);

    localparam STRB_WIDTH = DATA_WIDTH/8;
    
    typedef logic [ADDR_WIDTH-1:0] addr_t;
    typedef logic [DATA_WIDTH-1:0] data_t;
    typedef logic [STRB_WIDTH-1:0] strb_t;
    typedef logic [DATA_WIDTH-1:0] reg_t;

    logic tx_clk;
    logic tx_clk_en;
    logic tx_pause_req;
    logic tx_pause_ack;

    logic rx_clk;
    logic rx_clk_en;
    logic rx_pause_req;
    logic rx_pause_ack;

    logic apb_pause_ack;

    // Data (TX)
    reg_t tx_buf;
    reg_t tx_data;
    logic tx_data_valid;
    logic tx_data_ready;
    
    // Data (RX)
    reg_t rx_buf;
    reg_t rx_data;
    logic rx_data_valid;
    logic rx_data_ready;

    // Normal Registers
    reg_t control;
    reg_t status;
    reg_t baud_rate;
    reg_t interrupt_enable;

    // Control Register (CR)
    logic       periph_enable;
    logic       tx_enable;
    logic       rx_enable;
    logic       parity_control;
    logic       parity_select;
    logic       stop_bits;
    logic [3:0] data_length;

    // Status Register (SR)
    logic tx_buf_empty;   // Transmit Buffer Empty
    logic rx_buf_full; // Receive Buffer Full
    
    // Interrupt Enable Regiter (IER)
    logic tx_buf_empty_ie; // Transmit Buffer Empty Interrupt Enable
    logic rx_buf_full_ie;  // Receiver Buffer Full Interrupt Enable

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

    logic tx_o;
    logic rx_i;

    adam_clk_gate tx_adam_clk_gate (
        .clk  (clk),
        .rst  (rst),
        .test (test),
        
        .enable    (tx_clk_en),
        .gated_clk (tx_clk)
    );

    adam_clk_gate rx_adam_clk_gate (
        .clk  (clk),
        .rst  (rst),
        .test (test),
        
        .enable    (rx_clk_en),
        .gated_clk (rx_clk)
    );

    adam_periph_uart_tx #(
        .DATA_WIDTH(DATA_WIDTH)
    ) adam_periph_uart_tx (
        .clk  (tx_clk),
        .rst  (rst),
        .test (test),

        .pause_req (tx_pause_req),
        .pause_ack (tx_pause_ack),

        .parity_select  (parity_select),
        .parity_control (parity_control),
        .data_length    (data_length),
        .stop_bits      (stop_bits),
        .baud_rate      (baud_rate),

        .data       (tx_data),
        .data_valid (tx_data_valid),
        .data_ready (tx_data_ready),
    
        .tx (tx_o)
    );

    adam_periph_uart_rx #(
        .DATA_WIDTH(DATA_WIDTH)
    ) adam_periph_uart_rx (
        .clk  (rx_clk),
        .rst  (rst),
        .test (test),

        .pause_req (rx_pause_req),
        .pause_ack (rx_pause_ack),

        .parity_select  (parity_select),
        .parity_control (parity_control),
        .data_length    (data_length),
        .stop_bits      (stop_bits),
        .baud_rate      (baud_rate),

        .data       (rx_data),
        .data_valid (rx_data_valid),
        .data_ready (rx_data_ready),
    
        .rx (rx_i)
    );

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
        periph_enable  = control[0];
        tx_enable      = control[1];
        rx_enable      = control[2];
        parity_control = control[3];
        parity_select  = control[4];
        stop_bits      = control[5];
        data_length    = control[11:8];

        // Status Register (SR)
        status[0] = tx_buf_empty;
        status[1] = rx_buf_full;
        status[DATA_WIDTH-1:2] = 0;

        // Interrupt Enable Register (IER)
        tx_buf_empty_ie  = interrupt_enable[0];
        rx_buf_full_ie   = interrupt_enable[1];

        // IRQ
        irq = (periph_enable && !pause_ack) && (
            (tx_buf_empty && tx_buf_empty_ie && !tx_pause_ack) |
            (rx_buf_full  && rx_buf_full_ie  && !rx_pause_ack)
        );
            
        // Submodule transfers
        tx_data_valid = !tx_buf_empty;
        rx_data_ready = !rx_buf_full;
        
        // IO
        tx.o = tx_o;
        tx.mode  = 1;
        tx.otype = 0;

        rx_i = rx.i;
        rx.mode  = 0;
        rx.otype = 0;

        // pause_ack
        if (pause_req) begin
            pause_ack = apb_pause_ack && tx_pause_ack && rx_pause_ack;
        end
        else begin
            pause_ack = apb_pause_ack || tx_pause_ack || rx_pause_ack;
        end

        // clk
        tx_clk_en = !tx_pause_req || !tx_pause_ack;
        rx_clk_en = !rx_pause_req || !rx_pause_ack;

        tx_data = tx_buf;
    end

    always_ff @(posedge clk) begin
        automatic reg_t new_control;

        if (rst) begin
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

            tx_pause_req <= 0;
            rx_pause_req <= 0;

            apb_pause_ack <= 0;
        end
        else begin
            if (
                (!pause_req) &&   // no pause request
                (psel && !pready) // pending APB transaction
            ) case (index)
                
                12'h000: begin // Data Register (DR)
                    if (pwrite) begin 
                        if (periph_enable && tx_enable && tx_buf_empty) begin
                            // Transmission
                            tx_buf <= pwdata;
                            tx_buf_empty <= 0;
                            pready <= 1;
                            //$write("%c", pwdata);
                        end
                        else begin
                            // Transmission disabled, error
                            pready <= 1;
                            pslverr <= 1;
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
                            if (
                                (tx_pause_req && tx_pause_ack) &&
                                (rx_pause_req && rx_pause_ack)
                            ) begin
                                // on phy pause forward change
                                control <= new_control;
                            end
                            else begin
                                // else request pause
                                tx_pause_req <= 1;
                                rx_pause_req <= 1;
                            end
                        end
                        else begin
                            // phy resume (or changes wont affect it)
                            tx_pause_req <= 0;
                            rx_pause_req <= 0;
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
                (!apb_pause_ack) &&         // not paused
                (psel && penable && pready) // transaction completed
            ) begin
                // reset APB outputs.
                prdata  <= 0;
                pready  <= 0;
                pslverr <= 0;
            end
            else if (
                (pause_req && !apb_pause_ack) &&    // external pause init
                (!tx_pause_req && !tx_pause_ack) && // no tx pause
                (!rx_pause_req && !rx_pause_ack)    // no rx pause
            ) begin
                // pause
                tx_pause_req  <= 1;
                rx_pause_req  <= 1;
                apb_pause_ack <= 1;
                
                // tie APB interface off
                prdata  <= 0;
                pready  <= 1;
                pslverr <= 1;
            end
            else if (
                (!pause_req && apb_pause_ack) &&  // external pause end
                (tx_pause_req && tx_pause_ack) && // tx pause
                (rx_pause_req && rx_pause_ack)    // rx pause
            ) begin
                // resume
                tx_pause_req  <= 0;
                rx_pause_req  <= 0;
                apb_pause_ack <= 0;

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
            if (tx_data_valid && tx_data_ready) begin
                tx_buf_empty <= 1;
            end

            // RX complete, buffer is full
            if (rx_data_valid && rx_data_ready) begin
                rx_buf <= rx_data;
                rx_buf_full <= 1;
            end
        end
    end

endmodule