module ID_EX_pipeline #(
    parameter INST_WIDTH = 32,
    parameter INST_ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32,
    parameter DATA_ADDR_WIDTH = 32,
    parameter REGISTER_WIDTH = 32,
    parameter REGISTER_ADDR_WIDTH = 5
)(
    input wire cpu_clk,
    input wire cpu_rst_n,
    input wire flush_ID_EX,


    input wire [INST_ADDR_WIDTH-1:0] PC_ID_EX_i,
    input wire [INST_ADDR_WIDTH-1:0] PC_plus_4_ID_EX_i,
    input wire [INST_WIDTH-1:0] INST_ID_EX_i,
    input wire [5-1:0] rs1_ID_EX_i,
    input wire [5-1:0] rs2_ID_EX_i,
    input wire [5-1:0] rd_ID_EX_i,
    input signed [DATA_WIDTH-1:0] imm_ID_EX_i,
    input wire reg_write_ID_EX_i,
    input wire [1:0] result_sel_ID_EX_i,
    input wire mem_write_ID_EX_i,
    input wire uncond_jump_ID_EX_i,
    input wire meet_branch_ID_EX_i,
    input wire alu_ctrl_ID_EX_i,
    input wire [1:0] alu_sel_0_ID_EX_i,
    input wire [1:0] alu_sel_1_ID_EX_i,
    input wire pc_jal_sel_ID_EX_i,
    input wire [REGISTER_WIDTH-1:0] RD1D_ID_EX_i,
    input wire [REGISTER_WIDTH-1:0] RD2D_ID_EX_i,

    output reg [INST_ADDR_WIDTH-1:0] PC_ID_EX_o,
    output reg [INST_ADDR_WIDTH-1:0] PC_plus_4_ID_EX_o,
    output reg [INST_WIDTH-1:0] INST_ID_EX_o,
    output reg [5-1:0] rs1_ID_EX_o,
    output reg [5-1:0] rs2_ID_EX_o,
    output reg [5-1:0] rd_ID_EX_o,
    output reg signed [DATA_WIDTH-1:0] imm_ID_EX_o,
    output reg reg_write_ID_EX_o,
    output reg [1:0] result_sel_ID_EX_o,
    output reg mem_write_ID_EX_o,
    output reg uncond_jump_ID_EX_o,
    output reg meet_branch_ID_EX_o,
    output reg alu_ctrl_ID_EX_o,
    output reg [1:0] alu_sel_0_ID_EX_o,
    output reg [1:0] alu_sel_1_ID_EX_o,
    output reg pc_jal_sel_ID_EX_o,
    output reg [REGISTER_WIDTH-1:0] RD1D_ID_EX_o,
    output reg [REGISTER_WIDTH-1:0] RD2D_ID_EX_o
);

always @(posedge cpu_clk) begin
    if(!cpu_rst_n)begin
        PC_ID_EX_o <= 0;
        PC_plus_4_ID_EX_o <= 0;
        INST_ID_EX_o <= 0;
        rs1_ID_EX_o <= 0;
        rs2_ID_EX_o <= 0;
        rd_ID_EX_o <= 0;
        imm_ID_EX_o <= 0;
        reg_write_ID_EX_o <= 0;
        result_sel_ID_EX_o <= 0;
        mem_write_ID_EX_o <= 0;
        uncond_jump_ID_EX_o <= 0;
        meet_branch_ID_EX_o <= 0;
        alu_ctrl_ID_EX_o <= 0;
        alu_sel_0_ID_EX_o <= 0;
        alu_sel_1_ID_EX_o <= 0;
        pc_jal_sel_ID_EX_o <= 0;
        RD1D_ID_EX_o <= 0;
        RD2D_ID_EX_o <= 0;
    end else begin
        if(flush_ID_EX)begin
            PC_ID_EX_o <= 0;
            PC_plus_4_ID_EX_o <= 0;
            INST_ID_EX_o <= 0;
            rs1_ID_EX_o <= 0;
            rs2_ID_EX_o <= 0;
            rd_ID_EX_o <= 0;
            imm_ID_EX_o <= 0;
            reg_write_ID_EX_o <= 0;
            result_sel_ID_EX_o <= 0;
            mem_write_ID_EX_o <= 0;
            uncond_jump_ID_EX_o <= 0;
            meet_branch_ID_EX_o <= 0;
            alu_ctrl_ID_EX_o <= 0;
            alu_sel_0_ID_EX_o <= 0;
            alu_sel_1_ID_EX_o <= 0;
            pc_jal_sel_ID_EX_o <= 0;
            RD1D_ID_EX_o <= 0;
            RD2D_ID_EX_o <= 0;
        end else begin
            PC_ID_EX_o <= PC_ID_EX_i;
            PC_plus_4_ID_EX_o <= PC_plus_4_ID_EX_i;
            INST_ID_EX_o <= INST_ID_EX_i;
            rs1_ID_EX_o <= rs1_ID_EX_i;
            rs2_ID_EX_o <= rs2_ID_EX_i;
            rd_ID_EX_o <= rd_ID_EX_i;
            imm_ID_EX_o <= imm_ID_EX_i;
            reg_write_ID_EX_o <= reg_write_ID_EX_i;
            result_sel_ID_EX_o <= result_sel_ID_EX_i;
            mem_write_ID_EX_o <= mem_write_ID_EX_i;
            uncond_jump_ID_EX_o <= uncond_jump_ID_EX_i;
            meet_branch_ID_EX_o <= meet_branch_ID_EX_i;
            alu_ctrl_ID_EX_o <= alu_ctrl_ID_EX_i;
            alu_sel_0_ID_EX_o <= alu_sel_0_ID_EX_i;
            alu_sel_1_ID_EX_o <= alu_sel_1_ID_EX_i;
            pc_jal_sel_ID_EX_o <= pc_jal_sel_ID_EX_i;
            RD1D_ID_EX_o <= RD1D_ID_EX_i;
            RD2D_ID_EX_o <= RD2D_ID_EX_i;
        end
    end
end

endmodule