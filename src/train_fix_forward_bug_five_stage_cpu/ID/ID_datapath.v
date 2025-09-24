`include "riscv_defs.vh"

module ID_datapath #(
    parameter INST_WIDTH = 32,
    parameter INST_ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32,
    parameter DATA_ADDR_WIDTH = 32
)(
    input wire [INST_WIDTH-1:0] INST_IF_ID_o,
    input wire [INST_ADDR_WIDTH-1:0] PC_IF_ID_o,
    output reg [INST_ADDR_WIDTH-1:0] PC_ID,
    input wire [INST_ADDR_WIDTH-1:0] PC_plus_4_IF_ID_o,
    output reg [INST_ADDR_WIDTH-1:0] PC_plus_4_ID,
    output reg [INST_WIDTH-1:0] INST_ID,
    output reg [5-1:0] rs1_ID,
    output reg [5-1:0] rs2_ID,
    output reg [5-1:0] rd_ID,
    output reg signed [DATA_WIDTH-1:0] imm_ID,

    output wire reg_write_ID,
    output wire [1:0] result_sel_ID,
    output wire mem_write_ID,
    output wire [1:0] uncond_jump_ID,
    output wire meet_branch_ID,
    output wire [3:0] alu_ctrl_ID,
    output wire [1:0] alu_sel_rs1_ID,
    output wire [1:0] alu_sel_rs2_ID,
    output wire pc_jal_sel_ID,
    output reg [2:0] funct3_ID
);

always @(*) begin
    INST_ID = INST_IF_ID_o;
    PC_ID = PC_IF_ID_o;
    PC_plus_4_ID = PC_plus_4_IF_ID_o;
    funct3_ID = INST_IF_ID_o[14:12];
end

wire [7-1:0] funct7;
wire [3-1:0] funct3;
wire [6:0] opcode;

decoder #(.INST_WIDTH(INST_WIDTH),.DATA_WIDTH(DATA_WIDTH)) u_decoder (
    .inst(INST_ID),
    .funct7(funct7),
    .funct3(funct3),
    .opcode(opcode),
    .rs1(rs1_ID),
    .rs2(rs2_ID),
    .rd(rd_ID),
    .imm(imm_ID)
);
control_unit u_control_unit (
    .funct7(funct7),
    .funct3(funct3),
    .opcode(opcode),
    .reg_write_ID(reg_write_ID),
    .result_sel_ID(result_sel_ID),
    .mem_write_ID(mem_write_ID),
    .uncond_jump_ID(uncond_jump_ID),
    .meet_branch_ID(meet_branch_ID),
    .alu_ctrl_ID(alu_ctrl_ID),
    .alu_sel_rs1_ID(alu_sel_rs1_ID),
    .alu_sel_rs2_ID(alu_sel_rs2_ID),
    .pc_jal_sel_ID(pc_jal_sel_ID)
);

endmodule

// src/L1_cache/data_mem.v
// src/L1_cache/inst_mem.v
// src/L1_cache/L1_cache.v
// src/basic_five_stage_cpu/cpu.v
// src/basic_five_stage_cpu/EX_MEM_pipeline.v
// src/basic_five_stage_cpu/forward_detection.v
// src/basic_five_stage_cpu/hazard_detection.v
// src/basic_five_stage_cpu/ID_EX_pipeline.v
// src/basic_five_stage_cpu/IF_ID_pipeline.v
// src/basic_five_stage_cpu/memory_hazard.v
// src/basic_five_stage_cpu/MEM_WB_pipeline.v
// src/basic_five_stage_cpu/PC_IF_pipeline.v
// src/basic_five_stage_cpu/regfile.v
// src/train_fix_forward_bug_five_stage_cpu/IF/IF_datapath.v
// src/train_fix_forward_bug_five_stage_cpu/PC/PC_datapath.v
// src/train_fix_forward_bug_five_stage_cpu/ID/control_unit.v
// src/train_fix_forward_bug_five_stage_cpu/ID/decoder.v
// src/train_fix_forward_bug_five_stage_cpu/ID/ID_datapath.v
// src/train_fix_forward_bug_five_stage_cpu/ID/imm_unit.v
// src/train_fix_forward_bug_five_stage_cpu/EX/alu.v src/train_fix_forward_bug_five_stage_cpu/EX/compare.v src/train_fix_forward_bug_five_stage_cpu/EX/EX_datapath.v src/train_fix_forward_bug_five_stage_cpu/EX/handle_rs1_for_alu.v src/train_fix_forward_bug_five_stage_cpu/EX/handle_rs2_for_alu.v src/train_fix_forward_bug_five_stage_cpu/MEM/MEM_datapath.v src/train_fix_forward_bug_five_stage_cpu/WB/WB_datapath.v