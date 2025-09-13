module PC_datapath #(
    parameter INST_WIDTH = 32,
    parameter INST_ADDR_WIDTH = 32
)(
    input wire PC_take_branch,
    input wire PC_take_jalr,
    input wire [INST_ADDR_WIDTH-1:0] PC_for_normal_PC_plus_4,
    input wire [INST_ADDR_WIDTH-1:0] PC_for_normal_branch,
    input wire [INST_ADDR_WIDTH-1:0] PC_for_jalr,
    output reg [INST_ADDR_WIDTH-1:0] n_PC
);

always @(*) begin
    if(PC_take_branch)begin // take branch
        if(PC_take_jalr)begin // use register + offset
            n_PC = PC_for_jalr;
        end else begin // use PC+offset
            n_PC = PC_for_normal_branch;
        end
    end else begin
        n_PC = PC_for_normal_PC_plus_4;
    end
end

endmodule