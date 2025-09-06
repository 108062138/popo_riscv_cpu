module axi_master #(
    parameter ADDR_WIDTH = 32,
    parameter READ_CHANNEL_WIDTH = 4, // 4 bit per beat
    parameter READ_BURST_LEN = 8
)(
    input wire clk,
    input wire rst_n,
    // read control:
    input wire start_read,
    input wire [ADDR_WIDTH-1:0] target_read_addr,
    input wire [READ_BURST_LEN-1:0] target_read_burst_len,
    output wire done_read,
    // read address channel
    input wire ARREADY,
    output wire [ADDR_WIDTH-1:0] ARADDR,
    output wire ARVALID,
    output wire [READ_BURST_LEN-1:0] ARLEN,
    output wire [2:0] ARSIZE,
    output wire [1:0] ARBURST,
    // read data channel
    input wire RVALID,
    input wire [READ_CHANNEL_WIDTH-1:0] RDATA,
    input wire RLAST,
    input wire [1:0] RRESP,
    output wire RREADY
    // write control:
    // TBD
);

axi_master_read_channel #(
    .ADDR_WIDTH(ADDR_WIDTH),
    .READ_CHANNEL_WIDTH(READ_CHANNEL_WIDTH),
    .READ_BURST_LEN(READ_BURST_LEN)
) u_axi_master_read_channel (
    .clk(clk),
    .rst_n(rst_n),
    .start(start_read),
    .target_addr(target_read_addr),
    .target_read_burst_len(target_read_burst_len),
    .done(done_read),
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