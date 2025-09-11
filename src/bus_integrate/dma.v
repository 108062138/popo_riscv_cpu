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
    output reg dma_page_fault_done,
    input wire [ADDR_WIDTH-1:0] dma_page_fault_addr,
    input wire [READ_BURST_LEN-1:0] dma_page_fault_burst_len,
    // trigger axi read procedure
    output reg axi_master_read_start,
    input axi_master_rcv_read_start,
    input axi_master_read_done,
    output reg dma_rcv_read_done,
    output reg [ADDR_WIDTH-1:0] axi_master_target_read_addr,
    output reg [READ_BURST_LEN-1:0] axi_master_target_read_burst_len,
    // pull data from master2dma_afifo
    output reg master2dma_afifo_rpull,
    input wire master2dma_afifo_rempty,
    input wire [READ_CHANNEL_WIDTH-1:0] master2dma_afifo_rdata,

    // cache flush happend
    input wire dma_write_back_happen,
    output reg dma_write_back_done,
    input wire [ADDR_WIDTH-1:0] dma_write_back_addr,
    input wire [WRITE_BURST_LEN-1:0] dma_write_back_burst_len,
    // trigger axi write procedure
    output reg axi_master_write_start,
    input axi_master_rcv_write_start,
    input axi_master_write_done,
    output reg dma_rcv_write_done,
    output reg [ADDR_WIDTH-1:0] axi_master_target_write_addr,
    output reg [WRITE_BURST_LEN-1:0] axi_master_target_write_burst_len,
    // push data into dma2master_afifo
    output reg dma2master_afifo_wpush,
    output reg [WRITE_CHANNEL_WIDTH-1:0] dma2master_afifo_wdata,
    input wire dma2master_afifo_wfull
);

localparam r_idle = 0;
localparam r_raise_start = 1;
localparam r_process = 2;
localparam r_done = 3;

reg [3:0] r_state, n_r_state;
reg [ADDR_WIDTH-1:0] r_dma_page_fault_addr, n_r_dma_page_fault_addr;
reg [READ_BURST_LEN-1:0] r_dma_page_fault_burst_len, n_r_dma_page_fault_burst_len;
reg [READ_BURST_LEN-1:0] rcv_cnt, n_rcv_cnt;

always @(*) begin
    dma_page_fault_done = (r_state == r_done) && (n_r_state==r_idle);
    n_r_dma_page_fault_addr = r_dma_page_fault_addr;
    n_r_dma_page_fault_burst_len = r_dma_page_fault_burst_len;
    if(r_state==r_idle && dma_page_fault_happen && !axi_master_read_done)begin
        n_r_dma_page_fault_addr = dma_page_fault_addr;
        n_r_dma_page_fault_burst_len = dma_page_fault_burst_len;
    end
end

always @(*) begin
    axi_master_read_start = (r_state == r_raise_start);
    axi_master_target_read_addr = r_dma_page_fault_addr;
    axi_master_target_read_burst_len = r_dma_page_fault_burst_len;
    dma_rcv_read_done = (r_state==r_done);
end
always @(*) begin
    master2dma_afifo_rpull = 0;
    if(r_state==r_idle)begin
        n_rcv_cnt = 0;
    end else begin
        if(r_state == r_process || r_state == r_done)begin
            if(!master2dma_afifo_rempty)begin
                n_rcv_cnt = rcv_cnt + 1;
                master2dma_afifo_rpull = 1;
            end else begin
                n_rcv_cnt = rcv_cnt;
            end
        end else n_rcv_cnt = 0;
    end
end

always @(*) begin
    case (r_state)
        r_idle:begin
            if(dma_page_fault_happen && !axi_master_read_done)begin
                n_r_state = r_raise_start;
            end else begin
                n_r_state = r_idle;
            end
        end
        r_raise_start:begin
            if(axi_master_read_start && axi_master_rcv_read_start) n_r_state = r_process;
            else n_r_state = r_raise_start;
        end
        r_process:begin
            if(axi_master_read_done)begin
                n_r_state = r_done;
            end else begin
                n_r_state = r_process;
            end
        end
        r_done:begin
            if(!axi_master_read_done && rcv_cnt > r_dma_page_fault_burst_len) n_r_state = r_idle;
            else n_r_state = r_done;
        end
        default: begin
            n_r_state = r_state;
        end
    endcase
end

always @(posedge cpu_clk) begin
    if(!cpu_rst_n)begin
        r_dma_page_fault_addr <= 0;
        r_dma_page_fault_burst_len <= 0;
        r_state <= r_idle;
        rcv_cnt <= 0;
    end else begin
        r_dma_page_fault_addr <= n_r_dma_page_fault_addr;
        r_dma_page_fault_burst_len <= n_r_dma_page_fault_burst_len;
        r_state <= n_r_state;
        rcv_cnt <= n_rcv_cnt;
    end
end

localparam w_idle = 0;
localparam w_raise_start = 1;
localparam w_process = 2;
localparam w_done = 3;

reg [3:0] w_state, n_w_state;
reg [ADDR_WIDTH-1:0] r_dma_write_back_addr, n_r_dma_write_back_addr;
reg [WRITE_BURST_LEN-1:0] r_dma_write_back_burst_len, n_r_dma_write_back_burst_len;
reg [WRITE_BURST_LEN-1:0] snd_cnt, n_snd_cnt;
always @(*) begin
    n_r_dma_write_back_addr = r_dma_write_back_addr;
    n_r_dma_write_back_burst_len = r_dma_write_back_burst_len;
    if(w_state==w_idle && dma_write_back_happen && !axi_master_write_done)begin
        n_r_dma_write_back_addr = dma_write_back_addr;
        n_r_dma_write_back_burst_len = dma_write_back_burst_len;
    end
end
always @(*) begin
    dma_write_back_done = (w_state == w_done) && (n_w_state==w_idle);
    dma2master_afifo_wpush = 0;
    dma2master_afifo_wdata = 0;
    n_snd_cnt = snd_cnt;

    if(w_state==w_idle) n_snd_cnt = 0;
    else if(w_state==w_process)begin
        if(!dma2master_afifo_wfull && snd_cnt<=r_dma_write_back_burst_len)begin
           dma2master_afifo_wpush = 1;
           dma2master_afifo_wdata =  snd_cnt + r_dma_write_back_addr + 50;
           n_snd_cnt = snd_cnt + 1;
        end
    end
end

always @(*) begin
    axi_master_write_start = (w_state==w_raise_start);
    axi_master_target_write_addr = r_dma_write_back_addr;
    axi_master_target_write_burst_len = r_dma_write_back_burst_len;
    dma_rcv_write_done = (w_state==w_done);
end
always @(*) begin
    case(w_state)
    w_idle:begin
        if(dma_write_back_happen && !axi_master_write_done)begin
            n_w_state = w_raise_start;
        end else n_w_state = w_idle;
    end
    w_raise_start: begin
        if(axi_master_write_start && axi_master_rcv_write_start) n_w_state = w_process;
        else n_w_state = w_raise_start;
    end
    w_process:begin
        if(axi_master_write_done) n_w_state = w_done;
        else n_w_state = w_process;
    end
    w_done: begin
       if(!axi_master_write_done)n_w_state = w_idle;
       else n_w_state = w_done; 
    end
    default: n_w_state = w_state;
    endcase
end
always @(posedge cpu_clk) begin
    if(!cpu_rst_n)begin
        w_state <= w_idle;
        r_dma_write_back_addr <= 0;
        r_dma_write_back_burst_len <= 0;
        snd_cnt <= 0;
    end else begin
        w_state <= n_w_state;
        r_dma_write_back_addr <= n_r_dma_write_back_addr;
        r_dma_write_back_burst_len <= n_r_dma_write_back_burst_len;
        snd_cnt <= n_snd_cnt;
    end
end

endmodule