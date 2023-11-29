package adam_axil_mst_bhv;

class adam_axil_mst_bhv #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32,
    
    parameter TA = 2ns,
    parameter TT = 18ns,
    
    parameter MAX_TRANS = 4
);

    localparam STRB_WIDTH = DATA_WIDTH/8;

    typedef logic [ADDR_WIDTH-1:0] addr_t;
    typedef logic [1:0]            prot_t;       
    typedef logic [DATA_WIDTH-1:0] data_t;
    typedef logic [STRB_WIDTH-1:0] strb_t;
    typedef logic [1:0]            resp_t;

    typedef struct {
        addr_t addr;
        prot_t prot;
    } aw_t;

    typedef struct {
        data_t data;
        strb_t strb;
    } w_t;

    typedef struct {
        resp_t resp;
    } b_t;

    typedef struct {
        addr_t addr;
        prot_t prot;
    } ar_t;
    
    typedef struct {
        data_t data;
        resp_t resp;
    } r_t;

    typedef virtual AXI_LITE_DV #(
        .AXI_ADDR_WIDTH (ADDR_WIDTH),
        .AXI_DATA_WIDTH (DATA_WIDTH)
    ) axil_dv_t;

    aw_t aw_queue [$];
    w_t  w_queue  [$];
    b_t  b_queue  [$];
    ar_t ar_queue [$];
    r_t  r_queue  [$];
    
    axil_dv_t axil_dv;

    function new(
        axil_dv_t axil_dv
    );
        this.axil_dv = axil_dv;
    endfunction

    task send_aw(
        input addr_t addr,
        input prot_t prot
    );
        aw_queue.push_front('{addr, prot});
    endtask

    task send_w(
        input data_t data,
        input strb_t strb
    );
        w_queue.push_front('{data, strb});
    endtask

    task recv_b(
        output resp_t resp
    );
        b_t b;

        while (b_queue.size() == 0) begin
            cycle_start();
            cycle_end();
        end
        
        b = b_queue.pop_back();

        resp = b.resp;
    endtask

    task send_ar(
        input addr_t addr,
        input prot_t prot
    );
        ar_queue.push_front('{addr, prot});
    endtask

    task recv_r(
        output data_t data,
        output resp_t resp
    );
        r_t r;

        while (r_queue.size() == 0) begin
            cycle_start();
            cycle_end();
        end

        r = r_queue.pop_back();

        data = r.data;
        resp = r.resp;
    endtask

    task loop();
        fork
            aw_loop();
            w_loop();
            b_loop();
            ar_loop();
            r_loop();
        join
    endtask

    // AW Stream
    task aw_loop();
        logic start_transfer;
        logic end_transfer;
        aw_t  aw;

        // init value
        axil_dv.aw_addr  = 0;
        axil_dv.aw_prot  = 0;
        axil_dv.aw_valid = 0;

        forever begin
            cycle_start();
            
            end_transfer = axil_dv.aw_valid && axil_dv.aw_ready;
            
            start_transfer = (!axil_dv.aw_valid || end_transfer) &&
                (aw_queue.size() > 0);
            
            cycle_end();

            if (start_transfer) begin
                aw = aw_queue.pop_back();
                
                axil_dv.aw_addr  <= #TA aw.addr;
                axil_dv.aw_prot  <= #TA aw.prot;
                axil_dv.aw_valid <= #TA 1;
            end
            else if (end_transfer) begin
                axil_dv.aw_addr  <= #TA 0;
                axil_dv.aw_prot  <= #TA 0;
                axil_dv.aw_valid <= #TA 0;
            end
        end
    endtask

    // W Stream
    task w_loop();
        logic start_transfer;
        logic end_transfer;
        w_t   w;

        // init value
        axil_dv.w_data  = 0;
        axil_dv.w_strb  = 0;
        axil_dv.w_valid = 0;

        forever begin
            cycle_start();
            
            end_transfer = axil_dv.w_valid && axil_dv.w_ready;
            
            start_transfer = (!axil_dv.w_valid || end_transfer) &&
                (w_queue.size() > 0);
            
            cycle_end();

            if (start_transfer) begin
                w = w_queue.pop_back();
            
                axil_dv.w_data  <= #TA w.data;
                axil_dv.w_strb  <= #TA w.strb;
                axil_dv.w_valid <= #TA 1;
            end
            else if (end_transfer) begin
                axil_dv.w_data  <= #TA 0;
                axil_dv.w_strb  <= #TA 0;
                axil_dv.w_valid <= #TA 0;
            end
        end
    endtask

    // B Stream
    task b_loop();
        logic start_transfer;
        logic end_transfer;
        b_t   b;

        // init value
        axil_dv.b_ready = 0;

        forever begin
            cycle_start();
            
            end_transfer = axil_dv.b_valid && axil_dv.b_ready;
            
            if (end_transfer) begin
                b.resp = axil_dv.b_resp;
                b_queue.push_front(b);
            end

            start_transfer = (b_queue.size() < MAX_TRANS);

            cycle_end();
            
            if (end_transfer) begin
                axil_dv.b_ready <= #TA 0;
            end
            
            if (start_transfer) begin
                axil_dv.b_ready <= #TA 1;
            end
        end
    endtask

    // AR Stream
    task ar_loop();
        logic start_transfer;
        logic end_transfer;
        ar_t  ar;

        // init value
        axil_dv.ar_addr  = 0;
        axil_dv.ar_prot  = 0;
        axil_dv.ar_valid = 0;

        forever begin
            cycle_start();
            
            end_transfer = axil_dv.ar_valid && axil_dv.ar_ready;
            
            start_transfer = (!axil_dv.ar_valid || end_transfer) &&
                (ar_queue.size() > 0);
            
            cycle_end();

            if (start_transfer) begin
                ar = ar_queue.pop_back();

                axil_dv.ar_addr  <= #TA ar.addr;
                axil_dv.ar_prot  <= #TA ar.prot;
                axil_dv.ar_valid <= #TA 1;
            end
            else if (end_transfer) begin
                axil_dv.ar_addr  <= #TA 0;
                axil_dv.ar_prot  <= #TA 0;
                axil_dv.ar_valid <= #TA 0;
            end
        end
    endtask

    // R Stream
    task r_loop();
        logic start_transfer;
        logic end_transfer;
        r_t   r;

        // init value
        axil_dv.r_ready = 0;

        forever begin
            cycle_start();
            
            end_transfer = axil_dv.r_valid && axil_dv.r_ready;
            
            if (end_transfer) begin
                r.data = axil_dv.r_data;
                r.resp = axil_dv.r_resp;
                r_queue.push_front(r);
            end

            start_transfer = (r_queue.size() < MAX_TRANS);
            
            cycle_end();
            
            if (end_transfer) begin
                axil_dv.r_ready <= #TA 0;
            end
            
            if (start_transfer) begin
                axil_dv.r_ready <= #TA 1;
            end
        end
    endtask

    task cycle_start();
        #TT;
    endtask

    task cycle_end();
        @(posedge axil_dv.clk_i);
    endtask

endclass

endpackage