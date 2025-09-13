module cpu #(
    parameter INST_WIDTH = 32,
    parameter INST_ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32,
    parameter DATA_ADDR_WIDTH = 32
)(
    input wire cpu_clk,
    input wire cpu_rst_n,

    output wire [INST_ADDR_WIDTH-1:0] PC,
    input wire [INST_WIDTH-1:0] INST,
    input wire inst_mem_hazard,
    input wire [DATA_ADDR_WIDTH-1:0] cpu_data_mem_raddr,
    input wire [DATA_WIDTH-1:0] data_mem_rdata,
    input wire data_mem_hazard,
    output wire [DATA_ADDR_WIDTH-1:0] cpu_data_mem_waddr,
    output wire [DATA_WIDTH-1:0] cpu_data_mem_wdata,
    output wire cpu_data_mem_write
);

wire PC_take_branch, PC_take_jalr;
wire [INST_ADDR_WIDTH-1:0] PC_for_normal_PC_plus_4, PC_for_normal_branch, PC_for_jalr;
wire [INST_ADDR_WIDTH-1:0] n_PC;
assign PC_for_normal_PC_plus_4 = PC_plus_4_IF_ID_i;
PC_datapath #( .INST_WIDTH(INST_WIDTH), .INST_ADDR_WIDTH(INST_ADDR_WIDTH)) u_PC_datapath (
    .PC_take_branch(PC_take_branch),
    .PC_take_jalr(PC_take_jalr),
    .PC_for_normal_PC_plus_4(PC_for_normal_PC_plus_4),
    .PC_for_normal_branch(PC_for_normal_branch),
    .PC_for_jalr(PC_for_jalr),
    .n_PC(n_PC)
);

PC_IF_pipeline #( .INST_WIDTH(INST_WIDTH), .INST_ADDR_WIDTH(INST_ADDR_WIDTH)) u_PC_IF_pipeline (
    .cpu_clk(cpu_clk),
    .cpu_rst_n(cpu_rst_n),
    .stall_PC_IF(stall_PC_IF),
    .n_PC(n_PC),
    .PC(PC)
);


wire [INST_ADDR_WIDTH-1:0] PC_plus_4_IF_ID_i;
// IF datapath is too small
IF_datapath #( .INST_WIDTH(INST_WIDTH), .INST_ADDR_WIDTH(INST_ADDR_WIDTH)) u_IF_datapath (
    .PC(PC),
    .PC_plus_4_i(PC_plus_4_IF_ID_i)
);


wire [INST_ADDR_WIDTH-1:0] PC_IF_ID_o, PC_plus_4_IF_ID_o;
wire [INST_WIDTH-1:0] INST_IF_ID_o;
IF_ID_pipeline #( .INST_WIDTH(INST_WIDTH), .INST_ADDR_WIDTH(INST_ADDR_WIDTH)) u_IF_ID_pipeline (
    .cpu_clk(cpu_clk),
    .cpu_rst_n(cpu_rst_n),
    .stall_IF_ID(stall_IF_ID),
    .flush_IF_ID(flush_IF_ID),
    .PC_IF_ID_i(PC),
    .PC_IF_ID_o(PC_IF_ID_o),
    .PC_plus_4_IF_ID_i(PC_plus_4_IF_ID_i),
    .PC_plus_4_IF_ID_o(PC_plus_4_IF_ID_o),
    .INST_IF_ID_i(INST),
    .INST_IF_ID_o(INST_IF_ID_o)
);

wire stall_PC_IF,stall_IF_ID;
wire flush_IF_ID, flush_ID_EX;

hazard_detection u_hazard_detction(
    .inst_mem_hazard(inst_mem_hazard),
    .data_mem_hazard(data_mem_hazard),
    .stall_PC_IF(stall_PC_IF),
    .stall_IF_ID(stall_IF_ID),
    .flush_IF_ID(flush_IF_ID),
    .flush_ID_EX(flush_ID_EX)
);

endmodule