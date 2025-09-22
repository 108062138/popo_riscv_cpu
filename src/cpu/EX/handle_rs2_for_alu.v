module handle_rs2_for_alu #(parameter DATA_WIDTH = 32)(
    input wire [2:0] forward_detect_EX_rs2,
    input wire [DATA_WIDTH-1:0] RD2D_ID_EX_o,
    input wire [DATA_WIDTH-1:0] alu_res_EX_MEM_o,
    input wire [DATA_WIDTH-1:0] result_WB,

    input wire [1:0] alu_sel_rs2_ID_EX_o,
    output wire [DATA_WIDTH-1:0] mux_for_rs2_EX_forward_res,
    input wire [DATA_WIDTH-1:0] imm_ID_EX_o,
    output wire [DATA_WIDTH-1:0] rs2_for_alu_res,
    output wire [DATA_WIDTH-1:0] forward_rs2
);

assign forward_rs2 = mux_for_rs2_EX_forward_res;

mux_for_rs2_EX_forward #(.DATA_WIDTH(DATA_WIDTH)) u_mux_for_rs2_EX_forward (
    .forward_detect_EX_rs2(forward_detect_EX_rs2),
    .RD2D_ID_EX_o(RD2D_ID_EX_o),
    .alu_res_EX_MEM_o(alu_res_EX_MEM_o),
    .result_WB(result_WB),
    .mux_for_rs2_EX_forward_res(mux_for_rs2_EX_forward_res)
);
mux_for_rs2_before_alu #(.DATA_WIDTH(DATA_WIDTH)) u_mux_for_rs2_before_alu (
    .alu_sel_rs2_ID_EX_o(alu_sel_rs2_ID_EX_o),
    .mux_for_rs2_EX_forward_res(mux_for_rs2_EX_forward_res),
    .imm_ID_EX_o(imm_ID_EX_o),
    .mux_for_rs2_before_alu_res(rs2_for_alu_res)
);
endmodule

module mux_for_rs2_EX_forward #(parameter DATA_WIDTH = 32)(
    input wire [2:0] forward_detect_EX_rs2,
    input wire [DATA_WIDTH-1:0] RD2D_ID_EX_o,
    input wire [DATA_WIDTH-1:0] alu_res_EX_MEM_o,
    input wire [DATA_WIDTH-1:0] result_WB,
    output reg [DATA_WIDTH-1:0] mux_for_rs2_EX_forward_res
);

always @(*) begin
    mux_for_rs2_EX_forward_res = RD2D_ID_EX_o;
    if(forward_detect_EX_rs2[`FORWARD_COLLISION_IN_MEM]) mux_for_rs2_EX_forward_res = alu_res_EX_MEM_o;
    else if(forward_detect_EX_rs2[`FORWARD_COLLISION_IN_WB]) mux_for_rs2_EX_forward_res = result_WB;
end

endmodule

module mux_for_rs2_before_alu #(parameter DATA_WIDTH = 32)(
    input wire [1:0] alu_sel_rs2_ID_EX_o,
    input wire [DATA_WIDTH-1:0] mux_for_rs2_EX_forward_res,
    input wire [DATA_WIDTH-1:0] imm_ID_EX_o,
    output reg [DATA_WIDTH-1:0] mux_for_rs2_before_alu_res
);
always @(*) begin
    if(alu_sel_rs2_ID_EX_o==0) mux_for_rs2_before_alu_res = mux_for_rs2_EX_forward_res;
    else mux_for_rs2_before_alu_res = imm_ID_EX_o;
end
endmodule
