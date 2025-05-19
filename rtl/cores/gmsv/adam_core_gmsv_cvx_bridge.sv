module adam_core_gmsv_cvx_bridge
    import gmsv_pkg::*;
    import gmsv_isa_pkg::*;
(
    input logic clk_i,
    input logic rst_i,

    output dec_req_t dec_req_o,
    output logic     dec_req_valid_o,
    input  logic     dec_req_ready_i,

    input  dec_rsp_t dec_rsp_i,
    input  logic     dec_rsp_valid_i,
    output logic     dec_rsp_ready_o,

    output exe_req_t exe_req_o,
    output logic     exe_req_valid_o,
    input  logic     exe_req_ready_i,

    input  exe_rsp_t exe_rsp_i,
    input  logic     exe_rsp_valid_i,
    output logic     exe_rsp_ready_o,

    cv32e40x_if_xif.coproc_compressed xif_compressed_if,
    cv32e40x_if_xif.coproc_issue      xif_issue_if,
    cv32e40x_if_xif.coproc_commit     xif_commit_if,
    cv32e40x_if_xif.coproc_mem        xif_mem_if,
    cv32e40x_if_xif.coproc_mem_result xif_mem_result_if,
    cv32e40x_if_xif.coproc_result     xif_result_if
);

    assign xif_compressed_if.compressed_ready = 0;
    assign xif_compressed_if.compressed_resp = '0;

    assign xif_mem_if.mem_valid = 0;
    assign xif_mem_if.mem_req = '0;

    typedef struct packed {
        instr_t    instr;
        reg_data_t rs1_data;
        reg_data_t rs2_data;
        reg_addr_t rd_addr;
        reg_data_t rd_data;
        logic      rd_write;
        logic      error;
        logic      issue_done;
        logic      commit_done;
        logic      result_done;
        logic      dec_req_done;
        logic      dec_rsp_done;
        logic      exe_req_done;
        logic      exe_rsp_done;
    } state_t;

    state_t [SbLen-1:0] sb_d, sb_q;

    always_comb begin
        automatic id_t id = '0;
        automatic logic accept = 0;

        dec_req_o       = '0;
        dec_req_valid_o = '0;
        dec_rsp_ready_o = '0;
        exe_req_o       = '0;
        exe_req_valid_o = '0;
        exe_rsp_ready_o = '0;

        xif_issue_if.issue_ready   = '0;
        xif_issue_if.issue_resp    = '0;
        xif_result_if.result_valid = '0;
        xif_result_if.result       = '0;

        sb_d = sb_q;

        // issue ==============================================================

        id = xif_issue_if.issue_req.id;

        xif_issue_if.issue_ready = (
            xif_issue_if.issue_valid &&
            !sb_d[id].issue_done
        );

        if (xif_issue_if.issue_valid && xif_issue_if.issue_ready) begin
            sb_d[id].instr    = xif_issue_if.issue_req.instr;
            sb_d[id].rs1_data = xif_issue_if.issue_req.rs[0];
            sb_d[id].rs2_data = xif_issue_if.issue_req.rs[1];

            accept = (get_info(sb_d[id].instr).opcode === OpcodeGmsv);

            xif_issue_if.issue_resp.accept = accept;

            if (accept) begin
                sb_d[id].issue_done = 1;
            end
            else begin
                sb_d[id] = '0;
            end
        end

        // commit =============================================================

        id = xif_commit_if.commit.id;

        if (xif_commit_if.commit_valid) begin
            if (xif_commit_if.commit.commit_kill) begin
                sb_d[id] = '0;
            end
            else begin
                sb_d[id].commit_done = 1;
            end
        end

        // dec req ============================================================

        for (size_t i = 0; i < SbLen; i++) begin
            id = id_t'(i);
            if (sb_d[id].commit_done && !sb_d[id].dec_req_done) begin
                dec_req_o.id    = id;
                dec_req_o.instr = sb_d[id].instr;
                dec_req_valid_o = 1;

                if (dec_req_valid_o && dec_req_ready_i) begin
                    sb_d[id].dec_req_done = 1;
                end

                break;
            end
        end

        // dec rsp ============================================================

        id = dec_rsp_i.id;

        dec_rsp_ready_o = !sb_d[id].dec_rsp_done;

        if (dec_rsp_valid_i && dec_rsp_ready_o) begin
            sb_d[id].dec_rsp_done = 1;
        end

        // exe req ============================================================

        for (size_t i = 0; i < SbLen; i++) begin
            id = id_t'(i);
            if (sb_d[id].commit_done && !sb_d[id].exe_req_done) begin
                exe_req_o.id       = id;
                exe_req_o.instr    = sb_d[id].instr;
                exe_req_o.rs1_data = sb_d[id].rs1_data;
                exe_req_o.rs2_data = sb_d[id].rs2_data;
                exe_req_valid_o = 1;

                if (exe_req_valid_o && exe_req_ready_i) begin
                    sb_d[id].exe_req_done = 1;
                end
            end
        end

        // exe rsp ============================================================

        id = exe_rsp_i.id;

        exe_rsp_ready_o = !sb_d[id].exe_rsp_done;

        if (exe_rsp_valid_i && exe_rsp_ready_o) begin
            sb_d[id].rd_addr  = exe_rsp_i.rd_addr;
            sb_d[id].rd_data  = exe_rsp_i.rd_data;
            sb_d[id].rd_write = exe_rsp_i.rd_write;
            sb_d[id].error    = exe_rsp_i.error;
            sb_d[id].exe_rsp_done = 1;
        end

        // result =============================================================

        for (size_t i = 0; i < SbLen; i++) begin
            id = id_t'(i);
            if (sb_d[id].exe_rsp_done && !sb_d[id].result_done) begin
                xif_result_if.result.id   = id;
                xif_result_if.result.data = sb_d[id].rd_data;
                xif_result_if.result.rd   = sb_d[id].rd_addr;
                xif_result_if.result.we   = sb_d[id].rd_write;
                xif_result_if.result.err  = sb_d[id].error;
                xif_result_if.result_valid = 1;

                if (
                    xif_result_if.result_valid &&
                    xif_result_if.result_ready
                ) begin
                    sb_d[id].result_done = 1;
                end
            end
        end

        // end ================================================================

        for (size_t i = 0; i < SbLen; i++) begin
            id = id_t'(i);
            if (
                sb_d[id].issue_done &&
                sb_d[id].commit_done &&
                sb_d[id].result_done &&
                sb_d[id].dec_req_done &&
                sb_d[id].dec_rsp_done &&
                sb_d[id].exe_req_done &&
                sb_d[id].exe_rsp_done
            ) begin
                sb_d[id] = '0;
            end
        end
    end

    always_ff @(posedge clk_i) begin
        if (rst_i) begin
            sb_q <= '0;
        end
        else begin
            sb_q <= sb_d;
        end
    end

endmodule
