// handle read address channel, read data channel
module axi_slave_read_channel #(
    parameter ADDR_WIDTH = 32,
    parameter READ_CHANNEL_WIDTH = 32, // 32 bit per burst
    parameter READ_BURST_LEN = 8
)(
    input wire clk,
    input wire rst_n,
    // read address channel
    output reg ARREADY,
    input wire [ADDR_WIDTH-1:0] ARADDR,
    input wire ARVALID,
    input wire [READ_BURST_LEN-1:0] ARLEN,
    input wire [2:0] ARSIZE,
    input wire [1:0] ARBURST,
    // read data channel
    output reg RVALID,
    output reg [READ_CHANNEL_WIDTH-1:0] RDATA,
    output reg RLAST,
    output reg [1:0] RRESP,
    input wire RREADY
);

localparam idle = 0;
localparam transmit = 1;

reg [1:0] state, n_state;

reg [ADDR_WIDTH-1:0] r_ARADDR, n_r_ARADDR;
reg [READ_BURST_LEN-1:0] r_ARLEN, n_r_ARLEN, snd_cnt, n_snd_cnt;
reg [2:0] r_ARSIZE, n_r_ARSIZE;
reg [1:0] r_ARBURST, n_r_ARBURST;

wire lfsr_out;
wire beat_raddr, beat_rdata;

assign beat_raddr = (ARVALID && ARREADY);
assign beat_rdata = (RVALID && RREADY);

// just to immitate rcving data buffer condition
lfsr_4 u_lfsr_4(.clk(clk), .rst_n(rst_n), .lfsr_out(lfsr_out));

// remember the raddr value
always@(*)begin
    n_r_ARADDR = r_ARADDR;
    n_r_ARLEN = r_ARLEN;
    n_r_ARSIZE = r_ARSIZE;
    n_r_ARBURST = r_ARBURST;
    if(state==idle && ARVALID && ARREADY)begin
        n_r_ARADDR = ARADDR;
        n_r_ARLEN = ARLEN;
        n_r_ARSIZE = ARSIZE;
        n_r_ARBURST = ARBURST;
    end
end

// AR comb. for handshaking signals
always@(*)begin
    ARREADY = 1;
    if(state!=idle) ARREADY = 0;
end

// R comb. for handshaking signals
always@(*)begin
    if(state==transmit)begin
        if(lfsr_out)begin
            RVALID = 1;
            if(RREADY)begin
                n_snd_cnt = snd_cnt + 1;
                RDATA = r_ARADDR + {24'b0, snd_cnt};
            end else begin
                n_snd_cnt = snd_cnt;
                RDATA = 0;
            end
        end else begin
            RVALID = 0;
            n_snd_cnt = snd_cnt;
            RDATA = 0;
        end
    end else begin
        RVALID = 0;
        n_snd_cnt = 0;
        RDATA = 0;
    end

    RLAST = 0;
    RRESP = 0;
    if(state==transmit && RVALID && RREADY && snd_cnt==r_ARLEN)begin
        RLAST = 1;
        RRESP = 1;
    end
end

always@(*)begin
    case(state)
    idle:begin
        if(ARVALID && ARREADY) n_state = transmit;
        else n_state = idle;
    end
    transmit:begin
        if(snd_cnt >= r_ARLEN && RVALID && RREADY) n_state = idle;
        else n_state = transmit;
    end
    default: n_state = state;
    endcase
end

always@(posedge clk)begin
    if(!rst_n)begin
        state <= idle;
        r_ARADDR <= 0;
        r_ARLEN <= 0;
        snd_cnt <= 0;
        r_ARSIZE <= 0;
        r_ARBURST <= 0;
    end else begin
        state <= n_state;
        r_ARADDR <= n_r_ARADDR;
        r_ARLEN <= n_r_ARLEN;
        snd_cnt <= n_snd_cnt;
        r_ARSIZE <= n_r_ARSIZE;
        r_ARBURST <= n_r_ARBURST;
    end
end

endmodule