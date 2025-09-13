// this module handle load then use and mem_hazard, for now, it always output false
module hazard_detection(
    // input
    input inst_mem_hazard,
    input data_mem_hazard,
    // output
    output wire stall_PC_IF,
    output wire stall_IF_ID,
    output wire flush_IF_ID,
    output wire flush_ID_EX
);
assign stall_PC_IF = 0;
assign stall_IF_ID = 0;
assign flush_IF_ID = 0;
assign flush_ID_EX = 0;
// always @(*) begin
//     stall_PC_IF = 0;
//     stall_IF_ID = 0;
//     flush_IF_ID = 0;
//     flush_ID_EX = 0;
// end
endmodule