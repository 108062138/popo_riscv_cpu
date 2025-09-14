module regfile #(
    parameter INIT_STYLE = 2,
    parameter REGISTER_WIDTH = 32,
    parameter REGISTER_ADDR_WIDTH = 5
)(
    input cpu_clk,
    input cpu_rst_n,
    input wire [REGISTER_ADDR_WIDTH-1:0] rs1_addr,
    input wire [REGISTER_ADDR_WIDTH-1:0] rs2_addr,
    output wire [REGISTER_WIDTH-1:0] rs1_data,
    output wire [REGISTER_WIDTH-1:0] rs2_data,
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
        if(we && wd_addr!=0) rf[wd_addr] <= wd_data;
        rf[0] <= 0;
    end
end
assign rs1_data = rf[rs1_addr];
assign rs2_data = rf[rs2_addr];
endmodule