module compare #(DATA_WIDTH = 32)(
    input wire [2:0] funct3,
    input wire signed [DATA_WIDTH-1:0] forward_rs1,
    input wire signed [DATA_WIDTH-1:0] forward_rs2,
    input wire meet_branch_ID_EX_o,
    output reg branch_decision
);

always @(*) begin
    branch_decision = 0;
    if(meet_branch_ID_EX_o)begin
        case (funct3)
            3'b000: branch_decision = (forward_rs1 == forward_rs2); // beq
            3'b001: branch_decision = (forward_rs1 != forward_rs2); // bneq
            3'b100: branch_decision = (forward_rs1 < forward_rs2); // blt
            3'b101: branch_decision = (forward_rs1 >= forward_rs2); // bge
            3'b110: branch_decision = ($unsigned(forward_rs1) < $unsigned(forward_rs2)); // bltu
            3'b111: branch_decision = ($unsigned(forward_rs1) >= $unsigned(forward_rs2)); // bgeu
            default: branch_decision = 0;
        endcase 
    end
end

endmodule