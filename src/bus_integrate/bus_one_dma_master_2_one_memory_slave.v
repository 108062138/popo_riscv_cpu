// remember to add double sync

module bus_one_dma_master_2_one_memory_slave #(
    parameter ADDR_WIDTH = 32,
    parameter READ_CHANNEL_WIDTH = 32,
    parameter READ_BURST_LEN = 8,
    parameter WRITE_CHANNEL_WIDTH = 32,
    parameter WRITE_BURST_LEN = 8,
    parameter ASYNCFIFO_ADDR_WIDTH = 4
)(
    input wire cpu_clk,
    input wire cpu_rst_n,
    input wire sys_clk,
    input wire sys_rst_n,
    // page fault happend
    input wire dma_page_fault_happen,
    output wire dma_page_fault_done,
    input wire [ADDR_WIDTH-1:0] dma_page_fault_addr,
    input wire [READ_BURST_LEN-1:0] dma_page_fault_burst_len,
    // cache flush happend
    input wire dma_write_back_happen,
    output wire dma_write_back_done,
    input wire [ADDR_WIDTH-1:0] dma_write_back_addr,
    input wire [WRITE_BURST_LEN-1:0] dma_write_back_burst_len
);

// trigger axi read procedure
wire axi_master_read_start, dsync_axi_master_read_start;
wire axi_master_rcv_read_start, dsync_axi_master_rcv_read_start;
wire axi_master_read_done, dsync_axi_master_read_done;
wire dma_rcv_read_done, dsync_dma_rcv_read_done;

wire [ADDR_WIDTH-1:0] axi_master_target_read_addr;
wire [READ_BURST_LEN-1:0] axi_master_target_read_burst_len;
// read address channel
wire ARREADY;
wire [ADDR_WIDTH-1:0] ARADDR;
wire ARVALID;
wire [READ_BURST_LEN-1:0] ARLEN;
wire [2:0] ARSIZE;
wire [1:0] ARBURST;
// read data channel
wire RVALID;
wire [READ_CHANNEL_WIDTH-1:0] RDATA;
wire RLAST;
wire [1:0] RRESP;
wire RREADY;
// master2dma_afifo
wire master2dma_afifo_rpull;
wire master2dma_afifo_rempty;
wire [READ_CHANNEL_WIDTH-1:0] master2dma_afifo_rdata;
wire master2dma_afifo_wpush;
wire [READ_CHANNEL_WIDTH-1:0] master2dma_afifo_wdata;
wire master2dma_afifo_wfull;

// trigger axi write procedur
wire axi_master_write_start, dsync_axi_master_write_start;
wire axi_master_rcv_write_start, dsync_axi_master_rcv_write_start;
wire axi_master_write_done, dsync_axi_master_write_done;
wire dma_rcv_write_done, dsync_dma_rcv_write_done;
wire [ADDR_WIDTH-1:0] axi_master_target_write_addr;
wire [WRITE_BURST_LEN-1:0] axi_master_target_write_burst_len;
// write address channel
wire AWREADY;
wire [ADDR_WIDTH-1:0] AWADDR;
wire AWVALID;
wire [WRITE_BURST_LEN-1:0] AWLEN;
wire [2:0] AWSIZE;
wire [1:0] AWBURST;
// write data channe
wire WREADY;
wire WVALID;
wire [WRITE_CHANNEL_WIDTH-1:0] WDATA;
wire WLAST;
// write data responce channe
wire BREADY;
wire BRESP;
wire BVALID;
// push data into dma2master_afifo
wire dma2master_afifo_wpush;
wire [WRITE_CHANNEL_WIDTH-1:0] dma2master_afifo_wdata;
wire dma2master_afifo_wfull;
wire [WRITE_CHANNEL_WIDTH-1:0] dma2master_afifo_rdata;
wire dma2master_afifo_rpull;
wire dma2master_afifo_rempty;

double_sync #(.DSYNC_WIDTH(1)) u_double_sync_dsync_axi_master_read_start(
    .clk(sys_clk),
    .rst_n(sys_rst_n),
    .din(axi_master_read_start),
    .dout(dsync_axi_master_read_start)
);
double_sync #(.DSYNC_WIDTH(1)) u_double_sync_dsync_axi_master_rcv_read_start(
    .clk(cpu_clk),
    .rst_n(cpu_rst_n),
    .din(axi_master_rcv_read_start),
    .dout(dsync_axi_master_rcv_read_start)
);

double_sync #(.DSYNC_WIDTH(1)) u_double_sync_dsync_axi_master_read_done(
    .clk(cpu_clk),
    .rst_n(cpu_rst_n),
    .din(axi_master_read_done),
    .dout(dsync_axi_master_read_done)
);
double_sync #(.DSYNC_WIDTH(1)) u_double_sync_dsync_dma_rcv_read_done(
    .clk(sys_clk),
    .rst_n(sys_rst_n),
    .din(dma_rcv_read_done),
    .dout(dsync_dma_rcv_read_done)
);

double_sync #(.DSYNC_WIDTH(1)) u_double_sync_dsync_axi_master_write_start(
    .clk(sys_clk),
    .rst_n(sys_rst_n),
    .din(axi_master_write_start),
    .dout(dsync_axi_master_write_start)
);
double_sync #(.DSYNC_WIDTH(1)) u_double_sync_dsync_axi_master_rcv_write_start(
    .clk(cpu_clk),
    .rst_n(cpu_rst_n),
    .din(axi_master_rcv_write_start),
    .dout(dsync_axi_master_rcv_write_start)
);
double_sync #(.DSYNC_WIDTH(1)) u_double_sync_dsync_axi_master_write_done(
    .clk(cpu_clk),
    .rst_n(cpu_rst_n),
    .din(axi_master_write_done),
    .dout(dsync_axi_master_write_done)
);
double_sync #(.DSYNC_WIDTH(1)) u_double_sync_dsync_dma_rcv_write_done(
    .clk(sys_clk),
    .rst_n(sys_rst_n),
    .din(dma_rcv_write_done),
    .dout(dsync_dma_rcv_write_done)
);


// READ DATA: CPU <= DMA <= MASTER <= BUS <= SLAVE <= MEMORY
asyncfifo #(
    .DATA_WIDTH(READ_CHANNEL_WIDTH),
    .ADDR_WIDTH(ASYNCFIFO_ADDR_WIDTH)
) u_master2dma_afifo (
    // read domain is system clock
    .rclk(cpu_clk),
    .rrst_n(cpu_rst_n),
    .rpull(master2dma_afifo_rpull),
    .rempty(master2dma_afifo_rempty),
    .rdata(master2dma_afifo_rdata),
    // write domain: cpu clk
    .wclk(sys_clk),
    .wrst_n(sys_rst_n),
    .wpush(master2dma_afifo_wpush),
    .wfull(master2dma_afifo_wfull),
    .wdata(master2dma_afifo_wdata)
);

// WRITE DATA: CPU => DMA => MASTER => BUS => SLAVE => MEMORY
asyncfifo #(
    .DATA_WIDTH(WRITE_CHANNEL_WIDTH),
    .ADDR_WIDTH(ASYNCFIFO_ADDR_WIDTH)
) u_dma2master_afifo (
    // read domain is system clock
    .rclk(sys_clk),
    .rrst_n(sys_rst_n),
    .rpull(dma2master_afifo_rpull),
    .rempty(dma2master_afifo_rempty),
    .rdata(dma2master_afifo_rdata),
    // write domain: cpu clk
    .wclk(cpu_clk),
    .wrst_n(cpu_rst_n),
    .wpush(dma2master_afifo_wpush),
    .wfull(dma2master_afifo_wfull),
    .wdata(dma2master_afifo_wdata)
);

dma #(
    .ADDR_WIDTH(ADDR_WIDTH),
    .READ_CHANNEL_WIDTH(READ_CHANNEL_WIDTH),
    .READ_BURST_LEN(READ_BURST_LEN),
    .WRITE_CHANNEL_WIDTH(WRITE_CHANNEL_WIDTH),
    .WRITE_BURST_LEN(WRITE_BURST_LEN)
) u_dma (
    .cpu_clk(cpu_clk),
    .cpu_rst_n(cpu_rst_n),
    // page fault happend
    .dma_page_fault_happen(dma_page_fault_happen),
    .dma_page_fault_done(dma_page_fault_done),
    .dma_page_fault_addr(dma_page_fault_addr),
    .dma_page_fault_burst_len(dma_page_fault_burst_len),
    // trigger axi read procedure
    .axi_master_read_start(axi_master_read_start),
    .axi_master_rcv_read_start(dsync_axi_master_rcv_read_start),
    .axi_master_read_done(dsync_axi_master_read_done),
    .dma_rcv_read_done(dma_rcv_read_done),
    .axi_master_target_read_addr(axi_master_target_read_addr),
    .axi_master_target_read_burst_len(axi_master_target_read_burst_len),
    // pull data from master2dma_afifo
    .master2dma_afifo_rpull(master2dma_afifo_rpull),
    .master2dma_afifo_rempty(master2dma_afifo_rempty),
    .master2dma_afifo_rdata(master2dma_afifo_rdata),

    // cache flush happend
    .dma_write_back_happen(dma_write_back_happen),
    .dma_write_back_done(dma_write_back_done),
    .dma_write_back_addr(dma_write_back_addr),
    .dma_write_back_burst_len(dma_write_back_burst_len),
    // trigger axi write procedure
    .axi_master_write_start(axi_master_write_start),
    .axi_master_rcv_write_start(dsync_axi_master_rcv_write_start),
    .axi_master_write_done(dsync_axi_master_write_done),
    .dma_rcv_write_done(dma_rcv_write_done),
    .axi_master_target_write_addr(axi_master_target_write_addr),
    .axi_master_target_write_burst_len(axi_master_target_write_burst_len),
    // push data into dma2master_afifo
    .dma2master_afifo_wpush(dma2master_afifo_wpush),
    .dma2master_afifo_wdata(dma2master_afifo_wdata),
    .dma2master_afifo_wfull(dma2master_afifo_wfull)
);

axi_master #(
    .ADDR_WIDTH(ADDR_WIDTH),
    .READ_CHANNEL_WIDTH(READ_CHANNEL_WIDTH),
    .READ_BURST_LEN(READ_BURST_LEN),
    .WRITE_CHANNEL_WIDTH(WRITE_CHANNEL_WIDTH),
    .WRITE_BURST_LEN(WRITE_BURST_LEN)
) u_axi_master (
    .clk(sys_clk),
    .rst_n(sys_rst_n),
    // read control:
    .start_read(dsync_axi_master_read_start),
    .axi_master_rcv_read_start(axi_master_rcv_read_start),
    .target_read_addr(axi_master_target_read_addr),
    .target_read_burst_len(axi_master_target_read_burst_len),
    .done_read(axi_master_read_done),
    .dma_rcv_read_done(dsync_dma_rcv_read_done),
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
    .master2dma_afifo_wfull(master2dma_afifo_wfull),

    // write control:
    .start_write(dsync_axi_master_write_start),
    .axi_master_rcv_write_start(axi_master_rcv_write_start),
    .target_write_addr(axi_master_target_write_addr),
    .target_write_burst_len(axi_master_target_write_burst_len),
    .done_write(axi_master_write_done),
    .dma_rcv_write_done(dsync_dma_rcv_write_done),
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
    // write data responce channel
    .BREADY(BREADY),
    .BRESP(BRESP),
    .BVALID(BVALID)
);

axi_slave #(
    .ADDR_WIDTH(ADDR_WIDTH),
    .READ_CHANNEL_WIDTH(READ_CHANNEL_WIDTH),
    .READ_BURST_LEN(READ_BURST_LEN),
    .WRITE_CHANNEL_WIDTH(WRITE_CHANNEL_WIDTH),
    .WRITE_BURST_LEN(WRITE_BURST_LEN)
) u_axi_slave (
    .clk(sys_clk),
    .rst_n(sys_rst_n),
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
    .BVALID(BVALID)
);

endmodule