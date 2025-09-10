module axi_master #(
    parameter ADDR_WIDTH = 32,

    parameter READ_CHANNEL_WIDTH = 32, // 32 bit per beat
    parameter READ_BURST_LEN = 8,
    parameter WRITE_CHANNEL_WIDTH = 32, // 32 bit per beat
    parameter WRITE_BURST_LEN = 8
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
    output wire RREADY,
    // master 2 dma fifo
    output wire master2dma_afifo_wpush,
    output wire [READ_CHANNEL_WIDTH-1:0] master2dma_afifo_wdata,
    input wire master2dma_afifo_wfull,
    
    // write control:
    input wire start_write,
    input wire [ADDR_WIDTH-1:0] target_write_addr,
    input wire [WRITE_BURST_LEN-1:0] target_write_burst_len,
    output wire done_write,
    // write address channel
    input wire AWREADY,
    output wire [ADDR_WIDTH-1:0] AWADDR,
    output wire AWVALID,
    output wire [WRITE_BURST_LEN-1:0] AWLEN,
    output wire [2:0] AWSIZE,
    output wire [1:0] AWBURST,
    // write data channel
    input wire WREADY,
    output wire WVALID,
    output wire [WRITE_CHANNEL_WIDTH-1:0] WDATA,
    output wire WLAST,
    // dma 2 master fifo
    input wire [WRITE_CHANNEL_WIDTH-1:0] dma2master_afifo_rdata,
    output wire dma2master_afifo_rpull,
    input wire dma2master_afifo_rempty,
    // write data responce channel
    output wire BREADY,
    input wire BRESP,
    input wire BVALID
);

axi_master_read_channel #(
    .ADDR_WIDTH(ADDR_WIDTH),
    .READ_CHANNEL_WIDTH(READ_CHANNEL_WIDTH),
    .READ_BURST_LEN(READ_BURST_LEN)
) u_axi_master_read_channel (
    .clk(clk),
    .rst_n(rst_n),
    // read control
    .start(start_read),
    .target_read_addr(target_read_addr),
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
    .RREADY(RREADY),
    // master 2 dma fifo
    .master2dma_afifo_wpush(master2dma_afifo_wpush),
    .master2dma_afifo_wdata(master2dma_afifo_wdata),
    .master2dma_afifo_wfull(master2dma_afifo_wfull)
);

axi_master_write_channel #(
    .ADDR_WIDTH(ADDR_WIDTH),
    .WRITE_CHANNEL_WIDTH(WRITE_CHANNEL_WIDTH),
    .WRITE_BURST_LEN(WRITE_BURST_LEN)
) u_axi_master_write_channel (
    .clk(clk),
    .rst_n(rst_n),
    // write control
    .start(start_write),
    .target_write_addr(target_write_addr),
    .target_write_burst_len(target_write_burst_len),
    .done(done_write),
    // write address channel
    .AWREADY(AWREADY),
    .AWADDR(AWADDR),
    .AWVALID(AWVALID),
    .AWLEN(AWLEN),
    .AWSIZE(AWSIZE),
    .AWBURST(AWBURST),
    // write data channel
    .WREADY(WREADY),
    .WVALID(WVALID),
    .WDATA(WDATA),
    .WLAST(WLAST),
    // dma 2 master fifo
    .dma2master_afifo_rdata(dma2master_afifo_rdata),
    .dma2master_afifo_rpull(dma2master_afifo_rpull),
    .dma2master_afifo_rempty(dma2master_afifo_rempty),
    // write responce channel
    .BREADY(BREADY),
    .BRESP(BRESP),
    .BVALID(BVALID)
);

endmodule