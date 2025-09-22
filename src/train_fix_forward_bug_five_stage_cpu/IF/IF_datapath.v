module IF_datapath #(
    parameter INST_WIDTH = 32,
    parameter INST_ADDR_WIDTH = 32
)(
    input wire [INST_ADDR_WIDTH-1:0] PC,
    output wire [INST_ADDR_WIDTH-1:0] PC_plus_4_i
);
assign PC_plus_4_i = PC + 4;
endmodule