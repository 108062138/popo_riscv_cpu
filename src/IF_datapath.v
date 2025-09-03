module IF_datapath #(
    parameter INST_WIDTH = 32,
    parameter PC_WIDTH = 32,
    parameter INST_ADDR_WIDTH = 32
)(
    input wire [INST_WIDTH-1:0] IF_inst_i,
    input wire [INST_ADDR_WIDTH-1:0] IF_PC_i,

    output wire [INST_WIDTH-1:0] IF_inst_o,
    output wire [INST_ADDR_WIDTH-1:0] IF_PC_o,
    output wire [INST_ADDR_WIDTH-1:0] IF_PC_plus_4_o 
);

assign IF_inst_o = IF_inst_i;
assign IF_PC_o = IF_PC_i;
assign IF_PC_plus_4_o = IF_PC_i + 4;

endmodule