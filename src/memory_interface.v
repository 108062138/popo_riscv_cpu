module memory_interface #(
    parameter INIT_BY = 1,
    parameter CONTENT_WIDTH = 32,
    parameter CONTENT_ADDR_WIDTH = 32
)(
    input wire clk,
    input wire rst_n,
    input wire we,
    input wire request,
    input wire [CONTENT_ADDR_WIDTH-1:0] addr,
    input wire [CONTENT_WIDTH-1:0] data_i,
    output reg valid,
    output wire [CONTENT_WIDTH-1:0] data_o
);

reg [2-1:0] cd;
always@(posedge clk)begin
    if(!rst_n) cd <= 0;
    else cd <= cd + 1;
end
always@(posedge clk)begin
    if(!rst_n) valid <= 0;
    else if(request) valid <= 1;
    else valid <= 0;
end

memory_wrapper  #(
    .INIT_BY(INIT_BY),
    .DATA_WIDTH(CONTENT_WIDTH),
    .ADDR_WIDTH(CONTENT_ADDR_WIDTH),
    .NUM_WORDS(128/*1<<CONTENT_ADDR_WIDTH*/)
) u_mem(
    .clk(clk),
    .rst_n(rst_n),
    .we(we),
    .request(request),
    .addr(addr),
    .data_i(data_i),
    .data_o(data_o)
);

endmodule