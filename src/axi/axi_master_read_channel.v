// handle read address channel, read data channel

module axi_master_read_channel #(
    parameter ADDR_WIDTH = 32,
    parameter READ_CHANNEL_WIDTH = 32, // 32 bit per burst
    parameter READ_BURST_LEN = 8
)(
    input wire clk,
    input wire rst_n,
    input wire start,
    output reg axi_master_rcv_read_start,
    input wire [ADDR_WIDTH-1:0] target_read_addr,
    input wire [READ_BURST_LEN-1:0] target_read_burst_len,
    output wire done,
    input wire dma_rcv_read_done,
    // read address channel
    input wire ARREADY,
    output reg [ADDR_WIDTH-1:0] ARADDR,
    output reg ARVALID,
    output reg [READ_BURST_LEN-1:0] ARLEN,
    output reg [2:0] ARSIZE,
    output reg [1:0] ARBURST,
    // read data channel
    input wire RVALID,
    input wire [READ_CHANNEL_WIDTH-1:0] RDATA,
    input wire RLAST,
    input wire [1:0] RRESP,
    output reg RREADY,
    // master 2 dma fifo
    output reg master2dma_afifo_wpush,
    output reg [READ_CHANNEL_WIDTH-1:0] master2dma_afifo_wdata,
    input wire master2dma_afifo_wfull
);

localparam idle = 0;
localparam addr_handshaking = 1;
localparam data_handshaking = 2;
localparam raise_done = 3; 

reg [1:0] state, n_state;
reg [ADDR_WIDTH-1:0] rem_target_read_addr, n_rem_target_read_addr;
reg [READ_BURST_LEN-1:0] rem_burst_len, n_rem_burst_len;
wire lfsr_out;
wire beat_raddr, beat_rdata;

assign beat_raddr = (ARVALID && ARREADY);
assign beat_rdata = (RVALID && RREADY);
assign done = (state==raise_done);

// AR comb. for handshaking signals
always@(*)begin
    ARADDR = rem_target_read_addr;
    ARVALID = 1'b0;
    if(state == addr_handshaking)begin
        ARVALID = 1'b1;
    end
    ARLEN = rem_burst_len; // 4 bytes per beat
    ARSIZE = 3'b010; // 4 bytes per beat
    ARBURST = 2'b01; // incrementing
end

// R comb. for handshaking signals
always@(*)begin//123456
    RREADY = 1'b0;
    master2dma_afifo_wpush = 1'b0;
    master2dma_afifo_wdata = 0;
    if(state == data_handshaking)begin
        if(!master2dma_afifo_wfull)begin
            RREADY = 1'b1;
            if(RVALID)begin
                master2dma_afifo_wpush = 1;
                master2dma_afifo_wdata = RDATA;
            end
        end
    end
end
// always @(posedge clk) begin
//     if(state==data_handshaking)begin
//         if(RVALID && RREADY) $display("read and about to send %d to dma", RDATA);
//     end
// end

always @(*) begin
    axi_master_rcv_read_start = 0;
    if(state==addr_handshaking || state==data_handshaking)begin
        axi_master_rcv_read_start = 1;
    end
end

// comb for rem target read addr
always@(*)begin
    n_rem_target_read_addr = rem_target_read_addr;
    n_rem_burst_len = rem_burst_len;
    if(state == idle && start) begin
        n_rem_target_read_addr = target_read_addr;
        n_rem_burst_len = target_read_burst_len;
    end
end

// comb for read state generation
always@(*)begin
    case(state)
    idle: begin
        if(!start || done) n_state = idle;
        else n_state = addr_handshaking;
    end
    addr_handshaking: begin
        if(ARVALID && ARREADY) n_state = data_handshaking;
        else n_state = addr_handshaking;
    end
    data_handshaking: begin
        if(RVALID && RREADY && RLAST) n_state = raise_done;
        else n_state = data_handshaking;
    end
    raise_done: begin
        if(dma_rcv_read_done) n_state = idle;
        else n_state = raise_done;
    end
    default: n_state = state;
    endcase
end

always @(posedge clk) begin
    if (!rst_n) begin
        state <= idle;
        rem_target_read_addr <= 0;
        rem_burst_len <= 0;
    end else begin
        state <= n_state;
        rem_target_read_addr <= n_rem_target_read_addr;
        rem_burst_len <= n_rem_burst_len;
    end
end

endmodule