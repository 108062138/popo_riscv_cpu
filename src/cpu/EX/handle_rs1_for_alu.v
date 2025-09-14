module handle_rs1_for_alu #(parameter DATA_WIDTH = 32)(
    input wire [2:0] forward_detect_EX_rs1,
    input wire [DATA_WIDTH-1:0] RD1D_ID_EX_o,
    input wire [DATA_WIDTH-1:0] alu_res_EX_MEM_o,
    input wire [DATA_WIDTH-1:0] result_WB,

    input wire [1:0] alu_sel_rs1_ID_EX_o,
    // missing port: mux_for_rs1_EX_forward_res
    input wire [DATA_WIDTH-1:0] PC_ID_EX_o,
    // missing port: zero
    output wire [DATA_WIDTH-1:0] rs1_for_alu_res
);
wire [DATA_WIDTH-1:0] mux_for_rs1_EX_forward_res;
mux_for_rs1_EX_forward #(.DATA_WIDTH(DATA_WIDTH)) u_mux_for_rs1_EX_forward (
    .forward_detect_EX_rs1(forward_detect_EX_rs1),
    .RD1D_ID_EX_o(RD1D_ID_EX_o),
    .alu_res_EX_MEM_o(alu_res_EX_MEM_o),
    .result_WB(result_WB),
    .mux_for_rs1_EX_forward_res(mux_for_rs1_EX_forward_res)
);

mux_for_rs1_before_alu #(.DATA_WIDTH(DATA_WIDTH)) u_mux_for_rs1_before_alu (
    .alu_sel_rs1_ID_EX_o(alu_sel_rs1_ID_EX_o),
    .mux_for_rs1_EX_forward_res(mux_for_rs1_EX_forward_res),
    .PC_ID_EX_o(PC_ID_EX_o),
    .zero(32'b0),
    .mux_for_rs1_before_alu_res(rs1_for_alu_res)
);

endmodule

module mux_for_rs1_EX_forward #(parameter DATA_WIDTH = 32)(
    input wire [2:0] forward_detect_EX_rs1,
    input wire [DATA_WIDTH-1:0] RD1D_ID_EX_o,
    input wire [DATA_WIDTH-1:0] alu_res_EX_MEM_o,
    input wire [DATA_WIDTH-1:0] result_WB,
    output reg [DATA_WIDTH-1:0] mux_for_rs1_EX_forward_res
);

always @(*) begin
    mux_for_rs1_EX_forward_res = RD1D_ID_EX_o;
    if(forward_detect_EX_rs1[`FORWARD_COLLISION_IN_MEM]) mux_for_rs1_EX_forward_res = alu_res_EX_MEM_o;
    else if(forward_detect_EX_rs1[`FORWARD_COLLISION_IN_WB]) mux_for_rs1_EX_forward_res = result_WB;
end

endmodule

module mux_for_rs1_before_alu #(parameter DATA_WIDTH = 32)(
    input wire [1:0] alu_sel_rs1_ID_EX_o,
    input wire [DATA_WIDTH-1:0] mux_for_rs1_EX_forward_res,
    input wire [DATA_WIDTH-1:0] PC_ID_EX_o,
    input wire [DATA_WIDTH-1:0] zero,
    output reg [DATA_WIDTH-1:0] mux_for_rs1_before_alu_res
);
always @(*) begin
    if(alu_sel_rs1_ID_EX_o==0)
        mux_for_rs1_before_alu_res = mux_for_rs1_EX_forward_res;
    else if(alu_sel_rs1_ID_EX_o==1)
        mux_for_rs1_before_alu_res = PC_ID_EX_o;
    else
        mux_for_rs1_before_alu_res = zero;
end
endmodule
