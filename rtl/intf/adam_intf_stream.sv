interface ADAM_STREAM #(
    parameter type data_t = logic
);

    data_t data;
    logic  valid;
    logic  ready;

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
    parameter type data_t = logic
) (
    input logic clk
);

    data_t data;
    logic  valid;
    logic  ready;
    
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