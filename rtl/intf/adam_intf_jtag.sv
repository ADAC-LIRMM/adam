interface ADAM_JTAG;

    logic trst_n;
    logic tck;
    logic tms;
    logic tdi;
    logic tdo;

    modport Master (
        output trst_n,
        output tck,
        output tms,
        output tdi,
        input  tdo
    );

    modport Slave (
        input  trst_n,
        input  tck,
        input  tms,
        input  tdi,
        output tdo
    );

endinterface