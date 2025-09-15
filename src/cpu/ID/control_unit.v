`include "riscv_defs.vh"

module control_unit (
    input wire [7-1:0] funct7,
    input wire [3-1:0] funct3,
    input wire [6:0] opcode,

    output reg reg_write_ID,
    output reg [1:0] result_sel_ID,
    output reg mem_write_ID,
    output reg uncond_jump_ID,
    output reg meet_branch_ID,
    output reg [3:0] alu_ctrl_ID,
    output reg [1:0] alu_sel_rs1_ID,
    output reg [1:0] alu_sel_rs2_ID,
    output reg pc_jal_sel_ID
);

always @(*) begin
    reg_write_ID = 1;
    if(opcode==`BRANCH || opcode==`STORE)
        reg_write_ID = 0;

    mem_write_ID = 0;
    if(opcode==`STORE)
        mem_write_ID = 1;


    uncond_jump_ID = 0;
    if(opcode==`JAL || opcode==`JALR)
        uncond_jump_ID = 1;

    pc_jal_sel_ID = 0;
    if(opcode==`JALR) pc_jal_sel_ID = 1;

    meet_branch_ID = 0;
    if(opcode==`BRANCH)
        meet_branch_ID = 1;

    alu_ctrl_ID = 4'b0000; // default add
    if(opcode==`CAL_R)begin
        case(funct3)
            3'b000: begin
                if(!funct7[5]) alu_ctrl_ID = 4'b0000; // add
                else alu_ctrl_ID = 4'b0001; // sub
            end
            3'b001: alu_ctrl_ID = 4'b0010; // sll
            3'b010: alu_ctrl_ID = 4'b0011; // slt
            3'b011: alu_ctrl_ID = 4'b0100; // sltu
            3'b100: alu_ctrl_ID = 4'b0101; // xor
            3'b101: begin
                if(!funct7[5]) alu_ctrl_ID = 4'b0110; // srl
                else alu_ctrl_ID = 4'b0111; // sra
            end
            3'b110: alu_ctrl_ID = 4'b1000; // or
            3'b111: alu_ctrl_ID = 4'b1001; // and
            default: alu_ctrl_ID = 4'b0000; // default add for R
        endcase
    end else if(opcode==`CAL_I)begin
        case(funct3)
            3'b000: alu_ctrl_ID = 4'b0000; // addi
            3'b001: alu_ctrl_ID = 4'b0010; // slli
            3'b010: alu_ctrl_ID = 4'b0011; // slti
            3'b011: alu_ctrl_ID = 4'b0100; // sltiu
            3'b100: alu_ctrl_ID = 4'b0101; // xori
            3'b101: begin
                if(!funct7[5]) alu_ctrl_ID = 4'b0110; // srli
                else alu_ctrl_ID = 4'b0111; // srai
            end
            3'b110: alu_ctrl_ID = 4'b1000; // ori
            3'b111: alu_ctrl_ID = 4'b1001; // ani
            default: alu_ctrl_ID = 4'b0000;
        endcase
    end


    alu_sel_rs1_ID = 0; // send reg[rs1] to ALU
    if(opcode==`AUIPC || opcode==`JAL || opcode==`BRANCH) // send PC to ALU 
        alu_sel_rs1_ID = 1;
    else if(opcode==`LUI) // send 0 to ALU
        alu_sel_rs1_ID = 2;

    alu_sel_rs2_ID = 0; // when it meet R-type, send  reg[rs2] to ALU
    if(opcode!=`CAL_R) // default send imm to ALU
        alu_sel_rs2_ID = 1; 

    result_sel_ID = 0; // default takes ALU result to update reg
    if(opcode==`LOAD)
        result_sel_ID = 1; // reg update from memory
    else if(opcode==`JAL || opcode==`JALR)
        result_sel_ID = 2; // reg update from PC+4
end
endmodule