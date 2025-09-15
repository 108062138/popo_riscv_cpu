module alu #( parameter DATA_WIDTH = 32)(
    input wire signed [DATA_WIDTH-1:0] alu_in_rs1,
    input wire signed [DATA_WIDTH-1:0] alu_in_rs2,
    input wire [3:0] alu_ctrl_ID_EX_o,
    output reg signed [DATA_WIDTH-1:0] alu_res
);

// intermediate signed wires for rs1 and rs2
wire signed [DATA_WIDTH-1:0] rs1_signed = $signed(alu_in_rs1);
wire signed [DATA_WIDTH-1:0] rs2_signed = $signed(alu_in_rs2);
wire signed [DATA_WIDTH*2-1:0] mul_content = alu_in_rs1 * alu_in_rs2;
always @(*) begin
    case (alu_ctrl_ID_EX_o)
        4'b0000: alu_res = rs1_signed + rs2_signed; // signed add
        4'b0001: alu_res = rs1_signed - rs2_signed; // signed sub
        4'b0010: alu_res = alu_in_rs1 << alu_in_rs2[4:0]; // sll (logical shift left)
        4'b0011: alu_res = (rs1_signed < rs2_signed) ? 32'd1 : 32'd0; // slt (signed)
        4'b0100: alu_res = ($unsigned(alu_in_rs1) < $unsigned(alu_in_rs2)) ? 32'd1 : 32'd0; // sltu (unsigned)
        4'b0101: alu_res = alu_in_rs1 ^ alu_in_rs2; // xor
        4'b0110: alu_res = alu_in_rs1 >> alu_in_rs2[4:0]; // srl (logical shift right)
        4'b0111: alu_res = rs1_signed >>> alu_in_rs2[4:0]; // sra (arithmetic shift right)
        4'b1000: alu_res = alu_in_rs1 | alu_in_rs2; // or
        4'b1001: alu_res = alu_in_rs1 & alu_in_rs2; // and
        4'b1010: alu_res = mul_content[DATA_WIDTH-1:0]; // mul
        default: alu_res = 32'd0;
    endcase
end

endmodule