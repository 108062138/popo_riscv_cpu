module five_stage_cpu #(
    parameter INST_WIDTH = 32,
    parameter INST_ADDR_WIDTH = 7,
    parameter DATA_WIDTH = 32,
    parameter DATA_ADDR_WIDTH = 7
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

// just a naive fsm to make sure line are connected properly

localparam idle = 0;
localparam fetch = 1;
localparam done = 2;
localparam cnt_width = 5;
reg [1:0] state, n_state;
reg [cnt_width-1:0] cnt, n_cnt;

always@(*)begin
    inst_we_core2mem = 0;
    inst_request_core2mem = (state == fetch && cnt[1:0] == 2'b11) ? 1 : 0;
    inst_addr_core2mem = {{INST_ADDR_WIDTH-cnt_width{1'b0}}, cnt};
end

always@(*)begin
    n_state = state;
    n_cnt = cnt;
    if(state == fetch)
    if(state == fetch) n_cnt = cnt + 1;
    else n_cnt = 0;
    case(state)
        idle: begin
            if(start) n_state = fetch;
            else n_state = idle;
        end
        fetch: begin
            if(cnt == 5'b11111) n_state = done;
            else n_state = fetch;
        end
        done: n_state = done;
        default: n_state = idle;
    endcase
end
always@(posedge clk)begin
    if(!rst_n) begin
        state <= idle;
        cnt <= 0;
    end else begin
        state <= n_state;
        cnt <= n_cnt;
    end
end

endmodule