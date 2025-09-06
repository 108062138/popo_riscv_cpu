module lfsr_6 #(
    parameter LFSR_WIDTH = 6,
    parameter INIT_SEED = 6'b010110
)(
    input wire clk,
    input wire rst_n,
    output reg lfsr_out
);

reg [LFSR_WIDTH-1:0] lfsr_reg, n_lfsr_reg;
integer i;
always@(*)begin
    lfsr_out = lfsr_reg[LFSR_WIDTH-1];
    for(i=1;i<LFSR_WIDTH;i=i+1) begin
        n_lfsr_reg[i] = lfsr_reg[i-1];
    end
    n_lfsr_reg[0] = lfsr_reg[LFSR_WIDTH-1] ^ lfsr_reg[LFSR_WIDTH-3];
end

always@(posedge clk)begin
    if(!rst_n) lfsr_reg <= INIT_SEED;
    else lfsr_reg <= n_lfsr_reg;
end

endmodule

module lfsr_4 #(
    parameter LFSR_WIDTH = 4,
    parameter INIT_SEED = 4'b1010
)(
    input wire clk,
    input wire rst_n,
    output reg lfsr_out
);
reg [LFSR_WIDTH-1:0] lfsr_reg, n_lfsr_reg;
integer i;
always@(*)begin
    lfsr_out = lfsr_reg[LFSR_WIDTH-1];
    for(i=1;i<LFSR_WIDTH;i=i+1) begin
        n_lfsr_reg[i] = lfsr_reg[i-1];
    end
    n_lfsr_reg[0] = lfsr_reg[LFSR_WIDTH-1] ^ lfsr_reg[LFSR_WIDTH-2];
end
always@(posedge clk)begin
    if(!rst_n) lfsr_reg <= INIT_SEED;
    else lfsr_reg <= n_lfsr_reg;
end
endmodule