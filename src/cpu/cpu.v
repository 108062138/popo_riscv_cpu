module cpu #(
    parameter INST_WIDTH = 32,
    parameter INST_ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32,
    parameter DATA_ADDR_WIDTH = 32,
    parameter REGISTER_WIDTH = 32,
    parameter REGISTER_ADDR_WIDTH = 5
)(
    input wire cpu_clk,
    input wire cpu_rst_n,

    output wire [INST_ADDR_WIDTH-1:0] PC,
    input wire [INST_WIDTH-1:0] INST,
    input wire inst_mem_hazard,
    input wire [DATA_ADDR_WIDTH-1:0] cpu_data_mem_raddr,
    input wire [DATA_WIDTH-1:0] data_mem_rdata,
    input wire data_mem_hazard,
    output wire [DATA_ADDR_WIDTH-1:0] cpu_data_mem_waddr,
    output wire [DATA_WIDTH-1:0] cpu_data_mem_wdata,
    output wire cpu_data_mem_write
);

wire PC_take_branch, PC_take_jalr;
wire [INST_ADDR_WIDTH-1:0] PC_for_normal_PC_plus_4, PC_for_normal_branch, PC_for_jalr;
wire [INST_ADDR_WIDTH-1:0] n_PC;
assign PC_for_normal_PC_plus_4 = PC_plus_4_IF_ID_i;
PC_datapath #( .INST_WIDTH(INST_WIDTH), .INST_ADDR_WIDTH(INST_ADDR_WIDTH)) u_PC_datapath (
    .PC_take_branch(PC_take_branch),
    .PC_take_jalr(PC_take_jalr),
    .PC_for_normal_PC_plus_4(PC_for_normal_PC_plus_4),
    .PC_for_normal_branch(PC_for_normal_branch),
    .PC_for_jalr(PC_for_jalr),
    .n_PC(n_PC)
);

PC_IF_pipeline #( .INST_WIDTH(INST_WIDTH), .INST_ADDR_WIDTH(INST_ADDR_WIDTH)) u_PC_IF_pipeline (
    .cpu_clk(cpu_clk),
    .cpu_rst_n(cpu_rst_n),
    .stall_PC_IF(stall_PC_IF),
    .n_PC(n_PC),
    .PC(PC)
);


wire [INST_ADDR_WIDTH-1:0] PC_plus_4_IF_ID_i;
// IF datapath is too small
IF_datapath #( .INST_WIDTH(INST_WIDTH), .INST_ADDR_WIDTH(INST_ADDR_WIDTH)) u_IF_datapath (
    .PC(PC),
    .PC_plus_4_i(PC_plus_4_IF_ID_i)
);


wire [INST_ADDR_WIDTH-1:0] PC_IF_ID_o, PC_plus_4_IF_ID_o;
wire [INST_WIDTH-1:0] INST_IF_ID_o;
IF_ID_pipeline #( .INST_WIDTH(INST_WIDTH), .INST_ADDR_WIDTH(INST_ADDR_WIDTH)) u_IF_ID_pipeline (
    .cpu_clk(cpu_clk),
    .cpu_rst_n(cpu_rst_n),
    .stall_IF_ID(stall_IF_ID),
    .flush_IF_ID(flush_IF_ID),
    .PC_IF_ID_i(PC),
    .PC_IF_ID_o(PC_IF_ID_o),
    .PC_plus_4_IF_ID_i(PC_plus_4_IF_ID_i),
    .PC_plus_4_IF_ID_o(PC_plus_4_IF_ID_o),
    .INST_IF_ID_i(INST),
    .INST_IF_ID_o(INST_IF_ID_o)
);

wire [INST_ADDR_WIDTH-1:0] PC_ID;
wire [INST_ADDR_WIDTH-1:0] PC_plus_4_ID;
wire [INST_WIDTH-1:0] INST_ID;
wire [5-1:0] rs1_ID;
wire [5-1:0] rs2_ID;
wire [5-1:0] rd_ID;
wire signed [DATA_WIDTH-1:0] imm_ID;

wire reg_write_ID;
wire [1:0] result_sel_ID;
wire mem_write_ID;
wire uncond_jump_ID;
wire meet_branch_ID;
wire alu_ctrl_ID;
wire [1:0] alu_sel_0_ID;
wire [1:0] alu_sel_1_ID;
wire pc_jal_sel_ID;

wire [DATA_WIDTH-1:0] RD1D_ID, RD2D_ID;

ID_datapath #( .INST_WIDTH(INST_WIDTH), .INST_ADDR_WIDTH(INST_ADDR_WIDTH), .DATA_WIDTH(DATA_WIDTH), .DATA_ADDR_WIDTH(DATA_ADDR_WIDTH) ) u_ID_datapath (
    .INST_IF_ID_o(INST_IF_ID_o),
    .PC_IF_ID_o(PC_IF_ID_o),
    .PC_ID(PC_ID),
    .PC_plus_4_IF_ID_o(PC_plus_4_IF_ID_o),
    .PC_plus_4_ID(PC_plus_4_ID),
    .INST_ID(INST_ID),
    .rs1_ID(rs1_ID),
    .rs2_ID(rs2_ID),
    .rd_ID(rd_ID),
    .imm_ID(imm_ID),

    .reg_write_ID(reg_write_ID),
    .result_sel_ID(result_sel_ID),
    .mem_write_ID(mem_write_ID),
    .uncond_jump_ID(uncond_jump_ID),
    .meet_branch_ID(meet_branch_ID),
    .alu_ctrl_ID(alu_ctrl_ID),
    .alu_sel_0_ID(alu_sel_0_ID),
    .alu_sel_1_ID(alu_sel_1_ID),
    .pc_jal_sel_ID(pc_jal_sel_ID)
);

wire [INST_ADDR_WIDTH-1:0] PC_ID_EX_o;
wire [INST_ADDR_WIDTH-1:0] PC_plus_4_ID_EX_o;
wire [INST_WIDTH-1:0] INST_ID_EX_o;
wire [5-1:0] rs1_ID_EX_o;
wire [5-1:0] rs2_ID_EX_o;
wire [5-1:0] rd_ID_EX_o;
wire signed [DATA_WIDTH-1:0] imm_ID_EX_o;
wire reg_write_ID_EX_o;
wire [1:0] result_sel_ID_EX_o;
wire mem_write_ID_EX_o;
wire uncond_jump_ID_EX_o;
wire meet_branch_ID_EX_o;
wire alu_ctrl_ID_EX_o;
wire [1:0] alu_sel_0_ID_EX_o;
wire [1:0] alu_sel_1_ID_EX_o;
wire pc_jal_sel_ID_EX_o;
wire [REGISTER_WIDTH-1:0] RD1D_ID_EX_o;
wire [REGISTER_WIDTH-1:0] RD2D_ID_EX_o;

ID_EX_pipeline #( .INST_WIDTH(INST_WIDTH), .INST_ADDR_WIDTH(INST_ADDR_WIDTH), .DATA_WIDTH(DATA_WIDTH), .DATA_ADDR_WIDTH(DATA_ADDR_WIDTH) ) u_ID_EX_pipeline (
    .cpu_clk(cpu_clk),
    .cpu_rst_n(cpu_rst_n),
    .flush_ID_EX(flush_ID_EX),

    .PC_ID_EX_i(PC_ID),
    .PC_plus_4_ID_EX_i(PC_plus_4_ID),
    .INST_ID_EX_i(INST_ID),
    .rs1_ID_EX_i(rs1_ID),
    .rs2_ID_EX_i(rs2_ID),
    .rd_ID_EX_i(rd_ID),
    .imm_ID_EX_i(imm_ID),
    .reg_write_ID_EX_i(reg_write_ID),
    .result_sel_ID_EX_i(result_sel_ID),
    .mem_write_ID_EX_i(mem_write_ID),
    .uncond_jump_ID_EX_i(uncond_jump_ID),
    .meet_branch_ID_EX_i(meet_branch_ID),
    .alu_ctrl_ID_EX_i(alu_ctrl_ID),
    .alu_sel_0_ID_EX_i(alu_sel_0_ID),
    .alu_sel_1_ID_EX_i(alu_sel_1_ID),
    .pc_jal_sel_ID_EX_i(pc_jal_sel_ID),
    .RD1D_ID_EX_i(RD1D_ID),
    .RD2D_ID_EX_i(RD2D_ID),

    .PC_ID_EX_o(PC_ID_EX_o),
    .PC_plus_4_ID_EX_o(PC_plus_4_ID_EX_o),
    .INST_ID_EX_o(INST_ID_EX_o),
    .rs1_ID_EX_o(rs1_ID_EX_o),
    .rs2_ID_EX_o(rs2_ID_EX_o),
    .rd_ID_EX_o(rd_ID_EX_o),
    .imm_ID_EX_o(imm_ID_EX_o),
    .reg_write_ID_EX_o(reg_write_ID_EX_o),
    .result_sel_ID_EX_o(result_sel_ID_EX_o),
    .mem_write_ID_EX_o(mem_write_ID_EX_o),
    .uncond_jump_ID_EX_o(uncond_jump_ID_EX_o),
    .meet_branch_ID_EX_o(meet_branch_ID_EX_o),
    .alu_ctrl_ID_EX_o(alu_ctrl_ID_EX_o),
    .alu_sel_0_ID_EX_o(alu_sel_0_ID_EX_o),
    .alu_sel_1_ID_EX_o(alu_sel_1_ID_EX_o),
    .pc_jal_sel_ID_EX_o(pc_jal_sel_ID_EX_o),
    .RD1D_ID_EX_o(RD1D_ID_EX_o),
    .RD2D_ID_EX_o(RD2D_ID_EX_o)
);

wire stall_PC_IF,stall_IF_ID;
wire flush_IF_ID, flush_ID_EX;

hazard_detection u_hazard_detction ( .inst_mem_hazard(inst_mem_hazard), .data_mem_hazard(data_mem_hazard), .stall_PC_IF(stall_PC_IF), .stall_IF_ID(stall_IF_ID), .flush_IF_ID(flush_IF_ID), .flush_ID_EX(flush_ID_EX));

regfile #(.INIT_STYLE(1), .REGISTER_WIDTH(REGISTER_WIDTH), .REGISTER_ADDR_WIDTH(REGISTER_ADDR_WIDTH)) u_regfile (
    .cpu_clk(cpu_clk),
    .cpu_rst_n(cpu_rst_n),
    .rs1_addr(rs1_ID),
    .rs2_addr(rs2_ID),
    .rs1_data(RD1D_ID),
    .rs2_data(RD2D_ID),
    .rd_addr(0), // we haven't done WB stage
    .we(0), // we haven't done WB stage
    .rd_data(0) // we haven't done WB stage
);

endmodule