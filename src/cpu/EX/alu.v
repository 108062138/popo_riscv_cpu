module alu #( parameter DATA_WIDTH = 32)(
    input wire signed [DATA_WIDTH-1:0] alu_in_rs1,
    input wire signed [DATA_WIDTH-1:0] alu_in_rs2,
    input wire [3:0] alu_ctrl_ID_EX_o,
    output reg signed [DATA_WIDTH-1:0] alu_res
);

always @(*) begin
    case (alu_ctrl_ID_EX_o)
        4'b0000: alu_res = alu_in_rs1 + alu_in_rs2; // add
        4'b0001: alu_res = alu_in_rs1 - alu_in_rs2; // sub
        4'b0010: alu_res = alu_in_rs1 << (alu_in_rs2[4:0]); // sll
        4'b0011: alu_res = (alu_in_rs1 < alu_in_rs2)? 32'd1: 32'd0; // slt
        4'b0100: alu_res = ($unsigned(alu_in_rs1) < $unsigned(alu_in_rs2))? 32'd1: 32'd0; // sltu
        4'b0101: alu_res = alu_in_rs1 ^ alu_in_rs2; // xor
        4'b0110: alu_res = $unsigned(alu_in_rs1) >> alu_in_rs2[4:0]; // srl
        4'b0111: alu_res = $signed(alu_in_rs1) >> alu_in_rs2[4:0]; // sra
        4'b1000: alu_res = alu_in_rs1 | alu_in_rs2; // or
        4'b1001: alu_res = alu_in_rs1 & alu_in_rs2; // and
        default: alu_res = alu_in_rs1 + alu_in_rs2;
    endcase
end
endmodule