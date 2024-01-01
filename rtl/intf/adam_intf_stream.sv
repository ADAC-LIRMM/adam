interface ADAM_STREAM #(
    parameter type T = logic
);

    T     data;
    logic valid;
    logic ready;

    modport Master (
        output data,
        output valid,
        input  ready
    );

    modport Slave (
        input  data,
        input  valid,
        output ready
    );

endinterface

interface ADAM_STREAM_DV #(
    parameter type T = logic
) (
    input logic clk
);

    T     data;
    logic valid;
    logic ready;
    
    modport Master (
        output data,
        output valid,
        input  ready
    );

    modport Slave (
        input  data,
        input  valid,
        output ready
    );

endinterface