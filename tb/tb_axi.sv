module tb_axi();
    parameter CYC = 10;
    parameter max_cyc = 100;
    reg clk;
    reg rst_n;

    initial clk = 0;
    always #(CYC/2) clk = ~clk;

    initial begin
        repeat(max_cyc) @(posedge clk);
        $finish;
    end

    initial begin
        $dumpfile("axi_tb.vcd");
        $dumpvars(0, tb);
    end

    initial begin
        rst_n = 1; #(CYC *2);
        rst_n = 0; #(CYC *3);
        rst_n = 1;
    end

    parameter ADDR_WIDTH = 32;
    parameter READ_CHANNEL_WIDTH = 32;
    parameter READ_BURST_LEN = 8;
    parameter WRITE_CHANNEL_WIDTH = 32, // 32 bit per beat
    parameter WRITE_BURST_LEN = 8,

    // interface: master <-> slave, 1 to 1

    // read control
    reg start_read;
    reg [ADDR_WIDTH-1:0] target_read_addr;
    reg [READ_BURST_LEN-1:0] target_read_burst_len;
    wire done_read;

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

    // write control:
    wire start_write;
    reg [ADDR_WIDTH-1:0] target_write_addr;
    reg [WRITE_BURST_LEN-1:0] target_write_burst_len;
    reg [WRITE_CHANNEL_WIDTH-1:0] target_write_data;
    wire target_write_fifo_pull;
    reg target_write_fifo_empty;
    wire done_write;

    // write address channel
    wire AWREADY;
    wire [ADDR_WIDTH-1:0] AWADDR;
    wire AWVALID;
    wire [WRITE_BURST_LEN-1:0] AWLEN;
    wire [2:0] AWSIZE;
    wire [1:0] ARBURST;
    // write data channel
    wire WREADY;
    wire WVALID;
    wire [WRITE_CHANNEL_WIDTH-1:0] WDATA;
    wire WLAST;
    // write data responce
    wire BREADY;
    wire BRESP;
    wire BVALID;

    task set_raddr_rlen_and_wait;
        input [ADDR_WIDTH-1:0] desire_read_addr;
        input [READ_BURST_LEN-1:0] desire_read_burst_len;
        begin
            target_read_addr = desire_read_addr;
            target_read_burst_len = desire_read_burst_len - 1; // minus 1 to fit AXI format: move x data, so len RLEN is set as (x-1)
            start_read = 1;
            #(CYC);
            wait(done_read);
            $display("Time: %0t | READ only finish: target_read_addr: %d, target_read_burst_len: %d, ", $time, desire_read_addr, desire_read_burst_len);
            target_read_addr = 0;
            target_read_burst_len = 0;
            start_read = 0;
        end
    endtask

    task set_waddr_wlen_wdata_and_wait;
        input [ADDR_WIDTH-1:0] desire_write_addr;
        input [READ_BURST_LEN-1:0] desire_write_burst_len;
        begin
            target_write_addr = desire_write_addr;
            target_write_burst_len = desire_write_burst_len - 1; // minus 1 to fit AXI format: write x data, so len WLEN is set as (x-1)
            start_write = 1;
            #(CYC);
            wait(done_read);
            $display("Time: %0t | WRITE only finish: target_read_addr: %d, target_read_burst_len: %d, ", $time, desire_read_addr, desire_read_burst_len);
            target_write_addr = 0;
            target_write_burst_len = 0;
            start_write = 0;
        end
    endtask

    initial begin
        start_read = 0;
        target_read_addr = 0;
        target_read_burst_len = 0;
        #(CYC * 10);
        set_raddr_rlen_and_wait(32'd123, 8'd4);
        #(CYC * 10);
        set_raddr_rlen_and_wait(32'd5, 8'd1);
        #(CYC * 1);
        set_raddr_rlen_and_wait(32'd789, 8'd2);
        #(CYC * 10);
    end

    axi_master #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .READ_CHANNEL_WIDTH(READ_CHANNEL_WIDTH),
        .READ_BURST_LEN(READ_BURST_LEN)
    ) u_axi_master(
        .clk(clk),
        .rst_n(rst_n),
        .start_read(start_read),
        .target_read_addr(target_read_addr),
        .target_read_burst_len(target_read_burst_len),
        .done_read(done_read),
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
        .RREADY(RREADY)
    );

    axi_slave #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .READ_CHANNEL_WIDTH(READ_CHANNEL_WIDTH),
        .READ_BURST_LEN(READ_BURST_LEN)
    ) u_axi_slave(
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
        .RREADY(RREADY)
    );
endmodule
