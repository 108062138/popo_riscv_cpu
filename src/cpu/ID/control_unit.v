`include "riscv_defs.vh"

module control_unit (
    input wire [7-1:0] funct7,
    input wire [3-1:0] funct3,
    input wire [6:0] opcode,
    input wire [6:0] OP_type,

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
    if(opcode==`BRANCH || opcode==`STORE|| OP_type==`X_type)
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
    /*
    alu ctrl not fix yet
    */
    alu_ctrl_ID = 0; // default add~~~

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