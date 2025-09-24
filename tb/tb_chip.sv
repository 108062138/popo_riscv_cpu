`timescale 1ns/1ps

module tb_chip();

parameter CPU_CYC = 10;
parameter SYS_CYC = 40;
parameter max_cyc = 600;
reg cpu_clk;
reg sys_clk;
reg cpu_rst_n;
reg sys_rst_n;
integer i,j,k;
initial cpu_clk = 0;
always #(CPU_CYC/2) cpu_clk = ~cpu_clk;
always #(SYS_CYC/2) sys_clk = ~sys_clk;
initial begin
    wait(u_chip.u_cpu.u_regfile.rf[31]==666 || u_chip.u_cpu.u_regfile.rf[31]==404);
    if(u_chip.u_cpu.u_regfile.rf[31]==666) begin
        $display("TEST PASS! Use cycle %d", cnt);
    end else begin
        $display("TEST FAIL!");
    end
    $finish;
end
initial begin
    repeat(max_cyc) @(posedge cpu_clk);
    $display("Error: Exceed max cycle %d", max_cyc);
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
        sys_rst_n = 1; cpu_rst_n = 1; repeat(1)@(negedge sys_clk);
        sys_rst_n = 0; cpu_rst_n = 0; repeat(2)@(negedge sys_clk);
        sys_rst_n = 1; cpu_rst_n = 1; repeat(2)@(negedge sys_clk);
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
reg [32-1:0] cnt;
always @(posedge cpu_clk) begin
    if(!cpu_rst_n)begin
        cnt <= 0;
    end else begin
        // $display("at cyc: %d PC=%d IF[%h] ID[%h] EX[%h] MEM[%h] WB[%h] wen:%b reg{%d}<= %d with F1: %b F2: %b HZ:ST[%b%b] ,FL[%b%b]", cnt, 
        // u_chip.u_cpu.PC, u_chip.u_cpu.INST, u_chip.u_cpu.INST_ID, u_chip.u_cpu.INST_EX, u_chip.u_cpu.INST_MEM, u_chip.u_cpu.INST_WB,
        // u_chip.u_cpu.u_regfile.we, u_chip.u_cpu.u_regfile.wd_addr, u_chip.u_cpu.u_regfile.wd_data,
        // u_chip.u_cpu.forward_detect_rs1, u_chip.u_cpu.forward_detect_rs2,
        // u_chip.u_cpu.stall_PC_IF, u_chip.u_cpu.stall_IF_ID,
        // u_chip.u_cpu.flush_IF_ID, u_chip.u_cpu.flush_ID_EX);

        $display("at cyc: %4d PC=%4d IF[%h] ID[%h] EX[%h] MEM[%h] WB[%h] wen:%b reg{%4d}<= %h || mem_w:%b at mem{%h}<=%h with ra=%3d sp=%3d a0=%3d t0=%3d", cnt, 
        u_chip.u_cpu.PC, u_chip.u_cpu.INST, u_chip.u_cpu.INST_ID, u_chip.u_cpu.INST_EX, u_chip.u_cpu.INST_MEM, u_chip.u_cpu.INST_WB,
        u_chip.u_cpu.u_regfile.we, u_chip.u_cpu.u_regfile.wd_addr, u_chip.u_cpu.u_regfile.wd_data,
        u_chip.u_L1_cache.u_data_mem.data_mem_write, u_chip.u_L1_cache.u_data_mem.cpu_data_mem_waddr, u_chip.u_L1_cache.u_data_mem.cpu_data_mem_wdata,
        u_chip.u_cpu.u_regfile.rf[1], u_chip.u_cpu.u_regfile.rf[2], u_chip.u_cpu.u_regfile.rf[10], u_chip.u_cpu.u_regfile.rf[5]
        );

        cnt <= cnt + 1;
    end
end

endmodule
