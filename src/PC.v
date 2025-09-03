module PC_handler #(
    parameter INST_ADDR_WIDTH = 32
)(
    input wire clk,
    input wire rst_n,
    input wire start, // used to interrupt the cpu
    input wire stall_PC,
    input wire branch_taken, // 0-> not take, so PC+4; 1-> take, so branch_target
    input wire branch_source, // 0-> from pc+offset, 1: s2 + offset
    input wire [INST_ADDR_WIDTH-1:0] branch_jalr_target,
    input wire [INST_ADDR_WIDTH-1:0] branch_jal_beq_bne_target,
    input wire [INST_ADDR_WIDTH-1:0] IF_PC_plus_4,
    output wire inst_we_core2mem,
    output wire inst_request_core2mem,
    output reg [INST_ADDR_WIDTH-1:0] PC
);

localparam IDLE = 0;
localparam FETCH = 1;
localparam INTERRUPT = 2;

reg [1:0] cpu_state, n_cpu_state;
reg [INST_ADDR_WIDTH-1:0] n_PC;

assign inst_we_core2mem = 0;
assign inst_request_core2mem = (cpu_state == FETCH) ? 1 : 0;

always@(*)begin
    if(stall_PC)begin
        n_PC = PC;
    end else begin
        case(cpu_state)
        IDLE: n_PC = 0;
        FETCH:begin
            if(branch_taken)begin
                if(branch_source) n_PC = branch_jalr_target;
                else n_PC = branch_jal_beq_bne_target;
            end else begin
                n_PC = IF_PC_plus_4;
            end
        end
        default: n_PC = PC;
        endcase
    end
end

always@(*)begin
    n_cpu_state = cpu_state;
    if(cpu_state == IDLE) begin
        if(start) n_cpu_state = FETCH;
        else n_cpu_state = IDLE;
    end else begin
        if(!start) n_cpu_state = INTERRUPT;
        else n_cpu_state = FETCH;
    end
end

always@(posedge clk)begin
    if(!rst_n) begin
        cpu_state <= IDLE;
        PC <= 0;
    end else begin
        cpu_state <= n_cpu_state;
        PC <= n_PC;
    end
end

endmodule