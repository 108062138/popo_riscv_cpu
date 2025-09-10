module memory_wrapper_dual_port #(
    parameter INIT_BY = 0,
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 32,
    parameter NUM_WORDS = 128
)(
    input wire clk,
    input wire rst_n,
    input wire wen,
    input wire [ADDR_WIDTH-1:0] waddr,
    input wire [DATA_WIDTH-1:0] wdata,
    input wire ren,
    input wire [ADDR_WIDTH-1:0] raddr,
    output reg [DATA_WIDTH-1:0] rdata
);

reg [32-1:0] mem [0:NUM_WORDS-1];

initial begin
    if(INIT_BY==0)$readmemh("/home/popo/Desktop/popo_train_cpu/popo_cpu/tb/slow_data.mem", mem);
end

always@(posedge clk)begin
    if(!rst_n)begin
        rdata <= 0;
    end else begin
        if(ren)begin
            if(raddr==waddr && wen) rdata <= wdata;
            else rdata <= mem[raddr];
        end else begin
            rdata <= 0;
        end
    end
end

always @(posedge clk) begin
    if(wen)begin
        mem[waddr] <= wdata;
    end
end

endmodule