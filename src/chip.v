module chip #(
    parameter INST_WIDTH = 32,
    parameter INST_ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32,
    parameter DATA_ADDR_WIDTH = 32,

    parameter NUM_WORDS_INST_MEM = 128,
    parameter NUM_WORDS_DATA_MEM = 128,
    parameter READ_BURST_LEN = 8,
    parameter WRITE_BURST_LEN = 8
)(
    input wire sys_clk,
    input wire sys_rst_n,
    input wire cpu_clk,
    input wire cpu_rst_n
);

wire [INST_ADDR_WIDTH-1:0] PC;
wire [INST_WIDTH-1:0] INST;
wire inst_mem_hazard;
wire [DATA_ADDR_WIDTH-1:0] cpu_data_mem_raddr;
wire [DATA_WIDTH-1:0] data_mem_rdata;
wire data_mem_hazard;
wire [DATA_ADDR_WIDTH-1:0] cpu_data_mem_waddr;
wire [DATA_WIDTH-1:0] cpu_data_mem_wdata;
wire cpu_data_mem_write;

L1_cache #(
    .INST_WIDTH(INST_WIDTH),
    .INST_ADDR_WIDTH(INST_ADDR_WIDTH),
    .DATA_WIDTH(DATA_WIDTH),
    .DATA_ADDR_WIDTH(DATA_ADDR_WIDTH),
    .NUM_WORDS_INST_MEM(NUM_WORDS_INST_MEM),
    .NUM_WORDS_DATA_MEM(NUM_WORDS_DATA_MEM),
    .READ_BURST_LEN(READ_BURST_LEN),
    .WRITE_BURST_LEN(WRITE_BURST_LEN)
) u_L1_cache (
    .cpu_clk(cpu_clk),
    .cpu_rst_n(cpu_rst_n),
    .PC(PC),
    .INST(INST),
    .inst_mem_hazard(inst_mem_hazard),
    .cpu_data_mem_raddr(cpu_data_mem_raddr),
    .data_mem_rdata(data_mem_rdata),
    .data_mem_hazard(data_mem_hazard),
    .cpu_data_mem_waddr(cpu_data_mem_waddr),
    .cpu_data_mem_wdata(cpu_data_mem_wdata),
    .cpu_data_mem_write(cpu_data_mem_write)
);



endmodule