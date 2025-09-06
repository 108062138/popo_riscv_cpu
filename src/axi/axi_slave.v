module axi_slave #(
    parameter ADDR_WIDTH = 32,
    parameter READ_CHANNEL_WIDTH = 4, // 4 bit per read beat
    parameter READ_BURST_LEN = 8
)(
    input wire clk,
    input wire rst_n,
    // read address channel
    output wire ARREADY,
    input wire [ADDR_WIDTH-1:0] ARADDR,
    input wire ARVALID,
    input wire [READ_BURST_LEN-1:0] ARLEN,
    input wire [2:0] ARSIZE,
    input wire [1:0] ARBURST,
    // read data channel
    output wire RVALID,
    output wire [READ_CHANNEL_WIDTH-1:0] RDATA,
    output wire RLAST,
    output wire [1:0] RRESP,
    input wire RREADY

    // write control:
    // TBD
);

axi_slave_read_channel #(
    .ADDR_WIDTH(ADDR_WIDTH),
    .READ_CHANNEL_WIDTH(READ_CHANNEL_WIDTH),
    .READ_BURST_LEN(READ_BURST_LEN)
) u_axi_slave_read_channel (
    .clk(clk),
    .rst_n(rst_n),
    // read address channel
    .ARREADY(ARREADY),
    .ARADDR(ARADDR),
    .ARVALID(ARVALID),
    .ARLEN(ARLEN),
    .ARSIZE(ARSIZE),
    .ARBURST(ARBURST),
    // read data channel
    .RVALID(RVALID),
    .RDATA(RDATA),
    .RLAST(RLAST),
    .RRESP(RRESP),
    .RREADY(RREADY)
);

endmodule