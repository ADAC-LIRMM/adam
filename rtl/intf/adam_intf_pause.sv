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