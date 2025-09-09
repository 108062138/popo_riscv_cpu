// handle write address channel, write data channel, write responce channel

module axi_master_write_channel #(
    parameter ADDR_WIDTH = 32,
    parameter WRITE_CHANNEL_WIDTH = 32, // 32 bit per burst
    parameter WRITE_BURST_LEN = 8
)(
    input wire clk,
    input wire rst_n,
    input wire start,
    input wire [ADDR_WIDTH-1:0] target_addr,
    input wire [WRITE_BURST_LEN-1:0] target_write_burst_len,
    // dma 2 master afifo
    input wire [WRITE_CHANNEL_WIDTH-1:0] dma2master_afifo_rdata, // emulate afifo for master
    output wire dma2master_afifo_rpull,                     // emulate afifo for master
    input wire dma2master_afifo_rempty,                     // emulate afifo for master
    output wire done,
    // write address channel
    input wire AWREADY,
    output reg [ADDR_WIDTH-1:0] AWADDR,
    output reg AWVALID,
    output reg [WRITE_BURST_LEN-1:0] AWLEN,
    output reg [2:0] AWSIZE,
    output reg [1:0] AWBURST,
    // write data channel
    input wire WREADY,
    output reg WVALID,
    output reg [WRITE_CHANNEL_WIDTH-1:0] WDATA,
    output reg WLAST,
    // write responce channel
    output reg BREADY,
    input wire BRESP,
    input wire BVALID
);

localparam idle = 0;
localparam addr_handshaking = 1;
localparam data_handshaking = 2;
localparam resp = 3;
localparam raise_done = 4;

reg [2:0] state, n_state;
reg [ADDR_WIDTH-1:0] rem_target_addr, n_rem_target_addr;
reg [WRITE_BURST_LEN-1:0] rem_target_burst_len, n_rem_target_burst_len;
reg [WRITE_BURST_LEN-1:0] snd_cnt, n_snd_cnt;

wire beat_waddr, beat_wdata, beat_resp;
assign beat_waddr = AWVALID && AWREADY;
assign beat_wdata = WVALID && WREADY;
assign dma2master_afifo_rpull = beat_wdata;
assign beat_resp = BREADY && BVALID;
assign done = (state==raise_done);
// AW comb
always@(*)begin
    AWADDR = rem_target_addr;
    AWVALID = 1'b0;
    if(state==addr_handshaking)begin
        AWVALID = 1;
    end
    AWLEN = rem_target_burst_len;
    AWSIZE = 0;
    AWBURST = 0;
end

// comb for w addr
always@(*)begin
    n_rem_target_addr = rem_target_addr;
    n_rem_target_burst_len = rem_target_burst_len;
    if(state == idle && start) begin
        n_rem_target_addr = AWADDR;
        n_rem_target_burst_len = AWLEN;
    end
end

// W comb
always@(*)begin
    n_snd_cnt = snd_cnt;
    if(state==idle)begin
        n_snd_cnt = 0;
    end else if(state==data_handshaking)begin
        if(WVALID && WREADY) begin
            n_snd_cnt = snd_cnt + 1;
        end
    end
    WLAST = 0;
    if(state==data_handshaking)begin
        if(WVALID && WREADY && snd_cnt>=rem_burst_len)begin
            WLAST = 1;
        end
    end
    WVALID = 0;
    WDATA = 0;
    if(state==data_handshaking)begin
        if(!dma2master_afifo_rempty)begin
            WVALID = 1;
            WDATA = dma2master_afifo_rdata;
        end
    end
end

// B comb.
always@(*)begin
    BREADY = (state==resp);
end

always@(*)begin
    case(state)
    idle:begin
        if(start) n_state = set_addr;
        else n_state = idle;
    end
    addr_handshaking:begin
        if(AWVALID && AWREADY) n_state = data_handshaking;
        else n_state = addr_handshaking;
    end
    data_handshaking:begin
        if(WVALID && WREADY && WLAST) n_state = resp;
        else n_state = data_handshaking;
    end
    resp:begin
        if(BRESP && BVALID && BREADY) n_state = raise_done;
        else n_state = resp;
    end
    raise_done:begin
        n_state = idle;
    end
    default: n_state = state;
    endcase
end

always@(posedge clk)begin
    if(!rst_n)begin
        state <= idle;
        rem_target_addr <= 0;
        rem_target_burst_len <= 0;
        snd_cnt <= 0;
    end else begin
        state <= n_state;
        rem_target_addr <= n_rem_target_addr;
        rem_target_burst_len <= n_rem_target_burst_len;
        snd_cnt <= n_snd_cnt;
    end
end

endmodule