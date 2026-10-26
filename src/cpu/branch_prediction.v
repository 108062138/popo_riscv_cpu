`include "riscv_defs.vh"

// Branch prediction for the five-stage CPU.
//
// Direction predictor (PREDICTOR_MODE):
//   0 STATIC_NT   : always predict not taken
//   1 GLOBAL_2BIT : one 2-bit saturating counter shared by every branch
//   2 BHT         : table of 2^BHT_INDEX_BITS 2-bit counters indexed by PC[BHT_INDEX_BITS+1:2]
//
// Target prediction (BTB_ENABLE):
//   0 : no BTB. jal and predicted-taken branches redirect from ID (1 lost cycle).
//   1 : direct-mapped BTB looked up in IF with the fetch PC. On a hit for a jal,
//       or a branch the direction predictor calls taken, IF fetches the target
//       next, so no cycle is lost. Entries are written in ID, where the target
//       (PC + imm) is known. Tags are the full word address, so a hit is always
//       for the same instruction and its target is always right.
//
// The direction guess is carried with the branch (IF -> ID -> EX). EX compares
// the real outcome with that guess and redirects on a mismatch (2 lost cycles).
module branch_prediction #(
    parameter INST_ADDR_WIDTH = 32,
    parameter PREDICTOR_MODE = 2,
    parameter BHT_INDEX_BITS = 4,
    parameter BTB_ENABLE = 1,
    parameter BTB_INDEX_BITS = 4
)(
    input wire cpu_clk,
    input wire cpu_rst_n,
    // pipeline is moving (no memory freeze); counters only update when set
    input wire update_en,

    // IF: BTB lookup with the fetch PC
    input wire [INST_ADDR_WIDTH-1:0] PC_IF,
    output reg btb_redirect_IF,
    output reg [INST_ADDR_WIDTH-1:0] btb_target_IF,

    // ID
    input wire [6:0] opcode_ID,
    input wire [INST_ADDR_WIDTH-1:0] PC_ID,
    input wire [INST_ADDR_WIDTH-1:0] imm_ID,
    input wire btb_redirect_ID,                 // this instruction was already redirected in IF
    output reg guess_taken_ID,                  // direction guess for the branch in ID (carried to EX)
    output reg predict_branch_taken_ID,         // branch in ID needs a 1-cycle redirect from ID
    output reg [INST_ADDR_WIDTH-1:0] predict_branch_taken_PC_ID,

    // EX
    input wire [6:0] opcode_EX,
    input wire [INST_ADDR_WIDTH-1:0] PC_plus_4_EX,
    input wire [INST_ADDR_WIDTH-1:0] PC_EX,
    input wire [INST_ADDR_WIDTH-1:0] imm_EX,
    input wire guess_taken_EX,
    input wire branch_res_EX,
    output reg fix_predict_EX,
    output reg [INST_ADDR_WIDTH-1:0] fix_predict_PC_EX
);

localparam STATIC_NT = 0;
localparam GLOBAL_2BIT = 1;
localparam BHT = 2;

localparam BHT_ENTRIES = 1 << BHT_INDEX_BITS;
localparam BTB_ENTRIES = 1 << BTB_INDEX_BITS;
localparam TAG_WIDTH = INST_ADDR_WIDTH - 2;

// 2-bit counters: 0 strong not taken, 1 weak not taken, 2 weak taken, 3 strong taken
localparam [1:0] COUNTER_INIT = 2'd1;

reg [1:0] counter [0:BHT_ENTRIES-1];

function [BHT_INDEX_BITS-1:0] bht_index(input [INST_ADDR_WIDTH-1:0] pc);
    bht_index = (PREDICTOR_MODE == BHT) ? pc[BHT_INDEX_BITS+1:2] : {BHT_INDEX_BITS{1'b0}};
endfunction

function counter_says_taken(input [INST_ADDR_WIDTH-1:0] pc);
    counter_says_taken = (PREDICTOR_MODE != STATIC_NT) && counter[bht_index(pc)][1];
endfunction

// ---------------- BTB ----------------
reg btb_valid [0:BTB_ENTRIES-1];
reg btb_is_jal [0:BTB_ENTRIES-1];
reg [TAG_WIDTH-1:0] btb_tag [0:BTB_ENTRIES-1];
reg [INST_ADDR_WIDTH-1:0] btb_target [0:BTB_ENTRIES-1];

wire [BTB_INDEX_BITS-1:0] btb_idx_IF = PC_IF[BTB_INDEX_BITS+1:2];
wire [BTB_INDEX_BITS-1:0] btb_idx_ID = PC_ID[BTB_INDEX_BITS+1:2];
wire btb_hit_IF = BTB_ENABLE && btb_valid[btb_idx_IF] && (btb_tag[btb_idx_IF] == PC_IF[INST_ADDR_WIDTH-1:2]);

always @(*) begin
    btb_redirect_IF = btb_hit_IF && (btb_is_jal[btb_idx_IF] || counter_says_taken(PC_IF));
    btb_target_IF = btb_target[btb_idx_IF];
end

// ---------------- ID ----------------
always @(*) begin
    guess_taken_ID = 0;
    predict_branch_taken_ID = 0;
    predict_branch_taken_PC_ID = PC_ID + imm_ID;
    if(opcode_ID == `BRANCH) begin
        if(btb_redirect_ID) begin
            guess_taken_ID = 1;                 // IF already fetched the target
        end else begin
            guess_taken_ID = counter_says_taken(PC_ID);
            predict_branch_taken_ID = guess_taken_ID;
        end
    end
end

// ---------------- EX ----------------
wire branch_EX = (opcode_EX == `BRANCH);
always @(*) begin
    fix_predict_EX = branch_EX && (branch_res_EX != guess_taken_EX);
    fix_predict_PC_EX = branch_res_EX ? (PC_EX + imm_EX) : PC_plus_4_EX;
end

// ---------------- state update ----------------
integer i;
wire [BHT_INDEX_BITS-1:0] bht_idx_EX = bht_index(PC_EX);
always @(posedge cpu_clk) begin
    if(!cpu_rst_n) begin
        for(i = 0; i < BHT_ENTRIES; i = i + 1) counter[i] <= COUNTER_INIT;
        for(i = 0; i < BTB_ENTRIES; i = i + 1) begin
            btb_valid[i] <= 0;
            btb_is_jal[i] <= 0;
            btb_tag[i] <= 0;
            btb_target[i] <= 0;
        end
    end else if(update_en) begin
        if(branch_EX) begin
            if(branch_res_EX && counter[bht_idx_EX] != 2'd3) counter[bht_idx_EX] <= counter[bht_idx_EX] + 1;
            if(!branch_res_EX && counter[bht_idx_EX] != 2'd0) counter[bht_idx_EX] <= counter[bht_idx_EX] - 1;
        end
        // the target of jal / branch is known in ID: remember it for the next fetch of this PC
        if(BTB_ENABLE && (opcode_ID == `JAL || opcode_ID == `BRANCH)) begin
            btb_valid[btb_idx_ID] <= 1;
            btb_is_jal[btb_idx_ID] <= (opcode_ID == `JAL);
            btb_tag[btb_idx_ID] <= PC_ID[INST_ADDR_WIDTH-1:2];
            btb_target[btb_idx_ID] <= PC_ID + imm_ID;
        end
    end
end

endmodule
