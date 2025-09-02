module inst_mem #(
    parameter INST_WIDTH = 32,
    parameter INST_ADDR_WIDTH = 7
)(
    input wire clk,
    input wire rst_n,
    input wire request,
    input wire [INST_ADDR_WIDTH-1:0] addr,
    output reg valid,
    output wire [INST_WIDTH-1:0] fetched_inst
);

always@(posedge clk)begin
    if(!rst_n) valid <= 0;
    else if(request) valid <= 1;
    else valid <= 0;
end

memory_wrapper  #(
    .INIT_BY(1),
    .DATA_WIDTH(INST_WIDTH),
    .ADDR_WIDTH(INST_ADDR_WIDTH),
    .NUM_WORDS(1<<INST_ADDR_WIDTH)
) u_mem(
    .clk(clk),
    .rst_n(rst_n),
    .we(1'b0), // inst memory is read-only
    .request(request),
    .addr(addr),
    .data_i(0), // inst memory is read-only
    .data_o(fetched_inst)
);

endmodule