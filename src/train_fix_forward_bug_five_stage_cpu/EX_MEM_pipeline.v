module EX_MEM_pipeline #(
    parameter INST_WIDTH = 32,
    parameter INST_ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32,
    parameter DATA_ADDR_WIDTH = 32,
    parameter REGISTER_WIDTH = 32,
    parameter REGISTER_ADDR_WIDTH = 5
)(
    input wire cpu_clk,
    input wire cpu_rst_n,
    input wire [INST_WIDTH-1:0] INST_EX_MEM_i,
    input wire reg_write_EX_MEM_i,
    input wire mem_write_EX_MEM_i,
    input wire [1:0] result_sel_EX_MEM_i,
    input wire signed [DATA_WIDTH-1:0] alu_res_EX_MEM_i,
    input wire [REGISTER_ADDR_WIDTH-1:0] rd_EX_MEM_i,
    input wire signed [DATA_WIDTH-1:0] write_data_EX_MEM_i,
    input wire [INST_ADDR_WIDTH-1:0] PC_plus_4_EX_MEM_i,
    input wire [2:0] funct3_EX_MEM_i,

    output reg [INST_WIDTH-1:0] INST_EX_MEM_o,
    output reg reg_write_EX_MEM_o,
    output reg mem_write_EX_MEM_o,
    output reg [1:0] result_sel_EX_MEM_o,
    output reg signed [DATA_WIDTH-1:0] alu_res_EX_MEM_o,
    output reg [REGISTER_ADDR_WIDTH-1:0] rd_EX_MEM_o,
    output reg signed [DATA_WIDTH-1:0] write_data_EX_MEM_o,
    output reg [INST_ADDR_WIDTH-1:0] PC_plus_4_EX_MEM_o,
    output reg [2:0] funct3_EX_MEM_o
);

always @(posedge cpu_clk) begin
    if(!cpu_rst_n)begin
        INST_EX_MEM_o <= 0;
        reg_write_EX_MEM_o <= 0;
        mem_write_EX_MEM_o <= 0;
        result_sel_EX_MEM_o <= 0;
        alu_res_EX_MEM_o <= 0;
        rd_EX_MEM_o <= 0;
        write_data_EX_MEM_o <= 0;
        PC_plus_4_EX_MEM_o <= 0;
        funct3_EX_MEM_o <= 0;
    end else begin
        INST_EX_MEM_o <= INST_EX_MEM_i;
        reg_write_EX_MEM_o <= reg_write_EX_MEM_i;
        mem_write_EX_MEM_o <= mem_write_EX_MEM_i;
        result_sel_EX_MEM_o <= result_sel_EX_MEM_i;
        alu_res_EX_MEM_o <= alu_res_EX_MEM_i;
        rd_EX_MEM_o <= rd_EX_MEM_i;
        write_data_EX_MEM_o <= write_data_EX_MEM_i;
        PC_plus_4_EX_MEM_o <= PC_plus_4_EX_MEM_i;
        funct3_EX_MEM_o <= funct3_EX_MEM_i;
    end
end

endmodule