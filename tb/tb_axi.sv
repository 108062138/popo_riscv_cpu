module tb_axi();

parameter CPU_CYC = 10;
parameter SYS_CYC = 40;
parameter max_cyc = 200;
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
    $dumpfile("tb_axi.vcd");
    $dumpvars(0, tb_axi);
end

// main entry
initial begin
    reset_all();
    clear_dma_setting();
    write_only(8'd23);
end

parameter ADDR_WIDTH = 32;
parameter READ_CHANNEL_WIDTH = 32;
parameter READ_BURST_LEN = 8;
parameter WRITE_CHANNEL_WIDTH = 32;
parameter WRITE_BURST_LEN = 8;
parameter ASYNCFIFO_ADDR_WIDTH = 3;

// page fault happend
reg dma_page_fault_happen;
wire dma_page_fault_done;
reg [ADDR_WIDTH-1:0] dma_page_fault_addr;
reg [READ_BURST_LEN-1:0] dma_page_fault_burst_len;
// cache flush happen
reg dma_write_back_happen;
wire dma_write_back_done;
reg [ADDR_WIDTH-1:0] dma_write_back_addr;
reg [WRITE_BURST_LEN-1:0] dma_write_back_burst_len;

event reset_done;
task reset_all();
fork
    begin
        sys_rst_n = 1; repeat(2)@(negedge sys_clk);
        sys_rst_n = 0; repeat(2)@(negedge sys_clk);
        @(negedge sys_clk); 
        sys_rst_n = 1;
    end
    begin
        cpu_rst_n = 1; repeat(2)@(negedge cpu_clk);
        cpu_rst_n = 0; repeat(2)@(negedge cpu_clk);
        @(negedge cpu_clk); 
        cpu_rst_n = 1;
    end
join
-> reset_done;
endtask

task clear_dma_setting();
    begin
        dma_page_fault_happen = 0;
        dma_page_fault_addr = 0;
        dma_page_fault_burst_len = 0;
        dma_write_back_happen = 0;
        dma_write_back_addr = 0;
        dma_write_back_burst_len = 0;
        repeat(2)@(negedge cpu_clk);
    end
endtask

event write_only_done;
task write_only();
input [WRITE_BURST_LEN-1:0] number_of_write;
fork
    begin
        dma_write_back_addr = 30;
        dma_write_back_burst_len = number_of_write - 1;
        dma_write_back_happen = 1;
        repeat(10)@(negedge cpu_clk);
    end
join
-> write_only_done;
endtask
endmodule