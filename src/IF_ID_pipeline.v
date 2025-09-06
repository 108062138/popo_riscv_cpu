module IF_ID_pipeline #(
    parameter INST_WIDTH = 32,
    parameter INST_ADDR_WIDTH = 32
)(
    input clk,
    input rst_n,
    input start,
    input stall_IF_ID,
    input flush_IF_ID,
    input [INST_WIDTH-1:0] IF_inst_o,
    input [INST_ADDR_WIDTH-1:0] pre_PC_from_PC,
    output reg [INST_WIDTH-1:0] inst_IF_ID,
    output reg [INST_ADDR_WIDTH-1:0] PC_IF_ID
);

reg [INST_WIDTH-1:0] n_inst_IF_ID;
reg [INST_ADDR_WIDTH-1:0] n_PC_IF_ID;

always@(*)begin
    n_inst_IF_ID = inst_IF_ID;
    n_PC_IF_ID = PC_IF_ID;
    if(start)begin
        if(stall_IF_ID)begin
            n_inst_IF_ID = inst_IF_ID;
            n_PC_IF_ID = PC_IF_ID;
        end else if(flush_IF_ID)begin
            n_inst_IF_ID = 0;
            n_PC_IF_ID = 0;
        end else begin
            n_inst_IF_ID = IF_inst_o;
            n_PC_IF_ID = pre_PC_from_PC;
        end
    end
end

always@(posedge clk)begin
    if(!rst_n)begin
        inst_IF_ID <= 0;
        PC_IF_ID <= 0;
    end else begin
        inst_IF_ID <= n_inst_IF_ID;
        PC_IF_ID <= n_PC_IF_ID;
    end
end
endmodule