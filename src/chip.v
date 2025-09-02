// module chip #(
//     parameter INST_WIDTH = 32,
//     parameter INST_ADDR_WIDTH = 7
// )(
//     input wire clk,
//     input wire rst_n,
//     input wire start,
//     output wire [INST_WIDTH-1:0] fetch_inst,
//     output wire valid
// );

// // simple fsm
// localparam idle = 0;
// localparam fetch = 1;
// localparam done = 2;

// reg [INST_ADDR_WIDTH-1:0] inst_addr, n_inst_addr;
// reg snd_req;
// reg [1:0] state, n_state;

// always@(*)begin
//     n_state = state;
//     n_inst_addr = inst_addr;
//     if(state == idle)begin
//         if(start) n_state = fetch;
//     end else if(start==fetch)begin
//         if(inst_addr == 4'd15) n_state = done;
//     end else if(state == done) n_state = idle;

//     if(state == fetch)begin
//         n_inst_addr = inst_addr + 1;
//     end
// end

// always@(*)begin
//     if(state == fetch && inst_addr[1:0] == 2'b11) snd_req = 1;
//     else snd_req = 0;
// end

// always@(posedge clk)begin
//     if(!rst_n) begin
//         state <= idle;
//         inst_addr <= 0;
//     end else begin
//         state <= n_state;
//         inst_addr <= n_inst_addr;
//     end
// end

// inst_mem #(
//     .INST_WIDTH(INST_WIDTH),
//     .INST_ADDR_WIDTH(INST_ADDR_WIDTH)
// ) u_inst_mem (
//     .clk(clk),
//     .rst_n(rst_n),
//     .request(snd_req), // always request instruction
//     .addr(inst_addr), // always read from address 0
//     .valid(valid),
//     .fetched_inst(fetch_inst)
// );

// always@(posedge clk)begin
//     if(valid) $display("fetched inst: %h", fetch_inst);
// end

// endmodule


module chip #(
    parameter INST_WIDTH = 32,
    parameter INST_ADDR_WIDTH = 7,
    parameter DATA_WIDTH = 32,
    parameter DATA_ADDR_WIDTH = 7
)(
    input wire clk,
    input wire rst_n,
    input wire start,
    output wire [INST_WIDTH-1:0] fetch_inst,
    output wire inst_valid,
    output wire [DATA_WIDTH-1:0] fetch_data,
    output wire data_valid
);
wire inst_we_core2mem; // not used, for we should not overwrite inst. mem
wire inst_request_core2mem;
wire [INST_ADDR_WIDTH-1:0] inst_addr_core2mem;
wire [INST_WIDTH-1:0] inst_core2mem; // not used, for we should not overwrite inst. mem
wire [INST_WIDTH-1:0] inst_mem2core;

assign fetch_data = 0; // not implemented yet
assign data_valid = 0; // not implemented yet

assign inst_mem2core = fetch_inst;

memory_interface #(
    .INIT_BY(1),
    .CONTENT_WIDTH(INST_WIDTH),
    .CONTENT_ADDR_WIDTH(INST_ADDR_WIDTH)
) u_inst_mem(
    .clk(clk),
    .rst_n(rst_n),
    .we(1'b0),
    .request(inst_request_core2mem),
    .addr(inst_addr_core2mem),
    .data_i(0),
    .valid(inst_valid),
    .data_o(fetch_inst)
);

five_stage_cpu #(
    .INST_WIDTH(INST_WIDTH),
    .INST_ADDR_WIDTH(INST_ADDR_WIDTH),
    .DATA_WIDTH(DATA_WIDTH),
    .DATA_ADDR_WIDTH(DATA_ADDR_WIDTH)
) u_five_stage_cpu(
    .clk(clk),
    .rst_n(rst_n),
    .start(start),
    .inst_we_core2mem(inst_we_core2mem),
    .inst_request_core2mem(inst_request_core2mem),
    .inst_addr_core2mem(inst_addr_core2mem),
    .inst_valid_mem2core(inst_valid),
    .inst_mem2core(inst_mem2core)
);

// debuger
reg [10-1:0] cnt, n_cnt;
always@(*)begin
    n_cnt = cnt + 1;
end
always@(posedge clk)begin
    if(!rst_n) cnt <= 0;
    else cnt <= n_cnt;
end
always@(posedge clk)begin
    // demo status
    $display("cycle: %d, inst_addr: %d, inst: %h", cnt, inst_addr_core2mem, fetch_inst);
end
endmodule