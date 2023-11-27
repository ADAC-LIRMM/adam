interface ADAM_SEQ;

    logic clk;
    logic rst;

    modport Master (
        output clk,
        output rst
    );

    modport Slave (
        input clk,
        input rst
    );

endinterface