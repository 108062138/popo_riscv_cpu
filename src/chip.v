module chip #(
    parameter INST_WIDTH = 32,
    parameter INST_ADDR_WIDTH = 7
)(
    input wire clk,
    input wire rst_n,
    input wire start,
    output wire [INST_WIDTH-1:0] fetch_inst,
    output wire valid
);

// simple fsm
localparam idle = 0;
localparam fetch = 1;
localparam done = 2;

reg [INST_ADDR_WIDTH-1:0] inst_addr, n_inst_addr;
reg snd_req;
reg [1:0] state, n_state;

always@(*)begin
    n_state = state;
    n_inst_addr = inst_addr;
    if(state == idle)begin
        if(start) n_state = fetch;
    end else if(start==fetch)begin
        if(inst_addr == 4'd15) n_state = done;
    end else if(state == done) n_state = idle;

    if(state == fetch)begin
        n_inst_addr = inst_addr + 1;
    end
end

always@(*)begin
    if(state == fetch && inst_addr[1:0] == 2'b11) snd_req = 1;
    else snd_req = 0;
end

always@(posedge clk)begin
    if(!rst_n) begin
        state <= idle;
        inst_addr <= 0;
    end else begin
        state <= n_state;
        inst_addr <= n_inst_addr;
    end
end

inst_mem #(
    .INST_WIDTH(INST_WIDTH),
    .INST_ADDR_WIDTH(INST_ADDR_WIDTH)
) u_inst_mem (
    .clk(clk),
    .rst_n(rst_n),
    .request(snd_req), // always request instruction
    .addr(inst_addr), // always read from address 0
    .valid(valid),
    .fetched_inst(fetch_inst)
);

always@(posedge clk)begin
    if(valid) $display("fetched inst: %h", fetch_inst);
end

endmodule