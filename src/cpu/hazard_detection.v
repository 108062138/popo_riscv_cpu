`include "riscv_defs.vh"

// this module handle load then use and mem_hazard, for now, it always output false
module hazard_detection #(parameter REGISTER_ADDR_WIDTH = 5)(
    // input
    input inst_mem_hazard,
    input data_mem_hazard,
    input wire [REGISTER_ADDR_WIDTH-1:0] rs1_ID,
    input wire [REGISTER_ADDR_WIDTH-1:0] rs2_ID,
    input wire [REGISTER_ADDR_WIDTH-1:0] rd_EX,
    input wire [1:0] result_sel_EX,
    // output
    output reg stall_PC_IF,
    output reg stall_IF_ID,
    output reg flush_IF_ID,
    output reg flush_ID_EX
);

always @(*) begin
    stall_PC_IF = 0;
    stall_IF_ID = 0;
    flush_IF_ID = 0;
    flush_ID_EX = 0;

    if(inst_mem_hazard || data_mem_hazard)begin
        stall_PC_IF = 1;
        stall_IF_ID = 1;
        flush_IF_ID = 1;
        flush_ID_EX = 1; 
    end

    if(result_sel_EX==`SEL_MEM_AS_RES)begin
        if(rd_EX!=0)begin
            stall_PC_IF = 1;
            stall_IF_ID = 1;
            flush_ID_EX = 1;
        end
    end
end

endmodule