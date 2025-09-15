module data_mem #(
    parameter DATA_WIDTH = 32, // word address
    parameter DATA_ADDR_WIDTH = 32,
    parameter NUM_WORDS = 128
)(
    input wire cpu_clk,
    input wire cpu_rst_n,
    input wire [DATA_ADDR_WIDTH-1:0] cpu_data_mem_raddr,
    input wire [DATA_ADDR_WIDTH-1:0] dma_data_mem_raddr,
    input wire data_mem_read_ctrl_by,
    output reg [DATA_WIDTH-1:0] data_mem_rdata,
    output reg data_mem_hazard,

    input wire [DATA_ADDR_WIDTH-1:0] cpu_data_mem_waddr,
    input wire [DATA_WIDTH-1:0] cpu_data_mem_wdata,
    input wire [DATA_ADDR_WIDTH-1:0] dma_data_mem_waddr,
    input wire [DATA_WIDTH-1:0] dma_data_mem_wdata,
    input wire data_mem_write,
    input wire data_mem_write_ctrl_by
);
localparam cpu_ctrl = 0;
localparam dma_ctrl = 1;
reg [DATA_WIDTH-1:0] mem [0:NUM_WORDS-1];
initial begin
    $readmemh("/home/popo/Desktop/popo_train_cpu/popo_cpu/tb/data.mem", mem);
end
always @(*) begin
    data_mem_hazard = #1 0;
    if(data_mem_read_ctrl_by==cpu_ctrl)
        data_mem_rdata = #1 mem[cpu_data_mem_raddr];
    else
        data_mem_rdata = #1 mem[dma_data_mem_raddr];
end
always @(posedge cpu_clk) begin
    if(data_mem_write)begin
        if(data_mem_write_ctrl_by==cpu_ctrl)
            mem[cpu_data_mem_waddr] <= #1 cpu_data_mem_wdata;
        else
            mem[dma_data_mem_waddr] <= #1 dma_data_mem_wdata;
    end
end

reg [DATA_WIDTH-1:0] word_0;
reg [DATA_WIDTH-1:0] word_1;
reg [DATA_WIDTH-1:0] word_2;
reg [DATA_WIDTH-1:0] word_3;
reg [DATA_WIDTH-1:0] word_4;
reg [DATA_WIDTH-1:0] word_5;
reg [DATA_WIDTH-1:0] word_6;
reg [DATA_WIDTH-1:0] word_7;
reg [DATA_WIDTH-1:0] word_8;
reg [DATA_WIDTH-1:0] word_9;
reg [DATA_WIDTH-1:0] word_10;

always @(*) begin
    word_0 = mem[0];
    word_1 = mem[1];
    word_2 = mem[2];
    word_3 = mem[3];
    word_4 = mem[4];
    word_5 = mem[5];
    word_6 = mem[6];
    word_7 = mem[7];
    word_8 = mem[8];
    word_9 = mem[9];
    word_10 = mem[10];
end

endmodule