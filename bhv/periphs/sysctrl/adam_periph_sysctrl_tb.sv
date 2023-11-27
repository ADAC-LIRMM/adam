// `include "apb/assign.svh"
// `include "vunit_defines.svh"

// module adam_periph_sysctrl_tb;

//     localparam ADDR_WIDTH = 32;
//     localparam DATA_WIDTH = 32;

//     localparam NO_MEMS    = 2;
//     localparam NO_PERIPHS = 8;
//     localparam NO_CORES   = 2;

//     localparam STRB_WIDTH = DATA_WIDTH/8;

//     localparam CLK_PERIOD = 20ns;
//     localparam RST_CYCLES = 5;

//     localparam TA = 2ns;
//     localparam TT = CLK_PERIOD - TA;
    
//     typedef logic [ADDR_WIDTH-1:0] addr_t;
//     typedef logic [DATA_WIDTH-1:0] data_t;
//     typedef logic [STRB_WIDTH-1:0] strb_t;

//     ADAM_SEQ   seq   ();
//     ADAM_PAUSE pause ();

//     logic irq;

//     data_t rst_boot_addr;

//     logic      mem_srst  [NO_MEMS];
//     ADAM_PAUSE mem_pause [NO_MEMS] ();

//     logic      periph_srst  [NO_PERIPHS];
//     ADAM_PAUSE periph_pause [NO_PERIPHS] ();
//     logic      periph_irq   [NO_PERIPHS];

//     logic      core_srst      [NO_CORES];
//     ADAM_PAUSE core_pause     [NO_CORES] ();
//     addr_t     core_boot_addr [NO_CORES];    
//     logic      core_irq       [NO_CORES];

//     ADAM_PAUSE pause_auto ();
//     logic critical;

//     APB_DV #(
//         .ADDR_WIDTH(ADDR_WIDTH),
//         .DATA_WIDTH(DATA_WIDTH)
//     ) slave_dv(seq.clk);
    
//     APB #(
//         .ADDR_WIDTH(ADDR_WIDTH),
//         .DATA_WIDTH(DATA_WIDTH)
//     ) slave();
    
//     `APB_ASSIGN(slave, slave_dv)

//     apb_test::apb_driver #(
//         .ADDR_WIDTH (ADDR_WIDTH),
//         .DATA_WIDTH (DATA_WIDTH),
//         .TA         (TA),
//         .TT         (TT)
//     ) master = new(slave_dv);

//     adam_clk_rst_bhv #(
//         .CLK_PERIOD (CLK_PERIOD),
//         .RST_CYCLES (RST_CYCLES),

//         .TA (TA),
//         .TT (TT)
//     ) adam_clk_rst_bhv (
//         .seq (seq)
//     );

//     adam_pause_bhv #(
//         .DELAY    (1ms),
//         .DURATION (1ms),

//         .TA (TA),
//         .TT (TT)
//     ) adam_pause_bhv (
//         .seq   (seq),
//         .pause (pause_auto)
//     );

//     adam_periph_sysctrl #(
//         .ADDR_WIDTH (ADDR_WIDTH),
//         .DATA_WIDTH (DATA_WIDTH),

//         .NO_MEMS    (NO_MEMS),
//         .NO_PERIPHS (NO_PERIPHS),
//         .NO_CORES   (NO_CORES)
//     ) dut (
//         .seq   (seq),
//         .pause (pause),

//         .apb (slave),

//         .irq (irq),

//         .rst_boot_addr (rst_boot_addr),

//         .mem_srst  (mem_srst),
//         .mem_pause (mem_pause),

//         .periph_srst  (periph_srst),
//         .periph_pause (periph_pause),
//         .periph_irq   (periph_irq),

//         .core_srst      (core_srst),
//         .core_pause     (core_pause),
//         .core_boot_addr (core_boot_addr),
//         .core_irq       (core_irq)
//     );

//     always_comb begin
//         pause.req = pause_auto.req && !critical;
//         pause_auto.ack = pause.ack;
//     end

//     // Emulates reset behavior of the system's components
//     generate
//         for (genvar i = 0; i < NO_MEMS; i++) begin
//             initial begin
//                 logic state;
//                 logic change;

//                 mem_pause[i].ack = 0;
                
//                 @(negedge seq.rst);
//                 @(posedge seq.clk);

//                 forever begin
//                     cycle_start();
//                     state  = mem_pause[i].req;
//                     change = mem_pause[i].req != mem_pause[i].ack;
//                     cycle_end();

//                     #(1us * $urandom_range(0, 100));
//                     @(posedge seq.clk);

//                     mem_pause[i].ack <= #TA state;
//                     cycle_start();
//                     cycle_end();
//                 end
//             end
//         end 

//         for (genvar i = 0; i < NO_PERIPHS; i++) begin
//             initial begin
//                 logic state;
//                 logic change;

//                 mem_periph[i].ack = 0;
                
//                 @(negedge seq.rst);
//                 @(posedge seq.clk);

//                 forever begin
//                     cycle_start();
//                     state  = mem_periph[i].req;
//                     change = mem_periph[i].req != mem_periph[i].ack;
//                     cycle_end();

//                     #(1us * $urandom_range(0, 100));
//                     @(posedge seq.clk);

//                     mem_periph[i].ack <= #TA state;
//                     cycle_start();
//                     cycle_end();
//                 end
//             end
//         end 

//         for (genvar i = 0; i < NO_CORES; i++) begin
//             initial begin
//                 logic state;
//                 logic change;

//                 mem_core[i].ack = 0;
                
//                 @(negedge seq.rst);
//                 @(posedge seq.clk);

//                 forever begin
//                     cycle_start();
//                     state  = mem_core[i].req;
//                     change = mem_core[i].req != mem_core[i].ack;
//                     cycle_end();

//                     #(1us * $urandom_range(0, 100));
//                     @(posedge seq.clk);

//                     mem_core[i].ack <= #TA state;
//                     cycle_start();
//                     cycle_end();
//                 end
//             end
//         end  
//     endgenerate

//     `TEST_SUITE begin
//         `TEST_CASE("test") begin
//             automatic addr_t base;
//             automatic logic special;

//             rst_boot_addr = 32'hDEADBEEF;
//             periph_irq = {0, 1, 0, 0, 0, 0, 0, 0};
            
//             critical = 0;

//             // reset
//             @(negedge seq.rst);
//             master.reset_master();
//             @(posedge seq.clk);

//             // wait bootstrap
//             repeat (20) @(posedge seq.clk);  
            
//             // Test for memories
//             base = 12'h100;
//             for (int i = 0; i < NO_MEMS; i++) begin
//                 $display("Testing Memory %02d", i);

//                 special = (i == 0);

//                 verify_init_one(base, special, mem_srst[i], mem_pause[i].req,
//                     mem_pause[i].ack);

//                 resume_one(base, mem_srst[i], mem_pause[i].req,
//                     mem_pause[i].ack);
                
//                 pause_one(base, mem_srst[i], mem_pause[i].req,
//                     mem_pause[i].ack);

//                 stop_one(base, mem_srst[i], mem_pause[i].req,
//                     mem_pause[i].ack);

//                 resume_one(base, mem_srst[i], mem_pause[i].req,
//                     mem_pause[i].ack);

//                 base += 3;
//             end
            
//             // Test for peripherals
//             base = 12'h200;
//             for (int i = 0; i < NO_PERIPHS; i++) begin
//                 $display("Testing Peripheral %02d", i);

//                 special = (i == 0);

//                 verify_init_one(base, special, periph_srst[i], mem_periph[i].req, 
//                     mem_periph[i].ack);

//                 resume_one(base, periph_srst[i], mem_periph[i].req,
//                     mem_periph[i].ack);
                
//                 pause_one(base, periph_srst[i], mem_periph[i].req,
//                     mem_periph[i].ack);

//                 stop_one(base, periph_srst[i], mem_periph[i].req,
//                     mem_periph[i].ack);

//                 resume_one(base, periph_srst[i], mem_periph[i].req,
//                     mem_periph[i].ack);

//                 base += 3;
//             end

//             // Test for cores
//             base = 12'h400;
//             for (int i = 0; i < NO_CORES; i++) begin
//                 $display("Testing Core %02d", i);

//                 special = (i == 0);

//                 verify_init_one(base, special, core_srst[i], mem_core[i].req,
//                     mem_core[i].ack);

//                 resume_one(base, core_srst[i], mem_core[i].req,
//                     mem_core[i].ack);
                
//                 pause_one(base, core_srst[i], mem_core[i].req,
//                     mem_core[i].ack);

//                 stop_one(base, core_srst[i], mem_core[i].req,
//                     mem_core[i].ack);

//                 resume_one(base, core_srst[i], mem_core[i].req,
//                     mem_core[i].ack);

//                 // Extra core-related tests

//                 extra_core_one(base, core_boot_addr[i], core_irq[i]);

//                 base += 5;
//             end
            
//             repeat (10) @(posedge seq.clk);
//         end
//     end

//     task automatic verify_init_one(
//         input addr_t base,
//         input logic  special,

//         ref logic tgt_srst,
//         ref logic tgt_pause_req,
//         ref logic tgt_pause_ack
//     );
//         addr_t addr;
//         data_t data;
//         strb_t strb;
//         logic  resp;

//         strb = 4'b1111;

//         critical_begin();

//         // verify status
//         addr = (base + 0) << 2;
//         master.read(addr, data, resp);
//         assert (resp == apb_pkg::RESP_OKAY);
//         if (special) begin
//             assert (data == 32'b00);
//         end
//         else begin
//             assert (data == 32'b10);
//         end

//         // verify signals
//         cycle_start();
//         if (special) begin
//             assert (tgt_srst == 0);
//             assert (tgt_pause.req == 0);
//         end
//         else begin
//             assert (tgt_srst == 1);
//             assert (tgt_pause.req == 0);
//         end
//         cycle_end();

//         critical_end();
//     endtask

//     task automatic resume_one(
//         input addr_t base,

//         ref logic tgt_srst,
//         ref logic tgt_pause_req,
//         ref logic tgt_pause_ack
//     );
//         addr_t addr;
//         data_t data;
//         strb_t strb;
//         logic  resp;
        
//         strb = 4'b1111;

//         critical_begin();

//         // trigger meastro action
//         addr = (base + 2) << 2;
//         data = 1; // resume
//         master.write(addr, data, strb, resp);
//         assert (resp == apb_pkg::RESP_OKAY);

//         // wait for completion
//         do begin
//             master.read(addr, data, resp);
//             assert (resp == apb_pkg::RESP_OKAY);
//         end while (data != 0);

//         // verify status register
//         addr = (base + 0) << 2;
//         master.read(addr, data, resp);
//         assert (resp == apb_pkg::RESP_OKAY);
//         assert (data == 32'b00);

//         // verify signals
//         cycle_start();
//         assert (tgt_srst == 0);
//         assert (tgt_pause.req == 0);
//         assert (tgt_pause.ack == 0);
//         cycle_end();

//         critical_end();
//     endtask

//     task automatic pause_one(
//         input addr_t base,

//         ref logic tgt_srst,
//         ref logic tgt_pause_req,
//         ref logic tgt_pause_ack
//     );
//         addr_t addr;
//         data_t data;
//         strb_t strb;
//         logic  resp;
        
//         strb = 4'b1111;

//         critical_begin();

//         // trigger meastro action
//         addr = (base + 2) << 2;
//         data = 2; // pause
//         master.write(addr, data, strb, resp);
//         assert (resp == apb_pkg::RESP_OKAY);

//         // wait for completion
//         do begin
//             master.read(addr, data, resp);
//             assert (resp == apb_pkg::RESP_OKAY);
//         end while (data != 0);

//         // verify status register
//         addr = (base + 0) << 2;
//         master.read(addr, data, resp);
//         assert (resp == apb_pkg::RESP_OKAY);
//         assert (data[0] == 1);

//         // verify signals
//         cycle_start();
//         assert (tgt_srst == data[1]);
//         assert (tgt_pause.req == 1);
//         assert (tgt_pause.ack == 1);
//         cycle_end();

//         critical_end();
//     endtask

//     task automatic stop_one(
//         input addr_t base,

//         ref logic tgt_srst,
//         ref logic tgt_pause_req,
//         ref logic tgt_pause_ack
//     );
//         addr_t addr;
//         data_t data;
//         strb_t strb;
//         logic  resp;
        
//         strb = 4'b1111;

//         critical_begin();

//         // trigger meastro action
//         addr = (base + 2) << 2;
//         data = 3; // stop
//         master.write(addr, data, strb, resp);
//         assert (resp == apb_pkg::RESP_OKAY);

//         // wait for completion
//         do begin
//             master.read(addr, data, resp);
//             assert (resp == apb_pkg::RESP_OKAY);
//         end while (data != 0);

//         // verify status register
//         addr = (base + 0) << 2;
//         master.read(addr, data, resp);
//         assert (resp == apb_pkg::RESP_OKAY);
//         assert (data[1] == 1);

//         // verify signals
//         cycle_start();
//         assert (tgt_srst == data[1]);
//         assert (tgt_pause.req == 1);
//         assert (tgt_pause.ack == 1);
//         cycle_end();

//         critical_end();
//     endtask

//     task automatic extra_core_one(
//         input addr_t base,

//         ref addr_t tgt_boot_addr,
//         ref logic  tgt_irq
//     );
//         automatic addr_t addr;
//         automatic data_t data;
//         automatic strb_t strb;
//         automatic logic  resp;
        
//         strb = 4'b1111;

//         critical_begin();

//         // interrupts are disabled by default
//         assert (tgt_irq == 0);

//         addr = (base + 4) << 2; // IERx
//         data = 32'hFFFF_FFFF; // all interrupts are enabled
//         write_and_verify(addr, data);

//         assert (tgt_irq == 1);

//         // verify default boot address
//         assert (tgt_boot_addr == rst_boot_addr);

//         addr = (base + 3) << 2; // BARx
//         data = 32'h0xDEAD_C0DE;
//         write_and_verify(addr, data);

//         assert (tgt_boot_addr == data);

//         critical_end();
//     endtask

//     task write_and_verify(
//         input addr_t addr,
//         input data_t data
//     );
//         automatic strb_t strb = 4'b1111;
//         automatic logic  resp;
//         automatic data_t check;
//         master.write(addr, data, strb, resp);
//         assert (resp == apb_pkg::RESP_OKAY);
//         master.read(addr, check, resp);
//         assert (resp == apb_pkg::RESP_OKAY);
//         assert (check == data);
//     endtask

//     task critical_begin();
//         cycle_start();
//         while (pause.req || pause.ack) begin
//             cycle_end();
//             cycle_start();
//         end 
//         cycle_end();

//         critical <= #TA 1;
//         cycle_start();
//         cycle_end();
//     endtask

//     task critical_end();
//         critical <= #TA 0;
//         cycle_start();
//         cycle_end();
//     endtask

//     task cycle_start();
//         #TT;
//     endtask

//     task cycle_end();
//         @(posedge seq.clk);
//     endtask

// endmodule