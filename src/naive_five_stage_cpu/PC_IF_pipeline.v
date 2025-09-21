module PC_IF_pipeline #(
    parameter INST_WIDTH = 32,
    parameter INST_ADDR_WIDTH = 32
)(
    input wire cpu_clk,
    input wire cpu_rst_n,
    input wire stall_PC_IF,
    input wire [INST_ADDR_WIDTH-1:0] n_PC,
    output reg [INST_ADDR_WIDTH-1:0] PC
);
always @(posedge cpu_clk) begin
    if(!cpu_rst_n)begin
        PC <= 0;
    end else begin
        if(stall_PC_IF)
            PC <= PC;
        else
            PC <= n_PC;
    end
end
endmodule