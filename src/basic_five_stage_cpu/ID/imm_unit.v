`include "riscv_defs.vh"

module imm_unit #(
    parameter INST_WIDTH = 32,
    parameter DATA_WIDTH = 32
)(
    input wire [INST_WIDTH-1:0] inst,
    input [6:0] opcode,
    input [2:0] funct3,
    output reg signed [DATA_WIDTH-1:0] imm
);

always @(*) begin
    case (opcode)
        `LUI: imm = {inst[31:12], 12'b0};
        `AUIPC: imm = {inst[31:12], 12'b0};
        `JAL: imm = {{11{inst[31]}}, inst[31], inst[19:12], inst[20], inst[30:21], 1'b0};
        `JALR: imm = {{20{inst[31]}}, inst[31:20]};
        `BRANCH: begin
            imm = {{19{inst[31]}}, inst[31], inst[7], inst[30:25], inst[11:8], 1'b0};
            if(funct3==3'b110 || funct3==3'b111)begin
                imm = {19'b0, inst[31], inst[7], inst[30:25], inst[11:8], 1'b0};
            end
        end
        `LOAD: imm = {{20{inst[31]}}, inst[31:20]};
        `STORE: imm = {{20{inst[31]}},inst[31:25], inst[11:7]};
        `CAL_I:begin
            imm = {{20{inst[31]}}, inst[31:20]};
            if(opcode==7'b0000011 && (funct3==3'b100 || funct3==3'b101))begin
                imm = {20'b0, inst[31:20]};
            end
            if(opcode==7'b0010011 && funct3==3'b011)begin
                imm = {20'b0, inst[31:20]};
            end
        end
        `CAL_R:begin
            imm = 32'b0;
        end
        default: imm = 32'b0;
    endcase
end

endmodule