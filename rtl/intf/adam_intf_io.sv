interface ADAM_IO;

    logic i;
    logic o;
    logic mode;
    logic otype;

    modport Master (
        input  i,
        output o, mode, otype
    );

    modport Slave (
        output i,
        input  o, mode, otype
    );

endinterface