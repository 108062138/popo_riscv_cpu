`timescale 1ps/1ps
module tb_asyncfifo();

parameter max_cyc = 400;
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

reg start_test_1, end_test_1;
integer test_1_size;
integer rcv_cnt;

integer i = 0;

// Instantiate FIFO
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

// Clock generation
initial begin
    wclk = 0;
    rclk = 0;
end
always #(CYC_W/2) wclk = ~wclk;
always #(CYC_R/2) rclk = ~rclk;

// Dumpfile for GTKWave
initial begin
    $dumpfile("tb_asyncfifo.vcd");
    $dumpvars(0, tb_asyncfifo);
end

// Simulation end
initial begin
    repeat (max_cyc) @(posedge wclk);
    $finish;
end

initial begin
    reset_all();
    @reset_done;
end

// // Reset
// initial begin
//     wrst_n = 1; repeat(2)@(negedge wclk);
//     wrst_n = 0; repeat(2)@(negedge wclk);
//     @(negedge wclk); 
//     wrst_n = 1;
// end

// initial begin
//     rrst_n = 1; repeat(2)@(negedge rclk);
//     rrst_n = 0; repeat(2)@(negedge rclk);
//     @(negedge rclk); 
//     rrst_n = 1;
// end

// Main test entry
initial begin
    start_test_1 = 0; end_test_1 = 0; test_1_size = 16;
    test_1(test_1_size);
    wait(end_test_1);
    $display("✅ pass test 1: write and keep read");
end

// Write then read test
task test_1;
    input integer test_1_size;
    begin
        wpush = 0;
        wdata = 0;
        repeat(20) @(negedge wclk); // wait FIFO ready
        start_test_1 = 1;

        for (i = 0; i < test_1_size; i = i + 1) begin
            // Wait until FIFO is not full
            while (wfull) @(posedge wclk);

            // Setup at negedge
            @(negedge wclk); #3ps; // set up a bit
            wpush = 1;
            wdata = i + 2;

            // Wait posedge
            @(posedge wclk); #2ps;  // hold a bit

            // Clear
            wpush = 0;
            wdata = 0;
        end
    end
endtask

initial begin
    wait(start_test_1);
    rcv_cnt = 0;
    @(posedge rclk);
    // consider at cycle T, and a cycle starts from one posedge to another posedge
    while (rcv_cnt < test_1_size) begin
        @(posedge rclk); #2ps; // wait for data settle
        if (!rempty) begin
            // Verify data
            assert (rdata == rcv_cnt + 2)
            else $display("[%t] ❌ ERROR: rdata = %0d, expected = %0d", $time, rdata, rcv_cnt + 2);
            rcv_cnt++;
        end
    end
    end_test_1 = 1;
end

initial begin
    rpull = 0;
    wait(start_test_1);
    while(!end_test_1)begin
        @(posedge rclk); #2ps;
        if(!rempty)begin
            // Pull request at next negedge
            @(negedge rclk);
            rpull = 1;
            // Drop rpull after one cycle
            @(negedge rclk);
            rpull = 0;
        end
    end
end

event reset_done;
task reset_all();
fork
    begin
        wrst_n = 1; repeat(2)@(negedge wclk);
        wrst_n = 0; repeat(2)@(negedge wclk);
        @(negedge wclk); 
        wrst_n = 1;
    end
    begin
        rrst_n = 1; repeat(2)@(negedge rclk);
        rrst_n = 0; repeat(2)@(negedge rclk);
        @(negedge rclk); 
        rrst_n = 1;
    end
join
-> reset_done;
endtask

endmodule
