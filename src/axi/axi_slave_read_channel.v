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
    input wire RREADY,
    // mem control signal
    output reg mem_ren,
    output reg [ADDR_WIDTH-1:0] mem_raddr,
    input wire [READ_CHANNEL_WIDTH-1:0] mem_rdata
);

localparam idle = 0;
localparam prep_0 = 1;
localparam prep_1 = 2;
localparam same = 3;
localparam diff = 4;


reg cd, n_cd;
reg [2:0] state, n_state;
reg [ADDR_WIDTH-1:0] r_ARADDR, n_r_ARADDR;
reg [ADDR_WIDTH-1:0] prev_raddr, cur_raddr;
reg [READ_BURST_LEN-1:0] r_ARLEN, n_r_ARLEN;
reg [READ_BURST_LEN-1:0] snd_cnt, n_snd_cnt;
reg [READ_BURST_LEN-1:0] read_mark, n_read_mark;
reg [2:0] r_ARSIZE, n_r_ARSIZE;
reg [1:0] r_ARBURST, n_r_ARBURST;

always @(*) begin
    ARREADY = (state==idle);
end

always@(*)begin
    n_r_ARADDR = r_ARADDR;
    n_r_ARLEN = r_ARLEN;
    n_r_ARSIZE = r_ARSIZE;
    n_r_ARBURST = r_ARBURST;
    if(state==idle)begin
        n_r_ARADDR = ARADDR;
        n_r_ARLEN = ARLEN;
        n_r_ARSIZE = ARSIZE;
        n_r_ARBURST = ARBURST;
    end
end
always @(*) begin
    RVALID = 0;
    if(state==same)begin
        RVALID = 1;
    end else if(state==diff && cd)begin
        RVALID = 1;
    end
end
always @(*) begin
    mem_ren = (state!=idle);
    mem_raddr = r_ARADDR + read_mark;
    RLAST = (snd_cnt==r_ARLEN)? 1'b1: 1'b0;
    RRESP = (snd_cnt==r_ARLEN)? 2'b10 : 2'b0;
    RDATA = mem_rdata;
end
always @(*) begin
    case(state)
    idle:begin
        if(ARVALID && ARREADY)begin
            n_state = prep_0;
        end else n_snd_cnt = idle;
        n_snd_cnt = 0;
        n_cd = 0;
        n_read_mark = 0;
    end
    prep_0: begin
        n_state = prep_1;
        n_snd_cnt = 0;
        n_cd = 0;
        n_read_mark = 0;
    end
    prep_1: begin
        n_state = same;
        n_snd_cnt = 0;
        n_cd = 0;
        n_read_mark = 0;
    end
    same:begin
        if(RREADY)begin
            if(snd_cnt < r_ARLEN) n_state = diff;
            else n_state = idle;
        end else n_state = same;
        n_cd = 0;
        n_read_mark = read_mark + (RVALID && RREADY);
        n_snd_cnt = snd_cnt + (RVALID && RREADY);
    end
    diff:begin
        if(RREADY)begin
            if(snd_cnt < r_ARLEN) n_state = diff;
            else n_state = idle;
        end else begin
            n_state = same;
        end
        n_cd = 1;
        n_snd_cnt = snd_cnt + (RVALID && RREADY);
        n_read_mark = read_mark + 1;
    end
    default: begin
        n_state = state;
        n_snd_cnt = 0;
        n_cd = 0;
        n_read_mark = 0;
    end
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
        prev_raddr <= 0;
        cur_raddr <= 0;
        read_mark <= 0;
    end else begin
        state <= n_state;
        r_ARADDR <= n_r_ARADDR;
        r_ARLEN <= n_r_ARLEN;
        snd_cnt <= n_snd_cnt;
        r_ARSIZE <= n_r_ARSIZE;
        r_ARBURST <= n_r_ARBURST;
        prev_raddr <= mem_raddr;
        cd <= n_cd;
        read_mark <= n_read_mark;
    end
end

endmodule