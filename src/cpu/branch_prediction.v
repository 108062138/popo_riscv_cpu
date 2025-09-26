`include "riscv_defs.vh"

module branch_prediction #(
    parameter INST_WIDTH = 32,
    parameter INST_ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32,
    parameter DATA_ADDR_WIDTH = 32,
    parameter REGISTER_WIDTH = 32,
    parameter REGISTER_ADDR_WIDTH = 5
)(
    input wire cpu_clk,
    input wire cpu_rst_n,
    input wire [6:0] opcode_ID,
    input wire [6:0] opcode_EX,
    input wire [INST_ADDR_WIDTH-1:0] PC_plus_4_ID,
    input wire [INST_ADDR_WIDTH-1:0] PC_ID,
    input wire [INST_ADDR_WIDTH-1:0] imm_ID,

    input wire [INST_ADDR_WIDTH-1:0] PC_plus_4_EX,
    input wire [INST_ADDR_WIDTH-1:0] PC_EX,
    input wire [INST_ADDR_WIDTH-1:0] imm_EX,

    input wire branch_res_EX,

    output reg predict_branch_taken_ID,
    output reg [INST_ADDR_WIDTH-1:0] predict_branch_taken_PC_ID,
    output reg fix_predict_EX,
    output reg [INST_ADDR_WIDTH-1:0] fix_predict_PC_EX
);

localparam strong_taken = 2'b00;
localparam weak_taken = 2'b01;
localparam weak_not_taken = 2'b10;
localparam strong_not_taken = 2'b11;
reg [2:0] prediction_res;
reg [32-1:0] num_fault, n_num_fault;
reg [1:0] saturate_state, n_saturate_state;

always @(*) begin
    predict_branch_taken_ID = 0;
    predict_branch_taken_PC_ID = 0;
    if(opcode_ID==`BRANCH && ((saturate_state==strong_taken) || (saturate_state==weak_taken)))begin
        predict_branch_taken_ID = 1;
        predict_branch_taken_PC_ID = PC_ID + imm_ID;
    end
    fix_predict_EX = 0;
    fix_predict_PC_EX = 0;
    if(opcode_EX==`BRANCH)begin
        if((saturate_state==strong_taken || saturate_state==weak_taken) && !branch_res_EX)begin
            fix_predict_EX = 1;
            fix_predict_PC_EX = PC_plus_4_EX;
        end else if((saturate_state==strong_not_taken || saturate_state==weak_not_taken) && branch_res_EX) begin
            fix_predict_EX = 1;
            fix_predict_PC_EX = PC_EX + imm_EX;
        end
    end

    prediction_res = 0;
    n_num_fault = num_fault;
    if(opcode_EX==`BRANCH)begin
        if((saturate_state==strong_taken || saturate_state==weak_taken) && !branch_res_EX)begin
            prediction_res = 1;
            n_num_fault = num_fault + 1;
        end else if((saturate_state==strong_not_taken || saturate_state==weak_not_taken) && branch_res_EX) begin
            prediction_res = 2;
            n_num_fault = num_fault + 1;
        end else prediction_res = 7;
    end
end

always @(*) begin
    case (saturate_state)
        strong_taken:begin
            if(opcode_EX==`BRANCH)begin
                if(branch_res_EX) n_saturate_state = strong_taken;
                else n_saturate_state = weak_taken; 
            end else begin
                n_saturate_state = saturate_state;
            end
        end
        weak_taken:begin
            if(opcode_EX==`BRANCH)begin
                if(branch_res_EX) n_saturate_state = strong_taken;
                else n_saturate_state = weak_not_taken;
            end else begin
                n_saturate_state = saturate_state;
            end
        end
        weak_not_taken:begin
            if(opcode_EX==`BRANCH)begin
                if(branch_res_EX) n_saturate_state = weak_taken;
                else n_saturate_state = strong_not_taken;
            end else begin
                n_saturate_state = saturate_state;
            end
        end
        strong_not_taken: begin
            if(opcode_EX==`BRANCH)begin
                if(branch_res_EX) n_saturate_state = weak_not_taken;
                else n_saturate_state = strong_not_taken;
            end else begin
                n_saturate_state = saturate_state;
            end
        end
        default: n_saturate_state = saturate_state;
    endcase
end

always @(posedge cpu_clk) begin
    if(!cpu_rst_n)begin
        saturate_state <= weak_taken;
        num_fault <= 0;
    end else begin
        saturate_state <= n_saturate_state;
        num_fault <= n_num_fault;
    end
end

endmodule