module double_sync #(
    parameter ADDR_WIDTH = 4
)(
    input wire clk,
    input wire rst_n,
    input wire [ADDR_WIDTH-1:0] din,
    output reg [ADDR_WIDTH-1:0] dout
);

reg [ADDR_WIDTH-1:0] tmp;

always @(posedge clk) begin
    if(!rst_n) {dout, tmp} <= 0;
    else {dout, tmp} <= {tmp, din};
end

endmodule