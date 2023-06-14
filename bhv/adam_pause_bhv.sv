module adam_pause_bhv #(
    parameter DELAY    = 1us,
    parameter DURATION = 1us,

    parameter TA = 2ns,
    parameter TT = 18ns
) (
    input logic rst,
    input logic clk,

    output logic pause_req,
    input  logic pause_ack
);

    initial begin
        pause_req = 0;

        forever begin
            @(negedge rst);
            @(posedge clk);

            #(DELAY);
            @(posedge clk);

            pause_req <= #TA 1;
            cycle_start();
            while (pause_ack != 1) begin
                cycle_end();
                cycle_start();
            end
            cycle_end();

            #(DURATION);
            @(posedge clk);

            pause_req <= #TA 0;
            cycle_start();
            while (pause_ack != 0) begin
                cycle_end();
                cycle_start();
            end
            cycle_end();
        end
    end

    task cycle_start();
        #TT;
    endtask

    task cycle_end();
        @(posedge clk);
    endtask

endmodule