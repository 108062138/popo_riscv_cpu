module fifo_memory #(
    parameter ADDR_WIDTH = 4,
    parameter DATA_WIDTH = 32
)(
    input wire wclk,
    input wire wen,
    input wire [DATA_WIDTH-1:0] wdata,
    input wire [ADDR_WIDTH-1:0] waddr,
    input wire [ADDR_WIDTH-1:0] raddr,
    output wire [DATA_WIDTH-1:0] rdata
);

localparam MEMORY_DEPTH = 1 << ADDR_WIDTH;
reg [DATA_WIDTH-1:0] mem [0: MEMORY_DEPTH-1];
assign rdata = mem[raddr];
always@(posedge wclk)begin
    if(wen) mem[waddr] <= wdata;
end
endmodule