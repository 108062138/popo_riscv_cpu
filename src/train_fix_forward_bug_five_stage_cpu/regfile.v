`include "riscv_defs.vh"

module regfile #(
    parameter INIT_STYLE = 2,
    parameter REGISTER_WIDTH = 32,
    parameter REGISTER_ADDR_WIDTH = 5
)(
    input cpu_clk,
    input cpu_rst_n,
    input wire [2:0] forward_detect_rs1,
    input wire [2:0] forward_detect_rs2,
    input wire [REGISTER_ADDR_WIDTH-1:0] rs1_addr,
    input wire [REGISTER_ADDR_WIDTH-1:0] rs2_addr,
    output reg [REGISTER_WIDTH-1:0] rs1_data,
    output reg [REGISTER_WIDTH-1:0] rs2_data,
    input wire [REGISTER_ADDR_WIDTH-1:0] wd_addr,
    input wire we,
    input wire [REGISTER_WIDTH-1:0] wd_data
);

reg [REGISTER_WIDTH-1:0] rf [0:2**REGISTER_ADDR_WIDTH-1];
integer i;

always@(posedge cpu_clk)begin
    if(!cpu_rst_n)begin
        if(INIT_STYLE==0) for(i=0;i<2**REGISTER_ADDR_WIDTH;i=i+1) rf[i] <= i;
        else if(INIT_STYLE==1) for(i=0;i<2**REGISTER_ADDR_WIDTH;i=i+1) rf[i] <= i*3;
        else for(i=0;i<2**REGISTER_ADDR_WIDTH;i=i+1) rf[i] <= 0;
    end else begin
        if(we && wd_addr!=0) begin
            rf[wd_addr] <= wd_data;
            // $display("write reg[%d] <= %d in hexa:%h", wd_addr, $signed(wd_data), wd_data);
        end
        rf[0] <= 0;
    end
end

always @(*) begin
    rs1_data = rf[rs1_addr];
    if(forward_detect_rs1[`FORWARD_COLLISION_IN_ID]) rs1_data = wd_data;
    rs2_data = rf[rs2_addr];
    if(forward_detect_rs2[`FORWARD_COLLISION_IN_ID]) rs2_data = wd_data;
end

endmodule