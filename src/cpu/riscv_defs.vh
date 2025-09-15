`ifndef RISCV_DEFS_VH
`define RISCV_DEFS_VH

`define LUI    7'b0110111
`define AUIPC  7'b0010111
`define JAL    7'b1101111
`define JALR   7'b1100111
`define BRANCH 7'b1100011
`define LOAD   7'b0000011
`define STORE  7'b0100011
`define CAL_I  7'b0010011
`define CAL_R  7'b0110011

`define SEL_ALU_AS_RES 0
`define SEL_MEM_AS_RES 1
`define SEL_PC_PLUS_4_AS_RES 2

`define FORWARD_COLLISION_IN_MEM 0
`define FORWARD_COLLISION_IN_WB 1
`define FORWARD_COLLISION_IN_ID 2

`endif