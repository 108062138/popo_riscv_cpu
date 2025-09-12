module asyncfifo #(
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 4
)(
    input wire rclk,
    input wire rrst_n,
    input wire rpull,
    output wire rempty,
    output wire [DATA_WIDTH-1:0] rdata,
    input wire wclk,
    input wire wrst_n,
    input wire wpush,
    output wire wfull,
    input wire [DATA_WIDTH-1:0] wdata
);

wire [ADDR_WIDTH-1:0] waddr, raddr;
wire [ADDR_WIDTH:0] wptr, rptr, wq2_rptr, rq2_wptr;
wire wen;
wire beat_read;
assign wen = !wfull && wpush;
assign beat_read = !rempty && rpull;

write_pointer_handler #(
    .ADDR_WIDTH(ADDR_WIDTH)
) u_write_pointer_handler (
    .wclk(wclk),
    .wrst_n(wrst_n),
    .wq2_rptr(wq2_rptr),
    .wpush(wpush),
    .wptr(wptr),
    .waddr(waddr),
    .wfull(wfull)
);

double_sync #(
    .DSYNC_WIDTH(ADDR_WIDTH + 1)
) u_sync_r2w (
    .clk(wclk),
    .rst_n(wrst_n),
    .din(rptr),
    .dout(wq2_rptr)
);


fifo_memory #(
    .ADDR_WIDTH(ADDR_WIDTH),
    .DATA_WIDTH(DATA_WIDTH)
) u_fifo_memory (
    .wclk(wclk),
    .waddr(waddr),
    .wen(wen),
    .wdata(wdata),
    .raddr(raddr),
    .rdata(rdata)
);

double_sync #(
    .DSYNC_WIDTH(ADDR_WIDTH + 1)
) u_sync_w2r (
    .clk(rclk),
    .rst_n(rrst_n),
    .din(wptr),
    .dout(rq2_wptr)
);

read_pointer_handler #(
    .ADDR_WIDTH(ADDR_WIDTH)
) u_read_pointer_handler (
    .rclk(rclk),
    .rrst_n(rrst_n),
    .rpull(rpull),
    .rq2_wptr(rq2_wptr),
    .rempty(rempty),
    .raddr(raddr),
    .rptr(rptr)
);

endmodule