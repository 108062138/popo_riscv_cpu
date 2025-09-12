`timescale 1ns/1ps

module tb_axi();

parameter CPU_CYC = 10;
parameter SYS_CYC = 40;
parameter max_cyc = 800;
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
    // @read_only_done;
    // @write_only_done;
    $display("(QQ my love)");
    $finish;
end
initial begin
    $dumpfile("tb_axi.vcd");
    $dumpvars(0, tb_axi);
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

// main entry
initial begin
    reset_all();
    clear_dma_setting();
    $display("start write only");
    write_only(.desire_addr(32'd8), .number_of_write(8'd20));
    $display("finish write only");
    clear_dma_setting();
    $display("start read only");
    read_only(.desire_addr(32'd15), .number_of_read(8'd3));
    $display("finish read only");
    clear_dma_setting();
    $display("start read only");
    read_only(.desire_addr(32'd8), .number_of_read(8'd16));
    $display("finish read only");
    clear_dma_setting();
    $display("start read only");
    read_only(.desire_addr(32'd8), .number_of_read(8'd1));
    $display("finish read only");
    clear_dma_setting();
    $display("start mix");
    write_and_read_different_place();
    $display("end mix");
    clear_dma_setting();
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

event write_and_read_different_place_done;
task write_and_read_different_place;
fork
    begin
        write_only(.desire_addr(32'd2), .number_of_write(8'd10));
    end
    begin
        read_only(.desire_addr(32'd25), .number_of_read(8'd20));
    end
join
->write_and_read_different_place_done;
endtask

event clear_dma_setting_done;
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
-> clear_dma_setting_done;
endtask

event write_only_done;
task automatic write_only();
input [WRITE_BURST_LEN-1:0] number_of_write;
input [ADDR_WIDTH-1:0] desire_addr;
fork
    begin
        dma_write_back_addr = desire_addr;
        dma_write_back_burst_len = number_of_write - 1;
        dma_write_back_happen = 1;
        while (!dma_write_back_done) @(posedge cpu_clk);
    end
join
-> write_only_done;
endtask
event read_only_done;
task automatic read_only();
input [WRITE_BURST_LEN-1:0] number_of_read;
input [ADDR_WIDTH-1:0] desire_addr;
fork
    begin
        integer tmp_cnt = 0;
        dma_page_fault_addr = desire_addr;
        dma_page_fault_burst_len = number_of_read - 1;
        dma_page_fault_happen = 1;
        while (!dma_page_fault_done)begin
            @(posedge cpu_clk);
            if(tb_axi.popo_bus.u_dma.r_state==2 || tb_axi.popo_bus.u_dma.r_state==3)begin
                if(!tb_axi.popo_bus.u_dma.master2dma_afifo_rempty)begin
                    $display("see %d at tb_axi and its addr should be %d", tb_axi.popo_bus.u_dma.master2dma_afifo_rdata, tmp_cnt + desire_addr); //tb_axi.popo_bus.u_axi_slave.u_slave_mem.mem[tmp_cnt + desire_addr],
                    tmp_cnt = tmp_cnt + 1;
                end
            end
        end
    end
join
-> read_only_done;
endtask


bus_one_dma_master_2_one_memory_slave #(
    .ADDR_WIDTH(ADDR_WIDTH),
    .READ_CHANNEL_WIDTH(READ_CHANNEL_WIDTH),
    .READ_BURST_LEN(READ_BURST_LEN),
    .WRITE_CHANNEL_WIDTH(WRITE_CHANNEL_WIDTH),
    .WRITE_BURST_LEN(WRITE_BURST_LEN),
    .ASYNCFIFO_ADDR_WIDTH(ASYNCFIFO_ADDR_WIDTH)
) popo_bus (
    .cpu_clk(cpu_clk),
    .cpu_rst_n(cpu_rst_n),
    .sys_clk(sys_clk),
    .sys_rst_n(sys_rst_n),
    // page fault happend
    .dma_page_fault_happen(dma_page_fault_happen),
    .dma_page_fault_done(dma_page_fault_done),
    .dma_page_fault_addr(dma_page_fault_addr),
    .dma_page_fault_burst_len(dma_page_fault_burst_len),
    // cache flush happend
    .dma_write_back_happen(dma_write_back_happen),
    .dma_write_back_done(dma_write_back_done),
    .dma_write_back_addr(dma_write_back_addr),
    .dma_write_back_burst_len(dma_write_back_burst_len)
);

endmodule