module MEM_datapath #(
    parameter INST_WIDTH = 32,
    parameter INST_ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32,
    parameter DATA_ADDR_WIDTH = 32,
    parameter REGISTER_WIDTH = 32,
    parameter REGISTER_ADDR_WIDTH = 5
)(
    input wire [INST_WIDTH-1:0] INST_EX_MEM_o,
    input wire reg_write_EX_MEM_o,
    input wire mem_write_EX_MEM_o,
    input wire [1:0] result_sel_EX_MEM_o,
    input wire signed [DATA_WIDTH-1:0] alu_res_EX_MEM_o,
    input wire [REGISTER_ADDR_WIDTH-1:0] rd_EX_MEM_o,
    input wire [DATA_WIDTH-1:0] write_data_EX_MEM_o,
    input wire [INST_ADDR_WIDTH-1:0] PC_plus_4_EX_MEM_o,
    input wire [2:0] funct3_EX_MEM_o,

    output reg [INST_WIDTH-1:0] INST_MEM,
    output reg reg_write_MEM,
    output reg mem_write_MEM,
    output reg [1:0] result_sel_MEM,
    output reg signed [DATA_WIDTH-1:0] alu_res_MEM,
    output reg [REGISTER_ADDR_WIDTH-1:0] rd_MEM,
    output reg [DATA_WIDTH-1:0] write_data_MEM,
    output reg [INST_ADDR_WIDTH-1:0] PC_plus_4_MEM,
    output reg [2:0] funct3_MEM
);
always @(*) begin
    INST_MEM = INST_EX_MEM_o;
    reg_write_MEM = reg_write_EX_MEM_o;
    mem_write_MEM = mem_write_EX_MEM_o;
    result_sel_MEM = result_sel_EX_MEM_o;
    alu_res_MEM = alu_res_EX_MEM_o;
    rd_MEM = rd_EX_MEM_o;
    write_data_MEM = write_data_EX_MEM_o;
    PC_plus_4_MEM = PC_plus_4_EX_MEM_o;
    funct3_MEM = funct3_EX_MEM_o;
end
endmodule