// module five_stage_cpu #(
//     parameter INST_WIDTH = 32,
//     parameter INST_ADDR_WIDTH = 7,
//     parameter DATA_WIDTH = 32,
//     parameter DATA_ADDR_WIDTH = 7
// )(
//     input wire clk,
//     input wire rst_n,
//     input wire start,
//     // to inst memory
//     output reg inst_we_core2mem,
//     output reg inst_request_core2mem,
//     output reg [INST_ADDR_WIDTH-1:0] inst_addr_core2mem,
//     input wire inst_valid_mem2core,
//     input wire [INST_WIDTH-1:0] inst_mem2core
//     // to data memory (not implemented yet)
// );

// // just a naive fsm to make sure line are connected properly

// localparam idle = 0;
// localparam fetch = 1;
// localparam done = 2;
// localparam cnt_width = 5;
// reg [1:0] state, n_state;
// reg [cnt_width-1:0] cnt, n_cnt;

// always@(*)begin
//     inst_we_core2mem = 0;
//     inst_request_core2mem = (state == fetch && cnt[1:0] == 2'b11) ? 1 : 0;
//     inst_addr_core2mem = {{INST_ADDR_WIDTH-cnt_width{1'b0}}, cnt};
// end

// always@(*)begin
//     n_state = state;
//     n_cnt = cnt;
//     if(state == fetch)
//     if(state == fetch) n_cnt = cnt + 1;
//     else n_cnt = 0;
//     case(state)
//         idle: begin
//             if(start) n_state = fetch;
//             else n_state = idle;
//         end
//         fetch: begin
//             if(cnt == 5'b11111) n_state = done;
//             else n_state = fetch;
//         end
//         done: n_state = done;
//         default: n_state = idle;
//     endcase
// end
// always@(posedge clk)begin
//     if(!rst_n) begin
//         state <= idle;
//         cnt <= 0;
//     end else begin
//         state <= n_state;
//         cnt <= n_cnt;
//     end
// end

// endmodule


module five_stage_cpu #(
    parameter INST_WIDTH = 32,
    parameter INST_ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32,
    parameter DATA_ADDR_WIDTH = 32
)(
    input wire clk,
    input wire rst_n,
    input wire start,
    // to inst memory
    output reg inst_we_core2mem,
    output reg inst_request_core2mem,
    output reg [INST_ADDR_WIDTH-1:0] inst_addr_core2mem,
    input wire inst_valid_mem2core,
    input wire [INST_WIDTH-1:0] inst_mem2core
    // to data memory (not implemented yet)
);

wire stall_PC;
wire branch_taken;
wire branch_source;
wire [INST_ADDR_WIDTH-1:0] branch_jalr_target;
wire [INST_ADDR_WIDTH-1:0] branch_jal_beq_bne_target;
wire [INST_ADDR_WIDTH-1:0] PC_from_PC;

wire [INST_WIDTH-1:0] IF_inst_o;
wire [INST_ADDR_WIDTH-1:0] IF_PC_o;
wire [INST_ADDR_WIDTH-1:0] IF_PC_plus_4_o;

assign inst_addr_core2mem = PC_from_PC >> 2; // PC is byte address, but inst mem is word address

PC_handler #(
    .INST_ADDR_WIDTH(INST_ADDR_WIDTH)
) u_PC_handler(
    .clk(clk),
    .rst_n(rst_n),
    .start(start),
    .stall_PC(stall_PC), // for now, I haven't figure out
    .branch_taken(branch_taken),
    .branch_source(branch_source),
    .branch_jalr_target(branch_jalr_target),
    .branch_jal_beq_bne_target(branch_jal_beq_bne_target),
    .IF_PC_plus_4(IF_PC_plus_4_o),
    .inst_we_core2mem(inst_we_core2mem),
    .inst_request_core2mem(inst_request_core2mem),
    .PC(PC_from_PC)
);

IF_datapath #(
    .INST_WIDTH(INST_WIDTH),
    .INST_ADDR_WIDTH(INST_ADDR_WIDTH)
) u_IF_datapath(
    .IF_inst_i(inst_mem2core),
    .IF_PC_i(PC_from_PC),
    .IF_inst_o(IF_inst_o),
    .IF_PC_o(IF_PC_o),
    .IF_PC_plus_4_o(IF_PC_plus_4_o)
);

// naive IF/ID pipeline register
reg [INST_WIDTH-1:0] inst_IF_ID;
reg [INST_ADDR_WIDTH-1:0] PC_IF_ID;
always@(posedge clk)begin
    inst_IF_ID <= IF_inst_o;
    PC_IF_ID <= IF_PC_o;
end

branch_handler #(
    .INST_WIDTH(INST_WIDTH),
    .INST_ADDR_WIDTH(INST_ADDR_WIDTH)
) u_branch_handler(
    .clk(clk),
    .rst_n(rst_n),
    .start(start),
    .inst_IF_ID(inst_IF_ID),
    .PC_IF_ID(PC_IF_ID),
    .branch_taken(branch_taken),
    .branch_source(branch_source),
    .branch_jalr_target(branch_jalr_target),
    .branch_jal_beq_bne_target(branch_jal_beq_bne_target)
);

endmodule