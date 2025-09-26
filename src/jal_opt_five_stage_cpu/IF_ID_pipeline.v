module IF_ID_pipeline #(
    parameter INST_WIDTH = 32,
    parameter INST_ADDR_WIDTH = 32
)(
    input wire cpu_clk,
    input wire cpu_rst_n,
    input wire stall_IF_ID,
    input wire flush_IF_ID,
    input wire [INST_ADDR_WIDTH-1:0] PC_IF_ID_i,
    output reg [INST_ADDR_WIDTH-1:0] PC_IF_ID_o,
    input wire [INST_ADDR_WIDTH-1:0] PC_plus_4_IF_ID_i,
    output reg [INST_ADDR_WIDTH-1:0] PC_plus_4_IF_ID_o,
    input wire [INST_WIDTH-1:0] INST_IF_ID_i,
    output reg [INST_WIDTH-1:0] INST_IF_ID_o
);

always @(posedge cpu_clk) begin
    if(!cpu_rst_n)begin
        PC_IF_ID_o <= 0;
        PC_plus_4_IF_ID_o <= 0;
        INST_IF_ID_o <= 0;
    end else begin
        if(flush_IF_ID)begin
            PC_IF_ID_o <= 0;
            PC_plus_4_IF_ID_o <= 0;
            INST_IF_ID_o <= 0;
        end else begin
            if(stall_IF_ID)begin
                PC_IF_ID_o <= PC_IF_ID_o;
                PC_plus_4_IF_ID_o <= PC_plus_4_IF_ID_o;
                INST_IF_ID_o <= INST_IF_ID_o;
            end else begin
                PC_IF_ID_o <= PC_IF_ID_i;
                PC_plus_4_IF_ID_o <=  PC_plus_4_IF_ID_i;
                INST_IF_ID_o <= INST_IF_ID_i;        
            end
        end
        
    end
end

endmodule