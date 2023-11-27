interface ADAM_IO;

    logic i;
    logic o;
    logic mode;
    logic otype;

    modport Master (
        input  i,
        output o,
        output mode,
        output otype
    );

    modport Slave (
        output i,
        input  o,
        input  mode,
        input  otype
    );

endinterface