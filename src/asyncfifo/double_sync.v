module double_sync #(
    parameter DSYNC_WIDTH = 4
)(
    input wire clk,
    input wire rst_n,
    input wire [DSYNC_WIDTH-1:0] din,
    output reg [DSYNC_WIDTH-1:0] dout
);

reg [DSYNC_WIDTH-1:0] tmp;

always @(posedge clk) begin
    if(!rst_n) {dout, tmp} <= 0;
    else {dout, tmp} <= {tmp, din};
end

endmodule