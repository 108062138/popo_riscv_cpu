`timescale 1ns/1ps

module tb();
    parameter CYC = 10;
    parameter max_cyc = 30;
    parameter INST_WIDTH = 32;
    parameter INST_ADDR_WIDTH = 7;
    parameter DATA_WIDTH = 32;
    parameter DATA_ADDR_WIDTH = 7;

    reg clk;
    reg rst_n;
    reg start;
    wire [INST_WIDTH-1:0] fetch_inst;
    wire inst_valid;
    wire [DATA_WIDTH-1:0] fetch_data;
    wire data_valid;
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
        .inst_valid(inst_valid),
        .fetch_data(fetch_data),
        .data_valid(data_valid)
    );

endmodule
