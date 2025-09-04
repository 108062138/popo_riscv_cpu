module five_stage_cpu #(
    parameter INST_WIDTH = 32,
    parameter INST_ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32,
    parameter DATA_ADDR_WIDTH = 32
)(
    input wire clk,
    input wire rst_n,
    input wire start,
    // to inst memory
    output reg inst_we_core2mem,
    output reg inst_request_core2mem,
    output reg [INST_ADDR_WIDTH-1:0] inst_addr_core2mem,
    input wire inst_valid_mem2core,
    input wire [INST_WIDTH-1:0] inst_mem2core
    // to data memory (not implemented yet)
);

wire stall_PC; // load then use
wire stall_IF_ID; // load then use
wire flush_IF_ID; // control hazard
wire branch_taken;
wire branch_source;
wire [INST_ADDR_WIDTH-1:0] branch_jalr_target;
wire [INST_ADDR_WIDTH-1:0] branch_jal_beq_bne_target;
wire [INST_ADDR_WIDTH-1:0] PC_from_PC;
wire [INST_ADDR_WIDTH-1:0] pre_PC_from_PC;

wire [INST_WIDTH-1:0] IF_inst_o;
wire [INST_ADDR_WIDTH-1:0] IF_PC_o;
wire [INST_ADDR_WIDTH-1:0] IF_PC_plus_4_o;

wire [INST_WIDTH-1:0] inst_IF_ID;
wire [INST_ADDR_WIDTH-1:0] PC_IF_ID;

assign inst_addr_core2mem = PC_from_PC >> 2; // PC is byte address, but inst mem is word address
assign stall_PC = !inst_valid_mem2core; // stall when inst is not valid
PC_handler #(
    .INST_ADDR_WIDTH(INST_ADDR_WIDTH)
) u_PC_handler(
    .clk(clk),
    .rst_n(rst_n),
    .start(start),
    .stall_PC(stall_PC),
    .branch_taken(branch_taken),
    .branch_source(branch_source),
    .branch_jalr_target(branch_jalr_target),
    .branch_jal_beq_bne_target(branch_jal_beq_bne_target),
    .IF_PC_plus_4(IF_PC_plus_4_o),
    .inst_we_core2mem(inst_we_core2mem),
    .inst_request_core2mem(inst_request_core2mem),
    .PC(PC_from_PC),
    .pre_PC(pre_PC_from_PC)
);

IF_datapath #(
    .INST_WIDTH(INST_WIDTH),
    .INST_ADDR_WIDTH(INST_ADDR_WIDTH)
) u_IF_datapath(
    .IF_inst_i(inst_mem2core),
    .IF_PC_i(PC_from_PC),
    .IF_inst_o(IF_inst_o),
    .IF_PC_o(IF_PC_o),
    .IF_PC_plus_4_o(IF_PC_plus_4_o)
);

IF_ID_pipeline #(
    .INST_WIDTH(INST_WIDTH),
    .INST_ADDR_WIDTH(INST_ADDR_WIDTH)
) u_IF_ID_pipeline(
    .clk(clk),
    .rst_n(rst_n),
    .start(start),
    .stall_IF_ID(1'b0),
    .flush_IF_ID(1'b0),
    .IF_inst_o(IF_inst_o),
    .pre_PC_from_PC(pre_PC_from_PC),
    .inst_IF_ID(inst_IF_ID),
    .PC_IF_ID(PC_IF_ID)
);

branch_handler #(
    .INST_WIDTH(INST_WIDTH),
    .INST_ADDR_WIDTH(INST_ADDR_WIDTH)
) u_branch_handler(
    .clk(clk),
    .rst_n(rst_n),
    .start(start),
    .inst_IF_ID(inst_IF_ID),
    .PC_IF_ID(PC_IF_ID),
    .branch_taken(branch_taken),
    .branch_source(branch_source),
    .branch_jalr_target(branch_jalr_target),
    .branch_jal_beq_bne_target(branch_jal_beq_bne_target)
);

endmodule