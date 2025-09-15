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
    output wire [DATA_ADDR_WIDTH-1:0] cpu_data_mem_raddr,
    input wire [DATA_WIDTH-1:0] data_mem_rdata,
    input wire data_mem_hazard,
    output wire [DATA_ADDR_WIDTH-1:0] cpu_data_mem_waddr,
    output wire [DATA_WIDTH-1:0] cpu_data_mem_wdata,
    output wire cpu_data_mem_write
);

wire PC_take_branch_EX;
wire PC_take_jalr_EX;
wire signed [INST_ADDR_WIDTH-1:0] PC_for_jalr_EX;
wire signed [INST_ADDR_WIDTH-1:0] PC_for_normal_branch_EX;
wire signed [INST_ADDR_WIDTH-1:0] PC_for_normal_PC_plus_4;
wire [INST_ADDR_WIDTH-1:0] n_PC;
assign PC_for_normal_PC_plus_4 = PC_plus_4_IF_ID_i;
PC_datapath #( .INST_WIDTH(INST_WIDTH), .INST_ADDR_WIDTH(INST_ADDR_WIDTH)) u_PC_datapath (
    .PC_take_branch(PC_take_branch_EX),
    .PC_take_jalr(PC_take_jalr_EX),
    .PC_for_normal_PC_plus_4(PC_for_normal_PC_plus_4),
    .PC_for_normal_branch(PC_for_normal_branch_EX),
    .PC_for_jalr(PC_for_jalr_EX),
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
wire [REGISTER_ADDR_WIDTH-1:0] rs1_ID;
wire [REGISTER_ADDR_WIDTH-1:0] rs2_ID;
wire [REGISTER_ADDR_WIDTH-1:0] rd_ID;
wire signed [DATA_WIDTH-1:0] imm_ID;

wire reg_write_ID;
wire [1:0] result_sel_ID;
wire mem_write_ID;
wire [1:0] uncond_jump_ID;
wire meet_branch_ID;
wire [3:0] alu_ctrl_ID;
wire [1:0] alu_sel_rs1_ID;
wire [1:0] alu_sel_rs2_ID;
wire pc_jal_sel_ID;
wire [DATA_WIDTH-1:0] RD1D_ID, RD2D_ID;
wire [2:0] funct3_ID;

ID_datapath #( .INST_WIDTH(INST_WIDTH), .INST_ADDR_WIDTH(INST_ADDR_WIDTH), .DATA_WIDTH(DATA_WIDTH), .DATA_ADDR_WIDTH(DATA_ADDR_WIDTH)) u_ID_datapath (
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
    .alu_sel_rs1_ID(alu_sel_rs1_ID),
    .alu_sel_rs2_ID(alu_sel_rs2_ID),
    .pc_jal_sel_ID(pc_jal_sel_ID),
    .funct3_ID(funct3_ID)
);

wire [INST_ADDR_WIDTH-1:0] PC_ID_EX_o;
wire [INST_ADDR_WIDTH-1:0] PC_plus_4_ID_EX_o;
wire [INST_WIDTH-1:0] INST_ID_EX_o;
wire [REGISTER_ADDR_WIDTH-1:0] rs1_ID_EX_o;
wire [REGISTER_ADDR_WIDTH-1:0] rs2_ID_EX_o;
wire [REGISTER_ADDR_WIDTH-1:0] rd_ID_EX_o;
wire signed [DATA_WIDTH-1:0] imm_ID_EX_o;
wire reg_write_ID_EX_o;
wire [1:0] result_sel_ID_EX_o;
wire mem_write_ID_EX_o;
wire [1:0] uncond_jump_ID_EX_o;
wire meet_branch_ID_EX_o;
wire [3:0] alu_ctrl_ID_EX_o;
wire [1:0] alu_sel_rs1_ID_EX_o;
wire [1:0] alu_sel_rs2_ID_EX_o;
wire pc_jal_sel_ID_EX_o;
wire [DATA_WIDTH-1:0] RD1D_ID_EX_o;
wire [DATA_WIDTH-1:0] RD2D_ID_EX_o;
wire [2:0] funct3_ID_EX_o;

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
    .alu_sel_rs1_ID_EX_i(alu_sel_rs1_ID),
    .alu_sel_rs2_ID_EX_i(alu_sel_rs2_ID),
    .pc_jal_sel_ID_EX_i(pc_jal_sel_ID),
    .RD1D_ID_EX_i(RD1D_ID),
    .RD2D_ID_EX_i(RD2D_ID),
    .funct3_ID_EX_i(funct3_ID),

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
    .alu_sel_rs1_ID_EX_o(alu_sel_rs1_ID_EX_o),
    .alu_sel_rs2_ID_EX_o(alu_sel_rs2_ID_EX_o),
    .pc_jal_sel_ID_EX_o(pc_jal_sel_ID_EX_o),
    .RD1D_ID_EX_o(RD1D_ID_EX_o),
    .RD2D_ID_EX_o(RD2D_ID_EX_o),
    .funct3_ID_EX_o(funct3_ID_EX_o)
);

wire [INST_WIDTH-1:0] INST_EX;
wire reg_write_EX;
wire mem_write_EX;
wire [1:0] result_sel_EX;
wire signed [DATA_WIDTH-1:0] alu_res_EX;
wire [REGISTER_ADDR_WIDTH-1:0] rs1_EX;
wire [REGISTER_ADDR_WIDTH-1:0] rs2_EX;
wire [REGISTER_ADDR_WIDTH-1:0] rd_EX;
wire signed [DATA_WIDTH-1:0] write_data_EX;
wire [INST_ADDR_WIDTH-1:0] PC_plus_4_EX;
wire [2:0] funct3_EX;

EX_datapath #( .INST_WIDTH(INST_WIDTH), .INST_ADDR_WIDTH(INST_ADDR_WIDTH), .DATA_WIDTH(DATA_WIDTH), .DATA_ADDR_WIDTH(DATA_ADDR_WIDTH)) u_EX_datapath (
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
    .alu_sel_rs1_ID_EX_o(alu_sel_rs1_ID_EX_o),
    .alu_sel_rs2_ID_EX_o(alu_sel_rs2_ID_EX_o),
    .pc_jal_sel_ID_EX_o(pc_jal_sel_ID_EX_o),
    .RD1D_ID_EX_o(RD1D_ID_EX_o),
    .RD2D_ID_EX_o(RD2D_ID_EX_o),
    .funct3_ID_EX_o(funct3_ID_EX_o),

    // for forward rs1
    .forward_detect_EX_rs1(forward_detect_rs1),
    .alu_res_EX_MEM_o(alu_res_MEM),
    .result_WB(result_WB),
    // for forward rs2
    .forward_detect_EX_rs2(forward_detect_rs2),

    .INST_EX(INST_EX),
    .reg_write_EX(reg_write_EX),
    .mem_write_EX(mem_write_EX),
    .result_sel_EX(result_sel_EX),
    .alu_res_EX(alu_res_EX),
    .rs1_EX(rs1_EX),
    .rs2_EX(rs2_EX),
    .rd_EX(rd_EX),
    .write_data_EX(write_data_EX),
    .PC_plus_4_EX(PC_plus_4_EX),
    .PC_take_branch_EX(PC_take_branch_EX),
    .PC_take_jalr_EX(PC_take_jalr_EX),
    .PC_for_jalr_EX(PC_for_jalr_EX),
    .PC_for_normal_branch_EX(PC_for_normal_branch_EX),
    .funct3_EX(funct3_EX)
);

wire [INST_WIDTH-1:0] INST_EX_MEM_o;
wire reg_write_EX_MEM_o;
wire mem_write_EX_MEM_o;
wire [1:0] result_sel_EX_MEM_o;
wire signed [DATA_WIDTH-1:0] alu_res_EX_MEM_o;
wire [REGISTER_ADDR_WIDTH-1:0] rd_EX_MEM_o;
wire signed [DATA_WIDTH-1:0] write_data_EX_MEM_o;
wire [INST_ADDR_WIDTH-1:0] PC_plus_4_EX_MEM_o;
wire [2:0] funct3_EX_MEM_o;

EX_MEM_pipeline #( .INST_WIDTH(INST_WIDTH), .INST_ADDR_WIDTH(INST_ADDR_WIDTH), .DATA_WIDTH(DATA_WIDTH), .DATA_ADDR_WIDTH(DATA_ADDR_WIDTH), .REGISTER_WIDTH(REGISTER_WIDTH), .REGISTER_ADDR_WIDTH(REGISTER_ADDR_WIDTH)) u_EX_MEM_pipeline (
    .cpu_clk(cpu_clk),
    .cpu_rst_n(cpu_rst_n),
    .INST_EX_MEM_i(INST_EX),
    .reg_write_EX_MEM_i(reg_write_EX),
    .mem_write_EX_MEM_i(mem_write_EX),
    .result_sel_EX_MEM_i(result_sel_EX),
    .alu_res_EX_MEM_i(alu_res_EX),
    .rd_EX_MEM_i(rd_EX),
    .write_data_EX_MEM_i(write_data_EX),
    .PC_plus_4_EX_MEM_i(PC_plus_4_EX),
    .funct3_EX_MEM_i(funct3_EX),

    .INST_EX_MEM_o(INST_EX_MEM_o),
    .reg_write_EX_MEM_o(reg_write_EX_MEM_o),
    .mem_write_EX_MEM_o(mem_write_EX_MEM_o),
    .result_sel_EX_MEM_o(result_sel_EX_MEM_o),
    .alu_res_EX_MEM_o(alu_res_EX_MEM_o),
    .rd_EX_MEM_o(rd_EX_MEM_o),
    .write_data_EX_MEM_o(write_data_EX_MEM_o),
    .PC_plus_4_EX_MEM_o(PC_plus_4_EX_MEM_o),
    .funct3_EX_MEM_o(funct3_EX_MEM_o)
);

wire [INST_WIDTH-1:0] INST_MEM;
wire reg_write_MEM;
wire mem_write_MEM;
wire [1:0] result_sel_MEM;
wire signed [DATA_WIDTH-1:0] alu_res_MEM;
wire [REGISTER_ADDR_WIDTH-1:0] rd_MEM;
wire [DATA_WIDTH-1:0] write_data_MEM;
wire [INST_ADDR_WIDTH-1:0] PC_plus_4_MEM;
wire [2:0] funct3_MEM;

MEM_datapath #( .INST_WIDTH(INST_WIDTH), .INST_ADDR_WIDTH(INST_ADDR_WIDTH), .DATA_WIDTH(DATA_WIDTH), .DATA_ADDR_WIDTH(DATA_ADDR_WIDTH), .REGISTER_WIDTH(REGISTER_WIDTH), .REGISTER_ADDR_WIDTH(REGISTER_ADDR_WIDTH)) u_MEM_datapath (
    .INST_EX_MEM_o(INST_EX_MEM_o),
    .reg_write_EX_MEM_o(reg_write_EX_MEM_o),
    .mem_write_EX_MEM_o(mem_write_EX_MEM_o),
    .result_sel_EX_MEM_o(result_sel_EX_MEM_o),
    .alu_res_EX_MEM_o(alu_res_EX_MEM_o),
    .rd_EX_MEM_o(rd_EX_MEM_o),
    .write_data_EX_MEM_o(write_data_EX_MEM_o),
    .PC_plus_4_EX_MEM_o(PC_plus_4_EX_MEM_o),
    .funct3_EX_MEM_o(funct3_EX_MEM_o),
    .INST_MEM(INST_MEM),
    .reg_write_MEM(reg_write_MEM),
    .mem_write_MEM(mem_write_MEM),
    .result_sel_MEM(result_sel_MEM),
    .alu_res_MEM(alu_res_MEM),
    .rd_MEM(rd_MEM),
    .write_data_MEM(write_data_MEM),
    .PC_plus_4_MEM(PC_plus_4_MEM),
    .funct3_MEM(funct3_MEM)
);

assign cpu_data_mem_raddr = alu_res_MEM;
assign cpu_data_mem_waddr = alu_res_MEM;
assign cpu_data_mem_wdata = write_data_MEM;
assign cpu_data_mem_write = mem_write_MEM;

wire [INST_WIDTH-1:0] INST_MEM_WB_o;
wire reg_write_MEM_WB_o;
wire [1:0] result_sel_MEM_WB_o;
wire signed [DATA_WIDTH-1:0] alu_res_MEM_WB_o;
wire [DATA_WIDTH-1:0] data_mem_rdata_MEM_WB_o;
wire [REGISTER_ADDR_WIDTH-1:0] rd_MEM_WB_o;
wire [INST_ADDR_WIDTH-1:0] PC_plus_4_MEM_WB_o;
wire [2:0] funct3_MEM_WB_o;

MEM_WB_pipeline #( .INST_WIDTH(INST_WIDTH), .INST_ADDR_WIDTH(INST_ADDR_WIDTH), .DATA_WIDTH(DATA_WIDTH), .DATA_ADDR_WIDTH(DATA_ADDR_WIDTH), .REGISTER_WIDTH(REGISTER_WIDTH), .REGISTER_ADDR_WIDTH(REGISTER_ADDR_WIDTH)) u_MEM_WB_pipeline (
    .cpu_clk(cpu_clk),
    .cpu_rst_n(cpu_rst_n),
    .INST_MEM_WB_i(INST_MEM),
    .reg_write_MEM_WB_i(reg_write_MEM),
    .result_sel_MEM_WB_i(result_sel_MEM),
    .data_mem_rdata_MEM_WB_i(data_mem_rdata),
    .alu_res_MEM_WB_i(alu_res_MEM),
    .rd_MEM_WB_i(rd_MEM),
    .PC_plus_4_MEM_WB_i(PC_plus_4_MEM),
    .funct3_MEM_WB_i(funct3_MEM),
    .INST_MEM_WB_o(INST_MEM_WB_o),
    .reg_write_MEM_WB_o(reg_write_MEM_WB_o),
    .result_sel_MEM_WB_o(result_sel_MEM_WB_o),
    .alu_res_MEM_WB_o(alu_res_MEM_WB_o),
    .data_mem_rdata_MEM_WB_o(data_mem_rdata_MEM_WB_o),
    .rd_MEM_WB_o(rd_MEM_WB_o),
    .PC_plus_4_MEM_WB_o(PC_plus_4_MEM_WB_o),
    .funct3_MEM_WB_o(funct3_MEM_WB_o)
);

wire [INST_WIDTH-1:0] INST_WB;
wire reg_write_WB;
wire [REGISTER_ADDR_WIDTH-1:0] rd_WB;
wire [DATA_WIDTH-1:0] result_WB;
wire [2:0] funct3_WB;

WB_datapath #( .INST_WIDTH(INST_WIDTH), .INST_ADDR_WIDTH(INST_ADDR_WIDTH), .DATA_WIDTH(DATA_WIDTH), .DATA_ADDR_WIDTH(DATA_ADDR_WIDTH), .REGISTER_WIDTH(REGISTER_WIDTH), .REGISTER_ADDR_WIDTH(REGISTER_ADDR_WIDTH)) u_WB_datapath (
    .INST_MEM_WB_o(INST_MEM_WB_o),
    .reg_write_MEM_WB_o(reg_write_MEM_WB_o),
    .result_sel_MEM_WB_o(result_sel_MEM_WB_o),
    .alu_res_MEM_WB_o(alu_res_MEM_WB_o),
    .data_mem_rdata_MEM_WB_o(data_mem_rdata_MEM_WB_o),
    .rd_MEM_WB_o(rd_MEM_WB_o),
    .PC_plus_4_MEM_WB_o(PC_plus_4_MEM_WB_o),
    .funct3_MEM_WB_o(funct3_MEM_WB_o),
    .INST_WB(INST_WB),
    .reg_write_WB(reg_write_WB),
    .rd_WB(rd_WB),
    .result_WB(result_WB),
    .funct3_WB(funct3_WB)
);

wire stall_PC_IF,stall_IF_ID;
wire flush_IF_ID, flush_ID_EX;

hazard_detection #(.REGISTER_ADDR_WIDTH(REGISTER_ADDR_WIDTH)) u_hazard_detction (
    .inst_mem_hazard(inst_mem_hazard),
    .data_mem_hazard(data_mem_hazard),
    .rs1_ID(rs1_ID),
    .rs2_ID(rs2_ID),
    .rd_EX(rd_EX),
    .result_sel_EX(result_sel_EX),
    .PC_take_branch_EX(PC_take_branch_EX),
    .PC_take_jalr_EX(PC_take_jalr_EX),
    .stall_PC_IF(stall_PC_IF),
    .stall_IF_ID(stall_IF_ID),
    .flush_IF_ID(flush_IF_ID),
    .flush_ID_EX(flush_ID_EX)
);

wire [2:0] forward_detect_rs1;
wire [2:0] forward_detect_rs2;

forward_detection #(.REGISTER_ADDR_WIDTH(REGISTER_ADDR_WIDTH)) u_forward_detection (
    .rs1_ID(rs1_ID),
    .rs2_ID(rs2_ID),
    .rs1_EX(rs1_EX),
    .rs2_EX(rs2_EX),
    .rd_MEM(rd_MEM),
    .rd_WB(rd_WB),
    .forward_detect_rs1(forward_detect_rs1),
    .forward_detect_rs2(forward_detect_rs2)
);

regfile #(.INIT_STYLE(1), .REGISTER_WIDTH(REGISTER_WIDTH), .REGISTER_ADDR_WIDTH(REGISTER_ADDR_WIDTH)) u_regfile (
    .cpu_clk(cpu_clk),
    .cpu_rst_n(cpu_rst_n),
    .forward_detect_rs1(forward_detect_rs1),
    .forward_detect_rs2(forward_detect_rs2),
    .rs1_addr(rs1_ID),
    .rs2_addr(rs2_ID),
    .rs1_data(RD1D_ID),
    .rs2_data(RD2D_ID),
    .wd_addr(rd_WB),
    .we(reg_write_WB),
    .wd_data(result_WB)
);

endmodule