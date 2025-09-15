`include "riscv_defs.vh"

module WB_datapath #(
    parameter INST_WIDTH = 32,
    parameter INST_ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32,
    parameter DATA_ADDR_WIDTH = 32,
    parameter REGISTER_WIDTH = 32,
    parameter REGISTER_ADDR_WIDTH = 5
)(
    input wire [INST_WIDTH-1:0] INST_MEM_WB_o,
    input wire reg_write_MEM_WB_o,
    input wire [1:0] result_sel_MEM_WB_o,
    input wire signed [DATA_WIDTH-1:0] alu_res_MEM_WB_o,
    input wire [DATA_WIDTH-1:0] data_mem_rdata_MEM_WB_o,
    input wire [REGISTER_ADDR_WIDTH-1:0] rd_MEM_WB_o,
    input wire [INST_ADDR_WIDTH-1:0] PC_plus_4_MEM_WB_o,
    input wire [2:0] funct3_MEM_WB_o,

    output reg [INST_WIDTH-1:0] INST_WB,
    output reg reg_write_WB,
    output reg [REGISTER_ADDR_WIDTH-1:0] rd_WB,
    output reg [DATA_WIDTH-1:0] result_WB,
    output reg [2:0] funct3_WB
);

reg [1:0] result_sel_WB;
reg signed [DATA_WIDTH-1:0] alu_res_WB;
reg [DATA_WIDTH-1:0] data_mem_rdata_WB;
reg [INST_ADDR_WIDTH-1:0] PC_plus_4_WB;
        

always @(*) begin
    INST_WB = INST_MEM_WB_o;
    reg_write_WB = reg_write_MEM_WB_o;
    result_sel_WB = result_sel_MEM_WB_o;
    alu_res_WB = alu_res_MEM_WB_o;
    data_mem_rdata_WB = data_mem_rdata_MEM_WB_o;
    rd_WB = rd_MEM_WB_o;
    PC_plus_4_WB = PC_plus_4_MEM_WB_o;
    funct3_WB = funct3_MEM_WB_o;
end

always @(*) begin
    result_WB = alu_res_WB;
    if(result_sel_WB==`SEL_MEM_AS_RES)begin
        result_WB = data_mem_rdata_WB;
    end else if(result_sel_WB==`SEL_PC_PLUS_4_AS_RES)begin
        result_WB = PC_plus_4_WB;
    end
end

endmodule