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

endmodule