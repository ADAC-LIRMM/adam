/*
 * Copyright 2025 LIRMM
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

`include "adam/macros.svh"

module adam_core_cv32e40x #(
    `ADAM_CFG_PARAMS
) (
    ADAM_SEQ.Slave   seq,
    ADAM_PAUSE.Slave pause,

    input ADDR_T boot_addr,
    input DATA_T hart_id,

    AXI_LITE.Master axil_inst,
    AXI_LITE.Master axil_data,

    input logic irq,

    input  logic debug_req,
    output logic debug_unavail
);

    cv32e40x_if_xif xif ();

    ADAM_PAUSE pause_inst ();
    ADAM_PAUSE pause_data ();

    logic  inst_req;
    logic  inst_gnt;
    logic  inst_rvalid;
    logic  inst_rready;
    ADDR_T inst_addr;
    STRB_T inst_be;
    DATA_T inst_wdata;
    logic  inst_we;
    DATA_T inst_rdata;

    logic  data_req;
    logic  data_gnt;
    logic  data_rvalid;
    logic  data_rready;
    ADDR_T data_addr;
    STRB_T data_be;
    DATA_T data_wdata;
    logic  data_we;
    DATA_T data_rdata;

    assign inst_rready = 1;
    assign inst_be     = 0;
    assign inst_wdata  = 0;
    assign inst_we     = 0;

    assign data_rready = 1;

    assign debug_unavail = pause.req || pause.ack;

    cv32e40x_core #(
        .X_EXT (0)
    ) i_cv32e40x_core (
        // Clock and reset
        .rst_ni       (!seq.rst),
        .clk_i        (seq.clk),
        .scan_cg_en_i ('0),

        // Static Configuration
        .boot_addr_i         (boot_addr),
        .dm_exception_addr_i (DEBUG_ADDR_EXCEPTION),
        .dm_halt_addr_i      (DEBUG_ADDR_HALT),
        .mhartid_i           (hart_id),
        .mimpid_patch_i      ('0),
        .mtvec_addr_i        (boot_addr),

        // Instruction memory interface
        .instr_req_o     (inst_req),
        .instr_gnt_i     (inst_gnt),
        .instr_rvalid_i  (inst_rvalid),
        .instr_addr_o    (inst_addr),
        .instr_memtype_o (),
        .instr_prot_o    (),
        .instr_dbg_o     (),
        .instr_rdata_i   (inst_rdata),
        .instr_err_i     ('0),

        // Data memory interface
        .data_req_o     (data_req),
        .data_gnt_i     (data_gnt),
        .data_rvalid_i  (data_rvalid),
        .data_addr_o    (data_addr),
        .data_be_o      (data_be),
        .data_we_o      (data_we),
        .data_wdata_o   (data_wdata),
        .data_memtype_o (),
        .data_prot_o    (),
        .data_dbg_o     (),
        .data_atop_o    (),
        .data_rdata_i   (data_rdata),
        .data_err_i     ('0),
        .data_exokay_i  ('0),

        // Cycle count
        .mcycle_o (),

        // Time input
        .time_i ('0),

        // eXtension interface
        .xif_compressed_if (xif),
        .xif_issue_if      (xif),
        .xif_commit_if     (xif),
        .xif_mem_if        (xif),
        .xif_mem_result_if (xif),
        .xif_result_if     (xif),

        // Basic Interrupt interface
        .irq_i     ({20'b0, irq, 11'b0}),

        .wu_wfe_i ('0),

        // CLIC interrupt architecture
        .clic_irq_i       (),
        .clic_irq_id_i    (),
        .clic_irq_level_i (),
        .clic_irq_priv_i  (),
        .clic_irq_shv_i   (),

        // Fence.i flush handshake
        .fencei_flush_req_o (),
        .fencei_flush_ack_i ('0),

        // Debug interface
        .debug_req_i       (debug_req),
        .debug_havereset_o (),
        .debug_running_o   (),
        .debug_halted_o    (),
        .debug_pc_valid_o  (),
        .debug_pc_o        (),

        // CPU control signals
        .fetch_enable_i  ('1),
        .core_sleep_o    ()
    );

    adam_obi_to_axil #(
        `ADAM_CFG_PARAMS_MAP
    ) instr_adam_obi_to_axil (
        .seq   (seq),
        .pause (pause_inst),

        .axil (axil_inst),

        .req    (inst_req),
        .gnt    (inst_gnt),
        .addr   (inst_addr),
        .we     ('0),
        .be     ('0),
        .wdata  ('0),
        .rvalid (inst_rvalid),
        .rready (inst_rready),
        .rdata  (inst_rdata)
    );

    adam_obi_to_axil #(
        `ADAM_CFG_PARAMS_MAP
    ) data_adam_obi_to_axil (
        .seq   (seq),
        .pause (pause_data),

        .axil (axil_data),

        .req    (data_req),
        .gnt    (data_gnt),
        .addr   (data_addr),
        .we     (data_we),
        .be     (data_be),
        .wdata  (data_wdata),
        .rvalid (data_rvalid),
        .rready (data_rready),
        .rdata  (data_rdata)
    );

    // pause ==================================================================

    ADAM_PAUSE pause_null ();
    ADAM_PAUSE temp_pause [3] ();
    assign temp_pause[0].ack        = pause_inst.ack;
    assign temp_pause[1].ack        = pause_data.ack;
    assign temp_pause[2].ack        = pause_null.ack;
    assign pause_inst.req           = temp_pause[0].req;
    assign pause_data.req           = temp_pause[1].req;
    assign pause_null.req           = temp_pause[2].req;

    adam_pause_demux #(
        `ADAM_CFG_PARAMS_MAP,

        .NO_MSTS  (2),
        .PARALLEL (1)
    ) adam_pause_demux (
        .seq (seq),

        .slv (pause),
        .mst (temp_pause)
    );

endmodule
