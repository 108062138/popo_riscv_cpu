module EX_datapath #(
    parameter INST_WIDTH = 32,
    parameter INST_ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32,
    parameter DATA_ADDR_WIDTH = 32
)(
    input wire [INST_ADDR_WIDTH-1:0] PC_ID_EX_o,
    input wire [INST_ADDR_WIDTH-1:0] PC_plus_4_ID_EX_o,
    input wire [INST_WIDTH-1:0] INST_ID_EX_o,
    input wire [5-1:0] rs1_ID_EX_o,
    input wire [5-1:0] rs2_ID_EX_o,
    input wire [5-1:0] rd_ID_EX_o,
    input wire signed [DATA_WIDTH-1:0] imm_ID_EX_o,
    input wire reg_write_ID_EX_o,
    input wire [1:0] result_sel_ID_EX_o,
    input wire mem_write_ID_EX_o,
    input wire uncond_jump_ID_EX_o,
    input wire meet_branch_ID_EX_o,
    input wire [3:0] alu_ctrl_ID_EX_o,
    input wire [1:0] alu_sel_rs1_ID_EX_o,
    input wire [1:0] alu_sel_rs2_ID_EX_o,
    input wire pc_jal_sel_ID_EX_o,
    input wire [DATA_WIDTH-1:0] RD1D_ID_EX_o,
    input wire [DATA_WIDTH-1:0] RD2D_ID_EX_o,

    // for forward rs1
    input wire [2:0] forward_detect_EX_rs1,
    input wire [DATA_WIDTH-1:0] alu_res_EX_MEM_o,
    input wire [DATA_WIDTH-1:0] result_WB,
    // for forward rs2
    input wire [2:0] forward_detect_EX_rs2,

    output reg [INST_WIDTH-1:0] INST_EX,
    output reg reg_write_EX,
    output reg mem_write_EX,
    output reg [1:0] result_sel_EX,
    output wire signed [DATA_WIDTH-1:0] alu_res_EX,
    output reg [5-1:0] rd_EX,
    output wire signed [DATA_WIDTH-1:0] write_data_EX,
    output reg [INST_ADDR_WIDTH-1:0] PC_plus_4_EX
);

wire signed [DATA_WIDTH-1:0] alu_in_rs1;
wire signed [DATA_WIDTH-1:0] alu_in_rs2;

always @(*) begin
    INST_EX = INST_ID_EX_o;
    reg_write_EX = reg_write_ID_EX_o;
    mem_write_EX = mem_write_ID_EX_o;
    result_sel_EX = result_sel_ID_EX_o;

    rd_EX = rd_ID_EX_o;
end

alu #(.DATA_WIDTH(DATA_WIDTH)) u_alu (
    .alu_in_rs1(alu_in_rs1),
    .alu_in_rs2(alu_in_rs2),
    .alu_ctrl_ID_EX_o(alu_ctrl_ID_EX_o),
    .alu_res(alu_res_EX)
);

handle_rs1_for_alu #(.DATA_WIDTH(DATA_WIDTH)) u_handle_rs1_for_alu (
    .forward_detect_EX_rs1(forward_detect_EX_rs1),
    .RD1D_ID_EX_o(RD1D_ID_EX_o),
    .alu_res_EX_MEM_o(alu_res_EX_MEM_o),
    .result_WB(result_WB),
    .alu_sel_rs1_ID_EX_o(alu_sel_rs1_ID_EX_o),
    .PC_ID_EX_o(PC_ID_EX_o),
    .rs1_for_alu_res(alu_in_rs1)
);

handle_rs2_for_alu #(.DATA_WIDTH(DATA_WIDTH)) u_handle_rs2_for_alu (
    .forward_detect_EX_rs2(forward_detect_EX_rs2),
    .RD2D_ID_EX_o(RD2D_ID_EX_o),
    .alu_res_EX_MEM_o(alu_res_EX_MEM_o),
    .result_WB(result_WB),
    .alu_sel_rs2_ID_EX_o(alu_sel_rs2_ID_EX_o),
    .mux_for_rs2_EX_forward_res(write_data_EX),
    .imm_ID_EX_o(imm_ID_EX_o),
    .rs2_for_alu_res(alu_in_rs2)
);

endmodule