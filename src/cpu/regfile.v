module regfile #(
    parameter REGISTER_WIDTH = 32,
    parameter REG_ADDR_WIDTH = 5
)(
    input clk,
    input rst_n,
    input start,
    input wire [REG_ADDR_WIDTH-1:0] rs1_addr,
    input wire [REG_ADDR_WIDTH-1:0] rs2_addr,
    output wire [REGISTER_WIDTH-1:0] rs1_data,
    output wire [REGISTER_WIDTH-1:0] rs2_data,
    input wire [REG_ADDR_WIDTH-1:0] rd_addr,
    input wire we,
    input wire [REGISTER_WIDTH-1:0] rd_data
);

reg [REGISTER_WIDTH-1:0] rf [0:2**REG_ADDR_WIDTH-1];
integer i;

always@(posedge clk)begin
    if(!rst_n)begin
        for(i=0;i<2**REG_ADDR_WIDTH;i=i+1) rf[i] <= 0;
    end else begin
        if(start && we)begin
            rf[rd_addr] <= rd_data;
        end else begin
            for(i=0;i<2**REG_ADDR_WIDTH;i=i+1) rf[i] <= rf[i];
        end
    end
end
assign rs1_data = rf[rs1_addr];
assign rs2_data = rf[rs2_addr];
endmodule