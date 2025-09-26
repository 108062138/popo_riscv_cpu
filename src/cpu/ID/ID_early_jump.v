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
    // for jal
    input wire [INST_ADDR_WIDTH-1:0] PC_ID,
    input wire [DATA_WIDTH-1:0] imm_ID,
    output reg [DATA_WIDTH-1:0] early_jal_PC_ID,
    output reg early_jal_ID
);

always @(*) begin
    early_jal_PC_ID = PC_ID + imm_ID;
    early_jal_ID = 0;
    if(opcode_ID==`JAL)begin
        early_jal_ID = 1;
    end
end
endmodule