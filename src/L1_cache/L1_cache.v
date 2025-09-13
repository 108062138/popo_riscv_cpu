module L1_cache #(
    parameter INST_WIDTH = 32,
    parameter INST_ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32,
    parameter DATA_ADDR_WIDTH = 32,

    parameter NUM_WORDS_INST_MEM = 128,
    parameter NUM_WORDS_DATA_MEM = 128,
    parameter READ_BURST_LEN = 8,
    parameter WRITE_BURST_LEN = 8
)(
    input wire cpu_clk,
    input wire cpu_rst_n,
    // inst. for read only
    input wire [INST_ADDR_WIDTH-1:0] PC,
    output wire [INST_WIDTH-1:0] INST,
    output wire inst_mem_hazard,
    // data mem for both read and write
    input wire [DATA_ADDR_WIDTH-1:0] cpu_data_mem_raddr,
    output wire [DATA_WIDTH-1:0] data_mem_rdata,
    output wire data_mem_hazard,
    
    input wire [DATA_ADDR_WIDTH-1:0] cpu_data_mem_waddr,
    input wire [DATA_WIDTH-1:0] cpu_data_mem_wdata,
    input wire cpu_data_mem_write
    // use axi interface 
    // lots of write to connect
    // TODO
);

/*
    TODO:
    inst. over data mem hit/miss
    inst. over inst mem hit/miss
    inst. over dma that controls data mem and inst mem
*/

inst_mem #(
    .INST_WIDTH(INST_WIDTH),
    .INST_ADDR_WIDTH(INST_ADDR_WIDTH),
    .NUM_WORDS(NUM_WORDS_INST_MEM)
) u_inst_mem (
    .cpu_clk(cpu_clk),
    .cpu_rst_n(cpu_rst_n),
    // inst. only read by cpu
    .PC(PC),
    .INST(INST),
    .inst_mem_hazard(inst_mem_hazard),
    // inst. only write by DMA
    .dma_inst_mem_waddr(32'b0),
    .dma_inst_mem_wdata(32'b0),
    .inst_mem_write(1'b0)
);

data_mem #(
    .DATA_WIDTH(DATA_WIDTH),
    .DATA_ADDR_WIDTH(DATA_ADDR_WIDTH),
    .NUM_WORDS(NUM_WORDS_DATA_MEM)
) u_data_mem (
    .cpu_clk(cpu_clk),
    .cpu_rst_n(cpu_rst_n),
    .cpu_data_mem_raddr(cpu_data_mem_raddr),
    .dma_data_mem_raddr(32'b0),
    .data_mem_read_ctrl_by(1'b0),
    .data_mem_rdata(data_mem_rdata),
    .data_mem_hazard(data_mem_hazard),

    .cpu_data_mem_waddr(cpu_data_mem_waddr),
    .cpu_data_mem_wdata(cpu_data_mem_wdata),
    .dma_data_mem_waddr(32'b0),
    .dma_data_mem_wdata(32'b0),
    .data_mem_write(cpu_data_mem_write),
    .data_mem_write_ctrl_by(1'b0)
);

endmodule