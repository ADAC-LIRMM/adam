/*
 * - Memory 0 is designated as the boot memory.
 * - Peripheral 0 is expected to be SYSCTRL.
 * - Core 0 is the default active core upon startup.
 */

module adam_syscfg #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32,

    parameter NO_MEMS    = 2,
    parameter NO_PERIPHS = 7,
    parameter NO_CORES   = 2,

    parameter BOOT_ADDR = 32'h0000_0000,

    // Dependent parameters bellow, do not override.

    parameter STRB_WIDTH  = DATA_WIDTH/8,
    
    parameter type addr_t = logic [ADDR_WIDTH-1:0],
    parameter type data_t = logic [DATA_WIDTH-1:0],
    parameter type strb_t = logic [STRB_WIDTH-1:0]
) (
    ADAM_SEQ.Slave   seq,
    ADAM_PAUSE.Slave pause,

    AXI_LITE.Master slv,

    output logic irq,

    ADAM_SEQ.Master   mem_seq   [NO_MEMS],
    ADAM_PAUSE.Master mem_pause [NO_MEMS],

    ADAM_SEQ.Master   periph_seq   [NO_PERIPHS],
    ADAM_PAUSE.Master periph_pause [NO_PERIPHS],
    input  logic      periph_irq   [NO_PERIPHS],

    ADAM_SEQ.Master 
    output logic      core_srst      [NO_CORES],
    ADAM_PAUSE.Master core_pause     [NO_CORES],
    output addr_t     core_boot_addr [NO_CORES],    
    output logic      core_irq       [NO_CORES]
);

    // Registers
    data_t msr [NO_MEMS];
    data_t mcr [NO_MEMS];
    data_t mmr [NO_MEMS];
    data_t psr [NO_PERIPHS];
    data_t pcr [NO_PERIPHS];
    data_t pmr [NO_PERIPHS];
    data_t csr [NO_CORES];
    data_t ccr [NO_CORES];
    data_t cmr [NO_CORES];
    data_t bar [NO_CORES];
    data_t ier [NO_CORES];

    // APB
    addr_t paddr;
    logic  psel;
    logic  penable;
    logic  pwrite;
    data_t pwdata;
    strb_t pstrb;
    logic  pready;
    data_t prdata;
    logic  pslverr;

    addr_t index;
    data_t mask;

    logic bootstrap;

    ADAM_PAUSE mem_m_pause [NO_MEMS] ();
    logic      mem_paused  [NO_MEMS];
    logic      mem_stopped [NO_MEMS];

    ADAM_PAUSE periph_m_pause [NO_PERIPHS] ();
    logic      periph_paused  [NO_PERIPHS];
    logic      periph_stopped [NO_PERIPHS];

    ADAM_PAUSE core_m_pause [NO_CORES] ();
    logic      core_paused  [NO_CORES];
    logic      core_stopped [NO_CORES];

    ADAM_PAUSE apb_pause ();

    always_comb begin
        // APB inputs
        paddr   = apb.paddr;
        psel    = apb.psel;
        penable = apb.penable;
        pwrite  = apb.pwrite;
        pwdata  = apb.pwdata;
        pstrb   = apb.pstrb;
        
        // APB outputs
        apb.pready  = pready;
        apb.prdata  = prdata;
        apb.pslverr = pslverr;
        
        // APB address
        index = paddr[ADDR_WIDTH-1:$clog2(STRB_WIDTH)];

        // APB strobe
        for (int i = 0; i < DATA_WIDTH/8; i++) begin
            mask[i*8 +: 8] = (apb.pstrb[i]) ? 8'hFF : 8'h00; 
        end

        // Status Registers
        for (int i = 0; i < NO_MEMS; i++) begin
            msr[i] = 0;
            msr[i][0] = mem_paused[i];
            msr[i][1] = mem_stopped[i];            
        end 
        for (int i = 0; i < NO_PERIPHS; i++) begin
            psr[i] = 0;
            psr[i][0] = periph_paused[i];
            psr[i][1] = periph_stopped[i];            
        end
        for (int i = 0; i < NO_CORES; i++) begin
            csr[i] = 0;
            csr[i][0] = core_paused[i];
            csr[i][1] = core_stopped[i];
        end

        // core_boot_addr
        for (int i = 0; i < NO_CORES; i++) begin
            core_boot_addr[i] = bar[i];
        end

        // core_irq
        for (int i = 0; i < NO_CORES; i++) begin
            core_irq[i] = 0;
            for (int j = 0; j < NO_PERIPHS; j++) begin
                core_irq[i] |= ier[i][j] & periph_irq[j];
            end
        end

        // SYSCTRL irq
        irq = 0;

        // pause.req
        apb_pause.req = pause.req;
        for (int i = 0; i < NO_MEMS; i++) begin
            mem_m_pause[i].req = pause.req;
        end
        for (int i = 0; i < NO_PERIPHS; i++) begin
            periph_m_pause[i].req = pause.req;
        end
        for (int i = 0; i < NO_CORES; i++) begin
            core_m_pause[i].req = pause.req;
        end
        
        // pause.ack
        if (pause.req) begin
            pause.ack = 1;
            pause.ack &= apb_pause.ack;
            for (int i = 0; i < NO_MEMS; i++) begin
                pause.ack &= mem_m_pause[i].ack;
            end
            for (int i = 0; i < NO_PERIPHS; i++) begin
                pause.ack &= periph_m_pause[i].ack;
            end
            for (int i = 0; i < NO_CORES; i++) begin
                pause.ack &= core_m_pause[i].ack;
            end
        end
        else begin
            pause.ack = 0;
            pause.ack |= apb_pause.ack;
            for (int i = 0; i < NO_MEMS; i++) begin
                pause.ack |= mem_m_pause[i].ack;
            end
            for (int i = 0; i < NO_PERIPHS; i++) begin
                pause.ack |= periph_m_pause[i].ack;
            end
            for (int i = 0; i < NO_CORES; i++) begin
                pause.ack |= core_m_pause[i].ack;
            end
        end
    end

    always_ff @(posedge seq.clk) begin
        automatic addr_t x;
        automatic addr_t y;

        if (seq.rst) begin
            for (int i = 0; i < NO_MEMS; i++) begin
                mcr[i] <= 0;

                maestro_rst(
                    mmr[i],

                    mem_m_pause[i].req,
                    mem_m_pause[i].ack,

                    mem_srst[i],
                    mem_pause[i].req,
                    mem_pause[i].ack,

                    mem_paused[i],
                    mem_stopped[i]
                );
            end

            for (int i = 0; i < NO_PERIPHS; i++) begin
                pcr[i] <= 0;

                maestro_rst(
                    pmr[i],

                    periph_m_pause[i].req,
                    periph_m_pause[i].ack,

                    periph_srst[i],
                    mem_periph[i].req,
                    mem_periph[i].ack,

                    periph_paused[i],
                    periph_stopped[i]
                );          
            end

            // Special case for SYSCTRL. It should be running by default.
            periph_srst[0]    = 0;
            periph_stopped[0] = 0;

            for (int i = 0; i < NO_CORES; i++) begin
                ccr[i] <= 0;
                bar[i] <= rst_boot_addr;
                ier[i] <= 0;
                
                maestro_rst(
                    cmr[i],

                    core_m_pause[i].req,
                    core_m_pause[i].ack,

                    core_srst[i],
                    mem_core[i].req,
                    mem_core[i].ack,

                    core_paused[i],
                    core_stopped[i]
                );  
            end

            bootstrap <= 1;

            prdata  <= 0;
            pready  <= 0;
            pslverr <= 0;

            apb_pause.ack <= 0;
        end
        else if (apb_pause.ack && apb_pause.req) begin
            // PAUSED
        end
        else begin
            if (bootstrap) begin   
                // bootstrap
                if (mmr[0] == 0 && cmr[0] == 0) begin
                    if (mem_stopped[0]) begin
                        // start memory bank 0
                        mmr[0] = 1;
                    end
                    else if (core_stopped[0]) begin
                        // start core 0
                        cmr[0] = 1;
                    end
                    else begin
                        bootstrap <= 0;
                    end
                end
            end 
            else if (
                (!apb_pause.req) &&   // no pause request
                (psel && !pready)     // pending APB transaction
            ) begin 
                // handle APB transaction
                if (index >= 12'h100 && index < 12'h200) begin
                    // Memory

                    x = (index - 12'h100) / 3;
                    y = (index - 12'h100) % 3;
                    
                    if (x < NO_MEMS && y == 12'h000) begin
                        // Memory Status Register x (MSRx)

                        if (pwrite) begin
                            pslverr <= 1; // read only
                        end
                        else begin
                            prdata <= msr[x];
                        end

                        pready <= 1;
                    end
                    else if (x < NO_MEMS && y == 12'h001) begin
                        // Memory Control Register x (MCRx)

                        if (pwrite) begin
                            mcr[x] <= (pwdata & mask) | (mcr[x] & ~mask);
                        end
                        else begin
                            prdata <= mcr[x];
                        end

                        pready <= 1;
                    end
                    else if (x < NO_MEMS && y == 12'h002) begin
                        // Memory Maestro Register x (MMRx)

                        if (pwrite) begin
                            if (mmr[x] == 0) begin
                                mmr[x] = pwdata & mask;
                                pready <= 1;
                            end
                            else begin
                                pready <= 1;
                                pslverr <= 1;
                            end
                        end
                        else begin
                            prdata <= mmr[x];
                            pready <= 1;
                        end
                    end
                    else begin
                        pready <= 1;
                        pslverr <= 1;
                    end
                end
                else if (index >= 12'h200 && index < 12'h400) begin
                    // Peripheral

                    x = (index - 12'h200) / 3;
                    y = (index - 12'h200) % 3;
                    
                    if (x < NO_PERIPHS && y == 12'h000) begin
                        // Peripheral Status Register x (PSRx)

                        if (pwrite) begin
                            pslverr <= 1; // read only
                        end
                        else begin
                            prdata <= psr[x];
                        end

                        pready <= 1;
                    end
                    else if (x < NO_PERIPHS && y == 12'h001) begin
                        // Peripheral Control Register x (PCRx)

                        if (pwrite) begin
                            pcr[x] <= (pwdata & mask) | (pcr[x] & ~mask);
                        end
                        else begin
                            prdata <= pcr[x];
                        end

                        pready <= 1;
                    end
                    else if (x < NO_PERIPHS && y == 12'h002) begin
                        // Peripheral Maestro Register x (PMRx)

                        if (pwrite) begin
                            if (pmr[x] == 0) begin
                                pmr[x] = pwdata & mask;
                                pready <= 1;
                            end
                            else begin
                                pready <= 1;
                                pslverr <= 1;
                            end
                            
                        end
                        else begin
                            prdata <= pmr[x];
                            pready <= 1;
                        end
                    end
                    else begin
                        pready <= 1;
                        pslverr <= 1;
                    end
                end
                else if (index >= 12'h400 && index < 12'h600) begin
                    // Core

                    x = (index - 12'h400) / 5;
                    y = (index - 12'h400) % 5;
                    
                    if (x < NO_CORES && y == 12'h000) begin
                        // Core Status Register x (CSRx)

                        if (pwrite) begin
                            pslverr <= 1; // read only
                        end
                        else begin
                            prdata <= csr[x];
                        end

                        pready <= 1;
                    end
                    else if (x < NO_CORES && y == 12'h001) begin
                        // Core Control Register x (CCRx)

                        if (pwrite) begin
                            ccr[x] <= (pwdata & mask) | (ccr[x] & ~mask);
                        end
                        else begin
                            prdata <= ccr[x];
                        end

                        pready <= 1;
                    end
                    else if (x < NO_CORES && y == 12'h002) begin
                        // Core Maestro Register x (CMRx)

                        if (pwrite) begin
                            if (cmr[x] == 0) begin
                                cmr[x] = pwdata & mask;
                                pready <= 1;
                            end
                            else begin
                                pready <= 1;
                                pslverr <= 1;
                            end
                            
                        end
                        else begin
                            prdata <= cmr[x];
                            pready <= 1;
                        end
                    end
                    else if (x < NO_CORES && y == 12'h003) begin
                        // Boot Address Register x (BARx)

                        if (pwrite) begin
                            bar[x] <= (pwdata & mask) | (bar[x] & ~mask);
                        end
                        else begin
                            prdata <= bar[x];
                        end

                        pready <= 1;
                    end
                    else if (x < NO_CORES && y == 12'h004) begin
                        // Interrupt Enable Register x (IERx)

                        if (pwrite) begin
                            ier[x] <= (pwdata & mask) | (ier[x] & ~mask);
                        end
                        else begin
                            prdata <= ier[x];
                        end

                        pready <= 1;
                    end
                    else begin
                        pready <= 1;
                        pslverr <= 1;
                    end
                end
                else begin
                    // default
                    pready <= 1;
                    pslverr <= 1;
                end
            end
            else if (
                (!apb_pause.ack) &&          // not paused
                (psel && penable && pready)  // transaction completed
            ) begin
                // reset APB outputs.
                prdata  <= 0;
                pready  <= 0;
                pslverr <= 0;
            end
            else if (apb_pause.req && !apb_pause.ack) begin
                // pause
                apb_pause.ack <= 1;

                // tie APB interface off
                prdata  <= 0;
                pready  <= 1;
                pslverr <= 1;
            end
            else if (!apb_pause.req && apb_pause.ack) begin
                // resume
                apb_pause.ack <= 0;

                // reset APB outputs
                prdata  <= 0;
                pready  <= 0;
                pslverr <= 0;
            end

            for (int i = 0; i < NO_MEMS; i++) begin
                maestro(
                    mmr[i],

                    mem_m_pause[i].req,
                    mem_m_pause[i].ack,

                    mem_srst[i],
                    mem_pause[i].req,
                    mem_pause[i].ack,

                    mem_paused[i],
                    mem_stopped[i]
                );
            end

            for (int i = 0; i < NO_PERIPHS; i++) begin
                maestro(
                    pmr[i],

                    periph_m_pause[i].req,
                    periph_m_pause[i].ack,

                    periph_srst[i],
                    mem_periph[i].req,
                    mem_periph[i].ack,

                    periph_paused[i],
                    periph_stopped[i]
                );
            end

            for (int i = 0; i < NO_CORES; i++) begin            
                maestro(
                    cmr[i],

                    core_m_pause[i].req,
                    core_m_pause[i].ack,

                    core_srst[i],
                    mem_core[i].req,
                    mem_core[i].ack,

                    core_paused[i],
                    core_stopped[i]
                );
            end
        end
    end

    task automatic maestro_rst(
        inout data_t action,

        input logic pause_req,
        inout logic pause_ack,

        inout logic tgt_srst,
        inout logic tgt_pause_req,
        input logic tgt_pause_ack,

        inout logic tgt_paused,
        inout logic tgt_stopped
    );

        action = 0;

        pause_ack = 0;

        tgt_srst = 1;
        tgt_pause_req = 0;

        tgt_paused  = 0;
        tgt_stopped = 1;

    endtask

    task automatic maestro(
        inout data_t action,

        input logic pause_req,
        inout logic pause_ack,

        inout logic tgt_srst,
        inout logic tgt_pause_req,
        input logic tgt_pause_ack,

        inout logic tgt_paused,
        inout logic tgt_stopped
    );

        if (pause_req && pause_ack) begin
            // PAUSED
        end
        else if (!pause_req && pause_ack) begin
            // resume
            pause_ack = 0;
        end
        else case (action)

            // No action (default)
            default: begin                 
                if (pause_req) begin
                    // pause
                    pause_ack = 1;
                end

                action = 0;
            end

            // Resume
            1: begin 
                if (!tgt_pause_req && !tgt_pause_ack) begin
                    action       = 0;
                    tgt_paused   = 0;
                    tgt_stopped  = 0;
                end

                tgt_srst      = 0;
                tgt_pause_req = 0;
            end

            // Pause
            2: begin 
                tgt_pause_req = 1;

                if (tgt_pause_req && tgt_pause_ack) begin
                    action      = 0;
                    tgt_paused  = 1;
                end
            end

            // Stop
            3: begin 
                tgt_pause_req = 1;

                if (tgt_pause_req && tgt_pause_ack) begin
                    tgt_srst = 1;
                    
                    action      = 0;
                    tgt_stopped = 1;
                end
            end

            // Reset (Stop + Resume)
            4: begin 
                tgt_pause.req = 1;

                if (tgt_pause.req && tgt_pause.ack) begin
                    tgt_srst = 1;

                    action      = 1; // resume
                    tgt_stopped = 1;
                end  
            end

        endcase

    endtask

endmodule