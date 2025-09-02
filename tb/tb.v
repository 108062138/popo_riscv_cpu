`timescale 1ns/1ps

module tb();
    parameter CYC = 10;
    parameter max_cyc = 40;
    reg clk;
    reg rst_n;
    reg start;
    wire [32-1:0] fetch_inst;
    wire valid;
    // clock
    
    initial clk = 0;
    always #(CYC/2) clk = ~clk;

    // reset
    initial begin
        start = 0;
        rst_n = 1; #(CYC * 4);
        rst_n = 0; #(CYC * 2);
        rst_n = 1; #(CYC * 2);
        start = 1; #(CYC);
    end

    // dump
    initial begin
        $dumpfile("./build/cpu_tb.vcd");
        $dumpvars(0, tb);
    end

    initial begin
        repeat(max_cyc) @(posedge clk);
        $finish;
    end

    chip dut(
        .clk(clk),
        .rst_n(rst_n),
        .start(start),
        .fetch_inst(fetch_inst),
        .valid(valid)
    );

endmodule
