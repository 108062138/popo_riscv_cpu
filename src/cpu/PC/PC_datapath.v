module PC_datapath #(
    parameter INST_WIDTH = 32,
    parameter INST_ADDR_WIDTH = 32
)(
    input wire predict_branch_taken_ID,
    input wire early_jal_ID,
    input wire fix_predict_EX,
    input wire meet_jalr_EX,

    input wire [INST_ADDR_WIDTH-1:0] predict_branch_taken_PC_ID,
    input wire [INST_ADDR_WIDTH-1:0] early_jal_PC_ID,
    input wire [INST_ADDR_WIDTH-1:0] PC_plus_4_normal,
    input wire [INST_ADDR_WIDTH-1:0] meet_jalr_PC_EX,
    input wire [INST_ADDR_WIDTH-1:0] fix_predict_PC_EX,
    
    output reg [INST_ADDR_WIDTH-1:0] n_PC
);

always @(*) begin
    if(fix_predict_EX)begin
        n_PC = fix_predict_PC_EX;
    end else if(meet_jalr_EX)begin
        n_PC = meet_jalr_PC_EX;
    end else if(early_jal_ID)begin
        n_PC = early_jal_PC_ID;
    end else if(predict_branch_taken_ID)begin
        n_PC = predict_branch_taken_PC_ID;
    end else begin
        n_PC = PC_plus_4_normal;
    end
end

endmodule