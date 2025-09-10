module axi_slave #(
    parameter ADDR_WIDTH = 32,
    parameter NUM_WORDS = 128,
    parameter READ_CHANNEL_WIDTH = 32, // 32 bit per read beat
    parameter READ_BURST_LEN = 8,
    parameter WRITE_CHANNEL_WIDTH = 32, // 32 bit per burst
    parameter WRITE_BURST_LEN = 8
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
    input wire RREADY,

    // write address channel
    output wire AWREADY,
    input wire [ADDR_WIDTH-1:0] AWADDR,
    input wire AWVALID,
    input wire [WRITE_BURST_LEN-1:0] AWLEN,
    input wire [2:0] AWSIZE,
    input wire [1:0] AWBURST,
    // write data channel
    output wire WREADY,
    input wire WVALID,
    input wire [WRITE_CHANNEL_WIDTH-1:0] WDATA,
    input wire WLAST,
    // write responce channel
    input wire BREADY,
    output wire BRESP,
    output wire BVALID
);

wire mem_wen;
wire [ADDR_WIDTH-1:0] mem_waddr;
wire [WRITE_CHANNEL_WIDTH-1:0] mem_wdata;

wire mem_ren;
wire [ADDR_WIDTH-1:0] mem_raddr;
wire [READ_CHANNEL_WIDTH-1:0] mem_rdata;

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
    .RREADY(RREADY),
    // mem control signal
    .mem_ren(mem_ren),
    .mem_raddr(mem_raddr),
    .mem_rdata(mem_rdata)
);

axi_slave_write_channel #(
    .ADDR_WIDTH(ADDR_WIDTH),
    .WRITE_CHANNEL_WIDTH(WRITE_CHANNEL_WIDTH),
    .WRITE_BURST_LEN(WRITE_BURST_LEN)
) u_axi_slave_write_channel (
    .clk(clk),
    .rst_n(rst_n),
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
    // write responce channel
    .BREADY(BREADY),
    .BRESP(BRESP),
    .BVALID(BVALID),
    // mem control signal
    .mem_wen(mem_wen),
    .mem_waddr(mem_waddr),
    .mem_wdata(mem_wdata)
);

memory_wrapper_dual_port #(
    .INIT_BY(0),
    .DATA_WIDTH(WRITE_CHANNEL_WIDTH), 
    .ADDR_WIDTH(ADDR_WIDTH), 
    .NUM_WORDS(NUM_WORDS)
) u_slave_mem (
    .clk(clk),
    .rst_n(rst_n),
    .ren(mem_ren),
    .raddr(mem_raddr),
    .rdata(mem_rdata),
    .wen(mem_wen),
    .waddr(mem_waddr),
    .wdata(mem_wdata)
);

endmodule