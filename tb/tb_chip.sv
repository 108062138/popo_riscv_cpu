`timescale 1ns/1ps

module tb_chip();

parameter CPU_CYC = 10;
parameter SYS_CYC = 40;
parameter max_cyc = 30;
reg cpu_clk;
reg sys_clk;
reg cpu_rst_n;
reg sys_rst_n;
integer i,j,k;
initial cpu_clk = 0;
always #(CPU_CYC/2) cpu_clk = ~cpu_clk;
always #(SYS_CYC/2) sys_clk = ~sys_clk;
initial begin
    repeat(max_cyc) @(posedge cpu_clk);
    $display("(QQ my love)");
    $finish;
end
initial begin
    $dumpfile("tb_chip.vcd");
    $dumpvars(0, tb_chip);
end

parameter INST_WIDTH = 32;
parameter INST_ADDR_WIDTH = 32;
parameter DATA_WIDTH = 32;
parameter DATA_ADDR_WIDTH = 32;
parameter NUM_WORDS_INST_MEM = 128;
parameter NUM_WORDS_DATA_MEM = 128;
parameter READ_BURST_LEN = 8;
parameter WRITE_BURST_LEN = 8;


// main entry
initial begin
    reset_all();
end

event reset_done;
task reset_all();
fork
    begin
        sys_rst_n = 1; cpu_rst_n = 1; repeat(2)@(negedge sys_clk);
        sys_rst_n = 0; cpu_rst_n = 0; repeat(2)@(negedge sys_clk);
        sys_rst_n = 1; cpu_rst_n = 1; repeat(4)@(negedge sys_clk);
    end
join
-> reset_done;
endtask

chip #(
    .INST_WIDTH(INST_WIDTH),
    .INST_ADDR_WIDTH(INST_ADDR_WIDTH),
    .DATA_WIDTH(DATA_WIDTH),
    .DATA_ADDR_WIDTH(DATA_ADDR_WIDTH),
    .NUM_WORDS_INST_MEM(NUM_WORDS_INST_MEM),
    .NUM_WORDS_DATA_MEM(NUM_WORDS_DATA_MEM),
    .READ_BURST_LEN(READ_BURST_LEN),
    .WRITE_BURST_LEN(WRITE_BURST_LEN)
) u_chip(
    .sys_clk(sys_clk),
    .sys_rst_n(sys_rst_n),
    .cpu_clk(cpu_clk),
    .cpu_rst_n(cpu_rst_n)
);

endmodule
