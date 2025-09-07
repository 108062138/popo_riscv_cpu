// handle write address channel, write data channel, write responce channel for slave

module axi_slave_write_channel #(
    parameter ADDR_WIDTH = 32,
    parameter WRITE_CHANNEL_WIDTH = 32, // 32 bit per burst
    parameter WRITE_BURST_LEN = 8
)(
    input wire clk,
    input wire rst_n,
    // write address channel
    output reg AWREADY,
    input wire [ADDR_WIDTH-1:0] AWADDR,
    input wire AWVALID,
    input wire [WRITE_BURST_LEN-1:0] AWLEN,
    input wire [2:0] AWSIZE,
    input wire [1:0] AWBURST,
    // write data channel
    output reg WREADY,
    input wire WVALID,
    input wire [WRITE_CHANNEL_WIDTH-1:0] WDATA,
    input wire WLAST,
    // write responce channel
    input wire BREADY,
    output reg BRESP,
    output reg BVALID
);

localparam idle = 0;
localparam transmit = 1;
localparam resp = 2;

reg [1:0] state, n_state;
reg [ADDR_WIDTH-1:0] r_AWADDR, n_r_AWADDR;
reg [WRITE_BURST_LEN-1:0] r_AWLEN, n_r_AWLEN;
reg [2:0] r_AWSIZE, n_r_AWSIZE;
reg [1:0] r_AWBURST, n_r_AWBURST;
wire lfsr_out;
wire beat_waddr, beat_wdata;

assign beat_waddr = (AWVALID && AWREADY);
assign beat_wdata = (WVALID && WREADY);

// just to immitate rcving data buffer condition
lfsr_6 u_lfsr_6(.clk(clk), .rst_n(rst_n), .lfsr_out(lfsr_out));

// remember the waddr value
always@(*)begin
    n_r_AWADDR = r_AWADDR;
    n_r_AWLEN = r_AWLEN;
    n_r_AWSIZE = r_AWSIZE;
    n_r_AWBURST = r_AWBURST;
    if(state==idle && AWREADY && AWVALID)begin
        n_r_AWADDR = AWADDR;
        n_r_AWLEN = AWLEN;
        n_r_AWSIZE = AWSIZE;
        n_r_AWBURST = AWBURST;
    end
end
// AW comb. for handshaking signals
always@(*)begin
    AWREADY = 1;
    if(state!=idle) AWREADY = 0;
end

// W comb. for handshaking signals
always@(*)begin
    WREADY = 0;
    if(state == transmit)begin
        if(lfsr_out)begin
            WREADY = 1;
        end
    end
end

// respond comb. for handshaking signals
always@(*)begin
    BRESP = 0;
    BVALID = 0;
    if(state==resp)begin
        if(lfsr_out)begin
            BRESP = 1;
            BVALID = 1;
        end
    end
end

always@(*)begin
    case(state)
    idle:begin
        if(AWREADY && AWVALID) n_state = transmit;
        else n_state = idle;
    end
    transmit:begin
        if(WREADY && WVALID && WLAST) n_state = resp;
        else n_state = transmit;
    end
    resp:begin
        if(BREADY && BVALID && BRESP) n_state = idle;
        else n_state = resp;
    end
    default: n_state = state;
    endcase
end

always@(posedge clk)begin
    if(!rst_n)begin
        state <= idle;
        r_AWADDR <= 0;
        r_AWLEN <= 0;
        r_AWSIZE <= 0;
        r_AWBURST <= 0;
    end else begin
        state <= n_state;
        r_AWADDR <= n_r_AWADDR;
        r_AWLEN <= n_r_AWLEN;
        r_AWSIZE <= n_r_AWSIZE;
        r_AWBURST <= n_r_AWBURST;
    end
end

endmodule