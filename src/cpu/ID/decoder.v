`include "riscv_defs.vh"

module decoder #(
    parameter INST_WIDTH = 32,
    parameter DATA_WIDTH = 32
)(
    input wire [INST_WIDTH-1:0] inst,
    output reg [7-1:0] funct7,
    output reg [3-1:0] funct3,
    output reg [6:0] opcode,
    
    output reg [5-1:0] rs1,
    output reg [5-1:0] rs2,
    output reg [5-1:0] rd,
    output reg signed [DATA_WIDTH-1:0] imm,
    output reg [7-1:0] OP_type
);

always @(*) begin
    funct7 = inst[31:25];
    rs2 = inst[24:20];
    rs1 = inst[19:15];
    funct3 = inst[14:12];
    rd = inst[11:7];
    opcode = inst[6:0];
    case (opcode)
        `CAL_R:   OP_type = `R_type;
        `JALR:    OP_type = `I_type;
        `LOAD:    OP_type = `I_type;
        `CAL_I:   OP_type = `I_type;
        `STORE:   OP_type = `S_type;
        `BRANCH:  OP_type = `B_type;
        `LUI:     OP_type = `U_type;
        `AUIPC:   OP_type = `U_type;
        `JAL:     OP_type = `J_type;
        default: OP_type = `X_type;
    endcase
end

imm_unit #(.DATA_WIDTH(DATA_WIDTH)) u_imm_unit (.inst(inst), .opcode(opcode), .funct3(funct3), .imm(imm));

endmodule