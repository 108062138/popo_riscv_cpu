module branch_handler #(
    parameter REGISTER_WIDTH = 32,
    parameter INST_WIDTH = 32,
    parameter INST_ADDR_WIDTH = 32
)(
    input wire clk, // this port is  used to simulated following pipeline. Need to be removed after following pipeline implementation
    input wire rst_n, // same as clk
    input wire start, // same as clk
    // input wire [REGISTER_WIDTH-1:0] rs1_data, // since we haven't implemented regfile yet, we can't get rs1 and rs2
    // input wire [REGISTER_WIDTH-1:0] rs2_data, // since we haven't implemented regfile yet, we can't get rs1 and rs2
    input wire [INST_WIDTH-1:0] inst_IF_ID,
    input wire [INST_ADDR_WIDTH-1:0] PC_IF_ID,
    output reg branch_taken, // 0-> not take, so PC+4; 1-> take, so branch_target
    output reg branch_source, // 0-> from pc_if_id+offset, 1: s2 + inst_if_id_offset
    output reg [INST_WIDTH-1:0] branch_jalr_target,
    output reg [INST_WIDTH-1:0] branch_jal_beq_bne_target
);

wire [7-1:0] opcode;
wire [3-1:0] funct3;
wire [32-1:0] imm_for_jal, imm_for_jalr, imm_for_beq;
wire is_branch_inst;

localparam idle = 0;
localparam process = 1;
reg [1:0] state, n_state;
reg [3:0] cnt;

assign opcode = inst_IF_ID[6:0];
assign funct3 = inst_IF_ID[14:12];
assign is_branch_inst = (opcode[6:5] == 2'b11)? 1'b1: 1'b0; // jal, jalr, beq, bne, blt, bge, bltu, bgeu 
assign imm_for_jal = {{12{inst_IF_ID[31]}}, inst_IF_ID[19:12], inst_IF_ID[20], inst_IF_ID[30:21], 1'b0};
assign imm_for_jalr = {{20{inst_IF_ID[31]}}, inst_IF_ID[31:20]};
assign imm_for_beq = {/*{20{inst_IF_ID[31]}},*/ inst_IF_ID[7], inst_IF_ID[30:25], inst_IF_ID[11:8], 1'b0};

always@(*)begin
    branch_taken = 0;
    branch_source = 0;
    branch_jalr_target = 0;
    branch_jal_beq_bne_target = 0;

    if(state == process)begin
        if(is_branch_inst)begin
            if(inst_IF_ID[2])begin
                // unconditinal branch
                branch_taken = 1;
                if(inst_IF_ID[3])begin // jal
                    branch_source = 0;
                    branch_jal_beq_bne_target = PC_IF_ID + {{12{inst_IF_ID[31]}}, inst_IF_ID[19:12], inst_IF_ID[20], inst_IF_ID[30:21], 1'b0};
                end else begin // jalr
                    branch_source = 1;
                    branch_jalr_target = 4/*rs1*/ + {{20{inst_IF_ID[31]}}, inst_IF_ID[31:20]};
                end
            end else begin
                branch_source = 0;
                branch_jal_beq_bne_target = PC_IF_ID + {{20{inst_IF_ID[31]}}, inst_IF_ID[7], inst_IF_ID[30:25], inst_IF_ID[11:8], 1'b0};
                if(cnt[0] == 1)begin
                    branch_taken = 1;
                end else begin
                    branch_taken = 0;
                end
            end
        end
    end
end

always@(*)begin
    if(state == idle)begin
        if(start) n_state = process;
        else n_state = idle;
    end else begin
        if(!start) n_state = idle;
        else n_state = process;
    end
end
always@(posedge clk)begin
    if(!rst_n) begin
        state <= idle;
        cnt <= 0;
    end else begin
        state <= n_state;
        cnt <= cnt + 1;
    end
end
endmodule