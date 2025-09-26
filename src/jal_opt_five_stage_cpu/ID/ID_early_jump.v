`include "riscv_defs.vh"

module ID_early_jump #(
    parameter INST_WIDTH = 32,
    parameter INST_ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32,
    parameter DATA_ADDR_WIDTH = 32,
    parameter REGISTER_WIDTH = 32,
    parameter REGISTER_ADDR_WIDTH = 5
)(
    input wire [6:0] opcode_ID,
    input wire [6:0] opcode_EX,
    input wire reg_write_EX,
    input wire reg_write_MEM,
    input wire reg_write_WB,
    input wire [REGISTER_ADDR_WIDTH-1:0] rs1_ID,
    input wire [REGISTER_ADDR_WIDTH-1:0] rd_EX,
    input wire [REGISTER_ADDR_WIDTH-1:0] rd_MEM,
    input wire [REGISTER_ADDR_WIDTH-1:0] rd_WB,
    // for jal
    input wire [INST_ADDR_WIDTH-1:0] PC_ID,
    // for jalr
    input wire [DATA_WIDTH-1:0] RD1D_ID, 
    input wire [DATA_WIDTH-1:0] alu_res_EX,
    input wire [DATA_WIDTH-1:0] alu_res_MEM,
    input wire [DATA_WIDTH-1:0] result_WB,
    // both jal and jalr use imm_ID
    input wire [DATA_WIDTH-1:0] imm_ID,
    
    output reg [DATA_WIDTH-1:0] early_jump_jal_res,
    output reg [DATA_WIDTH-1:0] early_jump_jalr_res,
    output reg [1:0] early_jump
);

always @(*) begin
    early_jump_jal_res = 0;
    early_jump_jalr_res = 0;
    early_jump = 0;
    if(opcode_ID==`JAL)begin
        early_jump_jal_res = PC_ID + imm_ID;
        // for every jal, we always early jump
        early_jump = 2'b01;
    end
    if(opcode_ID==`JALR)begin // weird, ~~~~ for now, I forbid its usage
        early_jump_jalr_res = imm_ID + RD1D_ID; // default case no collision
        early_jump = 0;
        if(rs1_ID==rd_EX && reg_write_EX)begin
            early_jump_jalr_res = imm_ID + alu_res_EX;
            // if load then use meet, don't early jump
            if(opcode_EX==`LOAD)begin
                early_jump = 0;
            end
        end else if(rs1_ID==rd_MEM && reg_write_MEM)begin
            early_jump_jalr_res = imm_ID + alu_res_MEM;
            // if(opcode_EX==`LOAD)begin
            //     early_jump = 0;
            // end
        end else if(rs1_ID==rd_WB && reg_write_WB)begin
            early_jump_jalr_res = imm_ID + result_WB;
            // if(opcode_EX==`LOAD)begin
            //     early_jump = 0;
            // end
        end
    end
end

endmodule