module alu #( parameter DATA_WIDTH = 32)(
    input wire signed [DATA_WIDTH-1:0] alu_in_rs1,
    input wire signed [DATA_WIDTH-1:0] alu_in_rs2,
    input wire [3:0] alu_ctrl_ID_EX_o,
    output wire signed [DATA_WIDTH-1:0] alu_res
);

assign alu_res = alu_in_rs1 + alu_in_rs2;

endmodule