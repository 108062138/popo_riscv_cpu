`timescale 1ns/1ps

module tb_chip();

parameter CPU_CYC = 10;
parameter SYS_CYC = 40;
parameter max_cyc = 3000;
reg cpu_clk;
reg sys_clk;
reg cpu_rst_n;
reg sys_rst_n;
integer i,j,k;
initial cpu_clk = 0;
initial sys_clk = 0;
always #(CPU_CYC/2) cpu_clk = ~cpu_clk;
always #(SYS_CYC/2) sys_clk = ~sys_clk;
initial begin
    wait(u_chip.u_cpu.u_regfile.rf[31]==666 || u_chip.u_cpu.u_regfile.rf[31]==404);
    if(u_chip.u_cpu.u_regfile.rf[31]==666) begin
        $display("TEST PASS! Use cycle %d", cnt);
    end else begin
        $display("TEST FAIL!");
    end
    print_perf();
    $fclose(commit_fd);
    $fclose(store_fd);
    $finish;
end
initial begin
    repeat(max_cyc) @(posedge cpu_clk);
    $display("Error: Exceed max cycle %d", max_cyc);
    print_perf();
    $fclose(commit_fd);
    $fclose(store_fd);
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

// ---------------------------------------------------------------------------
// Commit / store traces, compared against tb/iss/rv32_iss.py by tb/iss/compare_trace.py.
// commit: "<pc> <inst> <rd> <value>" for every instruction that reaches WB.
// store:  "<byte addr> <data masked by strobe> <strobe>" for every data memory write.
// Output files: +commit=<file> +stores=<file> (defaults below).
// ---------------------------------------------------------------------------
integer commit_fd, store_fd;
string commit_file, store_file;
initial begin
    if(!$value$plusargs("commit=%s", commit_file)) commit_file = "rtl_commit.log";
    if(!$value$plusargs("stores=%s", store_file)) store_file = "rtl_store.log";
    commit_fd = $fopen(commit_file, "w");
    store_fd = $fopen(store_file, "w");
end

wire [31:0] trace_store_mask = {{8{u_chip.cpu_data_mem_write_strobe[3]}}, {8{u_chip.cpu_data_mem_write_strobe[2]}},
                                {8{u_chip.cpu_data_mem_write_strobe[1]}}, {8{u_chip.cpu_data_mem_write_strobe[0]}}};
always @(posedge cpu_clk) begin
    if(cpu_rst_n) begin
        if(u_chip.u_cpu.INST_WB != 0) begin
            if(u_chip.u_cpu.reg_write_WB && u_chip.u_cpu.rd_WB != 0)
                $fdisplay(commit_fd, "%h %h %02d %h", u_chip.u_cpu.PC_plus_4_MEM_WB_o - 32'd4, u_chip.u_cpu.INST_WB,
                          u_chip.u_cpu.rd_WB, u_chip.u_cpu.result_WB);
            else
                $fdisplay(commit_fd, "%h %h - -", u_chip.u_cpu.PC_plus_4_MEM_WB_o - 32'd4, u_chip.u_cpu.INST_WB);
        end
        if(u_chip.cpu_data_mem_write)
            $fdisplay(store_fd, "%h %h %h", u_chip.cpu_data_mem_waddr, u_chip.cpu_data_mem_wdata & trace_store_mask,
                      u_chip.cpu_data_mem_write_strobe);
    end
end

// ---------------------------------------------------------------------------
// Performance counters. Lost cycles are classified with the same priority as
// hazard_detection: 2-cycle redirect > stall > 1-cycle (ID) redirect.
// ---------------------------------------------------------------------------
integer perf_instret = 0, perf_redirect2 = 0, perf_stall = 0, perf_redirect1 = 0;
`ifdef CPU_OPT
integer perf_branches = 0, perf_taken = 0, perf_mispredict = 0, perf_jalr = 0, perf_jal = 0, perf_btb = 0;
`endif
always @(posedge cpu_clk) begin
    if(cpu_rst_n) begin
        if(u_chip.u_cpu.INST_WB != 0) perf_instret = perf_instret + 1;
        if(u_chip.u_cpu.flush_IF_ID && u_chip.u_cpu.flush_ID_EX && !u_chip.u_cpu.stall_PC_IF) perf_redirect2 = perf_redirect2 + 1;
        else if(u_chip.u_cpu.stall_PC_IF) perf_stall = perf_stall + 1;
        else if(u_chip.u_cpu.flush_IF_ID) perf_redirect1 = perf_redirect1 + 1;
`ifdef CPU_OPT
        if(u_chip.u_cpu.opcode_EX == 7'b1100011) begin
            perf_branches = perf_branches + 1;
            if(u_chip.u_cpu.branch_res_EX) perf_taken = perf_taken + 1;
        end
        if(u_chip.u_cpu.fix_predict_EX) perf_mispredict = perf_mispredict + 1;
        if(u_chip.u_cpu.meet_jalr_EX) perf_jalr = perf_jalr + 1;
        if(u_chip.u_cpu.early_jal_ID && u_chip.u_cpu.flush_IF_ID && !u_chip.u_cpu.flush_ID_EX) perf_jal = perf_jal + 1;
        // BTB redirect that actually steers the fetch (not overridden by a stall or an older redirect)
        if(u_chip.u_cpu.btb_redirect_IF && !u_chip.u_cpu.stall_PC_IF && !u_chip.u_cpu.flush_IF_ID) perf_btb = perf_btb + 1;
`endif
    end
end

task print_perf();
    $display("PERF cycles=%0d instret=%0d cpi=%0.3f redirect2=%0d stall=%0d redirect1=%0d",
             cnt, perf_instret, (perf_instret == 0) ? 0.0 : $itor(cnt) / $itor(perf_instret),
             perf_redirect2, perf_stall, perf_redirect1);
`ifdef CPU_OPT
    $display("PERF_BRANCH branches=%0d taken=%0d mispredict=%0d jalr=%0d jal_redirect=%0d btb_redirect=%0d",
             perf_branches, perf_taken, perf_mispredict, perf_jalr, perf_jal, perf_btb);
`endif
endtask

endmodule
