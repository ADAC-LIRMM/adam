/*
 * This module adds non-standard functionality to pause_req and pause_ack.
 * In addition to their conventional roles, when both are asserted, the
 * modification of the configuration signals is allowed. This functionality is
 * NOT part of the standard "pause protocol".
 */

module adam_periph_spi_phy #(
    parameter DATA_WIDTH = 32,

    // Dependent parameters bellow, do not override.

    parameter type data_t = logic [DATA_WIDTH-1:0]
) (
    input logic clk,
    input logic rst,
    input logic test,

    input  logic pause_req,
    output logic pause_ack,

    input  logic        tx_enable,
    input  logic        rx_enable,
    input  logic        mode_select,
    input  logic        clock_phase,
    input  logic        clock_polarity,
    input  logic        data_order,
    input  logic  [3:0] data_length,
    input  data_t       baud_rate,       
    
    input  data_t tx,
    input  logic  tx_valid,
    output logic  tx_ready,

    output data_t rx,
    output logic  rx_valid,
    input  logic  rx_ready,
    
    ADAM_IO.Master sclk,
    ADAM_IO.Master mosi,
    ADAM_IO.Master miso,
    ADAM_IO.Master ss_n
);

    logic pclk;
    logic lpclk;

    data_t clk_count;
    logic  pclk_gen;
    logic  ss_n_gen; 

    logic sdo;
    logic sdi;

    data_t tx_reg;
    data_t rx_reg;

    logic tx_ok;
    logic rx_ok;

    logic selected;
    logic lselected;

    data_t index;
    data_t reversed;

    // Handles all combinatory logic
    always_comb begin  
        rx       = rx_reg;
        reversed = data_length - 1 - index;

        // First, set default values for all IOs

        sclk.o = 0;
        mosi.o = 0;
        miso.o = 0;
        ss_n.o = 0;

        sclk.mode = 0;
        mosi.mode = 0;
        miso.mode = 0;
        ss_n.mode = 0;
        
        sclk.otype = 0;
        mosi.otype = 0;
        miso.otype = 0;
        ss_n.otype = 0;

        // Then, make changes as required.       

        if (mode_select) begin
            // Master
            pclk     = pclk_gen;
            selected = !ss_n_gen;

            sclk.o = pclk_gen ^ clock_polarity;
            mosi.o = sdo;
            sdi    = miso.i;
            ss_n.o = ss_n_gen;

            sclk.mode = 1;
            mosi.mode = 1;
            miso.mode = 0;
            ss_n.mode = 1;
        end
        else begin
            // Slave
            pclk     = sclk.i ^ clock_polarity;
            selected = !ss_n.i;

            sdi    = mosi.i;
            miso.o = sdo;

            sclk.mode = 0;
            mosi.mode = 0;
            miso.mode = selected;
            ss_n.mode = 0;
        end
    end

    // Generates clock and select signals while in master mode.
    always_ff @(posedge clk) begin
        if (
            (rst) ||
            (!mode_select) ||
            (!tx_ok || !rx_ok) ||
            (!tx_enable && !rx_enable)
        ) begin
            // not performing SPI transfer

            clk_count <= 0;
            pclk_gen  <= 0;
            ss_n_gen  <= 1;
        end
        else begin
            if (clk_count >= baud_rate) begin
                clk_count <= 0;

                if (!ss_n_gen && index < data_length) begin
                    pclk_gen <= !pclk_gen;
                end
                else begin
                    pclk_gen <= 0;
                end

                if (tx_ready || rx_valid) begin
                    ss_n_gen <= 1;
                end
                else if (index < data_length) begin
                    ss_n_gen <= 0;
                end
                else begin
                    ss_n_gen <= 1;
                end             
            end
            else begin
                clk_count <= clk_count + 2;
            end
        end 
    end

    // Main logic
    always_ff @(posedge clk) begin
        if (rst) begin
            tx_ready <= 0;
            rx_valid <= 0;

            pause_ack <= 0;

            tx_reg <= 0;
            rx_reg <= 0;

            tx_ok <= !tx_enable;
            rx_ok <= 1;
            
            index <= 0;
            
            sdo <= 0;

            lpclk     <= 0;
            lselected <= 0;
        end
        else if (pause_req && pause_ack) begin
            // paused
            tx_ok <= !tx_enable;
            rx_ok <= 1;
        end
        else begin
            if (
                // pause (handles the rx-only slave case)
                (pause_req && !tx_enable && index == 0) ||
                // waiting for stream
                (!tx_ok || !rx_ok) ||     
                // tx and rx disabled (invalid config)  
                (!tx_enable && !rx_enable)  
            ) begin
                // not performing SPI transfer
                
                // tx transfer
                if (tx_valid && tx_ready) begin
                    tx_reg   <= tx;
                    tx_ready <= 0;
                    tx_ok    <= 1;
                end
                else if (!tx_ok && (!pause_req && !pause_ack)) begin
                    tx_ready <= 1;
                end
                else if (rx_ok || (rx_valid && rx_ready)) begin
                    // able to pause
                    pause_ack <= pause_req;
                end

                // rx transfer
                if (rx_valid && rx_ready) begin
                    rx_valid <= 0;
                    rx_ok    <= 1;
                end
                else if (!rx_ok) begin
                    rx_valid <= 1;
                end
            end
            else if (pclk == !clock_phase && pclk != lpclk && selected) begin
                // SPI sample edge

                if (index < data_length) begin
                    if (data_order) begin 
                        // MSB first
                        rx_reg[reversed] <= sdi;
                    end
                    else begin 
                        // LSB first
                        rx_reg[index] <= sdi;
                    end
                    index <= index + 1;
                end
            end
            else if (
                (pclk == clock_phase && pclk != lpclk && selected) ||
                (selected == 1 && selected != lselected)
            ) begin
                // SPI change edge

                if (index < data_length) begin
                    if (data_order) begin 
                        // MSB first
                        sdo <= tx_reg[reversed];
                    end
                    else begin 
                        // LSB first
                        sdo <= tx_reg[index];
                    end  
                end
                else begin
                    sdo <= 0;
                end
            end
            
            if (
                (pclk == clock_polarity && pclk != lpclk) ||
                (!selected)
            ) begin
                if (index >= data_length) begin
                    // end of frame
                    index <= 0;
                    tx_ok <= !tx_enable;
                    rx_ok <= !rx_enable;
                end
            end
        end

        // for edge detection
        lpclk <= pclk;
        lselected <= selected;
    end

endmodule