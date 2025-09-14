`ifndef RISCV_DEFS_VH
`define RISCV_DEFS_VH

`define R_type 7'b0000001
`define I_type 7'b0000010
`define S_type 7'b0000100
`define B_type 7'b0001000
`define U_type 7'b0010000
`define J_type 7'b0100000
`define X_type 7'b1000000

`define LUI    7'b0110111
`define AUIPC  7'b0010111
`define JAL    7'b1101111
`define JALR   7'b1100111
`define BRANCH 7'b1100011
`define LOAD   7'b0000011
`define STORE  7'b0100011
`define CAL_I  7'b0010011
`define CAL_R  7'b0110011

`endif