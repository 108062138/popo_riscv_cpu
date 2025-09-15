module compare #(DATA_WIDTH = 32)(
    input wire [2:0] funct3,
    input wire signed [DATA_WIDTH-1:0] alu_in_rs1,
    input wire signed [DATA_WIDTH-1:0] alu_in_rs2,
    output reg branch_decision
);

always @(*) begin
    case (funct3)
        3'b000: branch_decision = (alu_in_rs1 == alu_in_rs2); // beq
        3'b001: branch_decision = (alu_in_rs1 != alu_in_rs2); // bneq
        3'b100: branch_decision = (alu_in_rs1 < alu_in_rs2); // blt
        3'b101: branch_decision = (alu_in_rs1 >= alu_in_rs2); // bge
        3'b110: branch_decision = ($unsigned(alu_in_rs1) < $unsigned(alu_in_rs2)); // bltu
        3'b111: branch_decision = ($unsigned(alu_in_rs1) >= $unsigned(alu_in_rs2)); // bgeu
        default: branch_decision = 0;
    endcase
end

endmodule