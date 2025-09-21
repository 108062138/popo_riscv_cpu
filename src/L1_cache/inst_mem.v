module inst_mem #(
    parameter INST_WIDTH = 32, // word address
    parameter INST_ADDR_WIDTH = 32,
    parameter NUM_WORDS = 128  
)(
    input wire cpu_clk,
    input wire cpu_rst_n,
    // inst. only read by cpu
    input wire [INST_ADDR_WIDTH-1:0] PC,
    output reg [INST_WIDTH-1:0] INST,
    output reg inst_mem_hazard,
    // inst. only write by DMA
    input wire [INST_ADDR_WIDTH-1:0] dma_inst_mem_waddr,
    input wire [INST_WIDTH-1:0] dma_inst_mem_wdata,
    input wire inst_mem_write
);

reg [INST_WIDTH-1:0] mem [0:NUM_WORDS-1];
initial begin
    $readmemh("/home/popo/Desktop/popo_train_cpu/fixing/popo_cpu/tb/word_inst.mem", mem);
end
always @(*) begin
    inst_mem_hazard = #2 0;
    INST = #2 mem[PC>>2]; // PC/4 is the instruction address
end
always @(posedge cpu_clk) begin
    if(inst_mem_write)begin
        mem[dma_inst_mem_waddr] <= #2 dma_inst_mem_wdata;
    end
end

reg [INST_WIDTH-1:0] word_0;
reg [INST_WIDTH-1:0] word_1;
reg [INST_WIDTH-1:0] word_2;
reg [INST_WIDTH-1:0] word_3;
reg [INST_WIDTH-1:0] word_4;
reg [INST_WIDTH-1:0] word_5;
reg [INST_WIDTH-1:0] word_6;
reg [INST_WIDTH-1:0] word_7;
reg [INST_WIDTH-1:0] word_8;
reg [INST_WIDTH-1:0] word_9;
reg [INST_WIDTH-1:0] word_10;

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