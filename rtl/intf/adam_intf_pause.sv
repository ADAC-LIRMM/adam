interface ADAM_PAUSE;

    logic req;
    logic ack;

    modport Master (
        output req,
        input  ack
    );

    modport Slave (
        input  req,
        output ack
    );

endinterface

interface ADAM_PAUSE_DV (
    input clk
);

    logic req;
    logic ack;

    modport Master (
        output req,
        input  ack
    );

    modport Slave (
        input  req,
        output ack
    );

endinterface