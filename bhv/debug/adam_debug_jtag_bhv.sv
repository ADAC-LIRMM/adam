`timescale 1ns/1ps
`include "adam/macros_bhv.svh"

module adam_debug_jtag_bhv #(
    `ADAM_BHV_CFG_PARAMS
) (
    output logic trst_n,
    output logic tck,
    output logic tms,
    output logic tdi,
    input  logic tdo
);

    typedef logic [7:0] char;

    logic [3:0] out_pins;
    integer     fd_jtag_rx;
    integer     fd_jtag_tx;
    char        cmd;
    logic       quit;
    
    assign '{trst_n, tck, tms, tdi} = out_pins;

    initial begin
        

        $system("rm -f jtag_rx.pipe");
        $system("rm -f jtag_tx.pipe");
        
        $system("mkfifo jtag_rx.pipe");
        $system("mkfifo jtag_tx.pipe");

        fd_jtag_rx = $fopen("jtag_rx.pipe", "rb");
        fd_jtag_tx = $fopen("jtag_tx.pipe", "wb");

        out_pins = '0;
        
        quit = 0;
        while(!quit) begin
            $display("dfssdfdsf");

            //$fread(cmd, fd_jtag_rx);

            $display(cmd);

            case (cmd)
                "0": out_pins = 5'b1000;
                "1": out_pins = 5'b1001;
                "2": out_pins = 5'b1010;
                "3": out_pins = 5'b1011;
                "4": out_pins = 5'b1100;
                "5": out_pins = 5'b1101;
                "6": out_pins = 5'b1110;
                "7": out_pins = 5'b1111;
                "R": begin
                    $fwrite(fd_jtag_tx, char'(tdo));
                    $fflush(fd_jtag_tx);
                end
                "Q": quit = 1;
            endcase
        end

        $fclose(fd_jtag_rx);
        $fclose(fd_jtag_tx);

        $system("rm -f jtag_rx.pipe");
        $system("rm -f jtag_tx.pipe");
    end
endmodule