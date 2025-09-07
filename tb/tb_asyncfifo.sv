`timescale 1ps/1ps
module tb_asyncfifo();
parameter max_cyc = 100;
parameter CYC_W = 20;
parameter CYC_R = 10;

parameter DATA_WIDTH = 32;
parameter ADDR_WIDTH = 4;
parameter MEMORY_DEPTH = 1 << ADDR_WIDTH;
reg [DATA_WIDTH-1:0] wdata;
wire [DATA_WIDTH-1:0] rdata;
wire wfull, rempty;
reg wpush, wclk, wrst_n;
reg rpull, rclk, rrst_n;

asyncfifo #(
    .DATA_WIDTH(DATA_WIDTH),
    .ADDR_WIDTH(ADDR_WIDTH)
) u_asyncfifo (
    .rpull(rpull),
    .rempty(rempty),
    .rclk(rclk),
    .rrst_n(rrst_n),
    .rdata(rdata),
    .wpush(wpush),
    .wclk(wclk),
    .wrst_n(wrst_n),
    .wfull(wfull),
    .wdata(wdata)
);

integer i = 0;
integer seed = 3;

initial begin
    wclk = 0; rclk = 0;
end
always #(CYC_W/2) wclk = ~wclk;
always #(CYC_R/2) rclk = ~rclk;

// wrtie domain reset
initial begin
    wrst_n = 1; repeat(2)@(posedge wclk);
    wrst_n = 0; repeat(2)@(posedge wclk);
    @(posedge wclk); 
    wrst_n = 1;
end

// read domain reset
initial begin
    rrst_n = 1; repeat(2)@(posedge rclk);
    rrst_n = 0; repeat(2)@(posedge rclk);
    @(posedge rclk); 
    rrst_n = 1;
end

initial begin
    wpush = 0; rpull = 0;
    #(CYC_W * 20);
    wpush = 0; rpull = 1; // keep extracting data from fifo
    for(i=0;i<10;i=i+1)begin
        wpush = 1;
        wdata = i + 2;
        #(CYC_W);
        wpush = 0;
        wdata = 0;
        #(CYC_W);
    end
end

initial begin
    $dumpfile("asyncfifo_tb.vcd");
    $dumpvars(0, tb_asyncfifo);
end

initial begin
    repeat (max_cyc) @(posedge wclk);
    $finish;
end

endmodule