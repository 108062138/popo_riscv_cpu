module MEM_WB_pipeline #(
    parameter INST_WIDTH = 32,
    parameter INST_ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32,
    parameter DATA_ADDR_WIDTH = 32,
    parameter REGISTER_WIDTH = 32,
    parameter REGISTER_ADDR_WIDTH = 5
)(
    input wire cpu_clk,
    input wire cpu_rst_n,

    input wire [INST_WIDTH-1:0] INST_MEM_WB_i,
    input wire reg_write_MEM_WB_i,
    input wire [1:0] result_sel_MEM_WB_i,
    input wire signed [DATA_WIDTH-1:0] alu_res_MEM_WB_i,
    input wire [DATA_WIDTH-1:0] data_mem_rdata_MEM_WB_i,
    input wire [REGISTER_ADDR_WIDTH-1:0] rd_MEM_WB_i,
    input wire [INST_ADDR_WIDTH-1:0] PC_plus_4_MEM_WB_i,
    input wire [2:0] funct3_MEM_WB_i,

    output reg [INST_WIDTH-1:0] INST_MEM_WB_o,
    output reg reg_write_MEM_WB_o,
    output reg [1:0] result_sel_MEM_WB_o,
    output reg signed [DATA_WIDTH-1:0] alu_res_MEM_WB_o,
    output reg [DATA_WIDTH-1:0] data_mem_rdata_MEM_WB_o,
    output reg [REGISTER_ADDR_WIDTH-1:0] rd_MEM_WB_o,
    output reg [INST_ADDR_WIDTH-1:0] PC_plus_4_MEM_WB_o,
    output reg [2:0] funct3_MEM_WB_o
);

always @(posedge cpu_clk) begin
    if(!cpu_rst_n)begin
        INST_MEM_WB_o <= 0;
        reg_write_MEM_WB_o <= 0;
        result_sel_MEM_WB_o <= 0;
        alu_res_MEM_WB_o <= 0;
        data_mem_rdata_MEM_WB_o <= 0;
        rd_MEM_WB_o <= 0;
        PC_plus_4_MEM_WB_o <= 0;
        funct3_MEM_WB_o <= 0;
    end else begin
        INST_MEM_WB_o <= INST_MEM_WB_i;
        reg_write_MEM_WB_o <= reg_write_MEM_WB_i;
        result_sel_MEM_WB_o <= result_sel_MEM_WB_i;
        alu_res_MEM_WB_o <= alu_res_MEM_WB_i;
        data_mem_rdata_MEM_WB_o <= data_mem_rdata_MEM_WB_i;
        rd_MEM_WB_o <= rd_MEM_WB_i;
        PC_plus_4_MEM_WB_o <= PC_plus_4_MEM_WB_i;
        funct3_MEM_WB_o <= funct3_MEM_WB_i;
    end
end

endmodule