// it manipulate axi-master by start and listen to its end signal
module dma #(
    parameter ADDR_WIDTH = 32,
    parameter READ_CHANNEL_WIDTH = 32,
    parameter READ_BURST_LEN = 8,
    parameter WRITE_CHANNEL_WIDTH = 32,
    parameter WRITE_BURST_LEN = 8
)(
    input wire cpu_clk,
    input wire cpu_rst_n,
    // page fault happend
    input wire dma_page_fault_happen,
    output wire dma_page_fault_done,
    input wire [ADDR_WIDTH-1:0] dma_page_fault_addr,
    input wire [READ_BURST_LEN-1:0] dma_page_fault_burst_len,
    // trigger axi read procedure
    output reg axi_master_read_start,
    input axi_master_read_done,
    output reg [ADDR_WIDTH-1:0] axi_master_target_read_addr,
    output reg [READ_BURST_LEN-1:0] axi_master_target_read_burst_len,
    // pull data from master2dma_afifo
    output reg master2dma_afifo_rpull,
    input wire master2dma_afifo_rempty,
    input wire [READ_CHANNEL_WIDTH-1:0] master2dma_afifo_rdata,

    // cache flush happend
    input wire dma_write_back_happen,
    output wire dma_write_back_done,
    input wire [ADDR_WIDTH-1:0] dma_write_back_addr,
    input wire [WRITE_BURST_LEN-1:0] dma_write_back_burst_len,
    // trigger axi write procedure
    output reg axi_master_write_start,
    input axi_master_write_done,
    output reg [ADDR_WIDTH-1:0] axi_master_target_write_addr,
    output reg [WRITE_BURST_LEN-1:0] axi_master_target_write_burst_len,
    // push data into dma2master_afifo
    output reg dma2master_afifo_wpush,
    output reg [WRITE_CHANNEL_WIDTH-1:0] dma2master_afifo_wdata,
    input wire dma2master_afifo_wfull
);

localparam r_idle = 0;
localparam r_processing = 1;
localparam r_done = 2;
localparam w_idle = 3;
localparam w_processing = 4;
localparam w_done = 5;

reg [2:0] r_state, n_r_state;
reg [READ_BURST_LEN-1:0] r_cnt, n_r_cnt;
reg [1:0] cool_r, n_cool_r;
reg [2:0] w_state, n_w_state;
reg [WRITE_BURST_LEN-1:0] w_cnt, n_w_cnt;
reg [5:0] cool_w, n_cool_w;

assign dma_page_fault_done = (r_state == r_done);
assign dma_write_back_done = (w_state == w_done);

// naively pull data when possible
always@(*)begin
    n_r_cnt = r_cnt;
    master2dma_afifo_rpull = 0;
    if(r_state==r_idle)begin
        n_r_cnt = 0;
    end else begin
        if(!master2dma_afifo_rempty) begin
            master2dma_afifo_rpull = 1;
            n_r_cnt = r_cnt + 1;
        end
    end
end
// naively push data when possible
always@(*)begin
    n_w_cnt = w_cnt;
    dma2master_afifo_wpush = 0;
    dma2master_afifo_wdata = 0;
    
    if(w_state==w_idle)begin
        n_w_cnt = 0;
    end else if(!dma2master_afifo_wfull && w_state==w_processing && w_cnt <= dma_write_back_burst_len)begin
        dma2master_afifo_wpush = 1;
        dma2master_afifo_wdata = dma_write_back_addr + w_cnt+ 50;
        n_w_cnt = w_cnt + 1;
    end 
end
// handle read
always@(posedge cpu_clk)begin
    if(dma_page_fault_happen)begin
        axi_master_read_start <= (r_state == r_processing);
        axi_master_target_read_addr <= dma_page_fault_addr;
        axi_master_target_read_burst_len <= dma_page_fault_burst_len;
    end else begin
        axi_master_read_start <= axi_master_read_start && (cool_r < 3);
        axi_master_target_read_addr <= axi_master_target_read_addr;
        axi_master_target_read_burst_len <= axi_master_target_read_burst_len;
    end 
end
always@(*)begin
    n_cool_r = cool_r;
    case(r_state)
    r_idle:begin
        if(dma_page_fault_happen && !axi_master_read_done) n_r_state = r_processing;
        else n_r_state = r_idle;
        n_cool_r = 0;
    end
    r_processing:begin
        n_cool_r = (cool_r<=3)? cool_r +1: cool_r;
        if(axi_master_read_done) n_r_state = r_done;
        else n_r_state = r_processing;
    end
    r_done:begin
        n_cool_r = cool_r;
        if(r_cnt >= dma_page_fault_burst_len) n_r_state = r_idle;
        else n_r_state = r_done;
    end
    default: begin
        n_cool_r = cool_r;
        n_r_state = r_state;
    end
    endcase
end

// handle write
always@(posedge cpu_clk)begin
    if(dma_write_back_happen)begin
        axi_master_write_start <= (w_state == w_processing);
        axi_master_target_write_addr <= dma_write_back_addr;
        axi_master_target_write_burst_len <= dma_write_back_burst_len;
    end else begin
        axi_master_write_start <= axi_master_write_start && (cool_w < 3);
        axi_master_target_write_addr <= axi_master_target_write_addr;
        axi_master_target_write_burst_len <= axi_master_target_write_burst_len;
    end
end
always@(*)begin
    n_cool_w = cool_w;
    case(w_state)
    w_idle:begin
        n_cool_w = 0;
        if(dma_write_back_happen && !axi_master_write_done) n_w_state = w_processing;
        else n_w_state = w_idle;
    end
    w_processing:begin
        n_cool_w = (cool_w<=3)?cool_w+1: cool_w;
        if(axi_master_write_done) n_w_state = w_done;
        else n_w_state = w_processing;
    end
    w_done:begin
        n_cool_w = cool_w;
        if(w_cnt >= dma_write_back_burst_len) n_w_state = w_idle;
        else n_w_state = w_done;
    end
    default: begin
        n_cool_w = cool_w;
        n_w_state = w_state;
    end
    endcase
end

always @(posedge cpu_clk) begin
    if(!cpu_rst_n)begin
        w_state <= w_idle;
        w_cnt <= 0;
        r_state <= r_idle;
        r_cnt <= 0;
        cool_r <= 0;
        cool_w <= 0;
    end else begin
        w_state <= n_w_state;
        w_cnt <= n_w_cnt;
        r_state <= n_r_state;
        r_cnt <= n_r_cnt;
        cool_r <= n_cool_r;
        cool_w <= n_cool_w;
    end
end

endmodule