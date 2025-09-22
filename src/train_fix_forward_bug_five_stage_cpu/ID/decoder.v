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
    output reg signed [DATA_WIDTH-1:0] imm
);

always @(*) begin
    opcode = inst[6:0];

    funct3 = inst[14:12];
    
    funct7 = 0;
    if(opcode==`CAL_R || (opcode==`CAL_I && (funct3==3'b001 || funct3==3'b101)))begin
        funct7 = inst[31:25];
    end

    rs1 = inst[19:15];

    rs2 = 0;
    if(opcode==`BRANCH || opcode==`STORE || opcode==`CAL_R)begin
        rs2 = inst[24:20];
    end
    
    rd = inst[11:7];
    if(opcode==`BRANCH || opcode==`STORE) rd = 0;
end

imm_unit #(.DATA_WIDTH(DATA_WIDTH)) u_imm_unit (.inst(inst), .opcode(opcode), .funct3(funct3), .imm(imm));

endmodule