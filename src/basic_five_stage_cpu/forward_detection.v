`include "riscv_defs.vh"

module forward_detection #(
    parameter REGISTER_ADDR_WIDTH = 5
)(
    input wire reg_write_MEM,
    input wire reg_write_WB,
    input wire [6:0] opcode_ID,
    input wire [6:0] opcode_EX,
    input wire [REGISTER_ADDR_WIDTH-1:0] rs1_ID,
    input wire [REGISTER_ADDR_WIDTH-1:0] rs2_ID,
    input wire [REGISTER_ADDR_WIDTH-1:0] rs1_EX,
    input wire [REGISTER_ADDR_WIDTH-1:0] rs2_EX,
    
    input wire [REGISTER_ADDR_WIDTH-1:0] rd_MEM,
    input wire [REGISTER_ADDR_WIDTH-1:0] rd_WB,

    output reg [2:0] forward_detect_rs1,
    output reg [2:0] forward_detect_rs2
);

wire ID_use_rs1, ID_use_rs2;
wire EX_use_rs1, EX_use_rs2;

assign ID_use_rs1 = (opcode_ID != `LUI) && (opcode_ID != `AUIPC) && (opcode_ID !=`JAL);
assign ID_use_rs2 = (opcode_ID == `BRANCH) || (opcode_ID == `STORE) || (opcode_ID == `CAL_R);

assign EX_use_rs1 = (opcode_EX != `LUI) && (opcode_EX != `AUIPC) && (opcode_EX !=`JAL);
assign EX_use_rs2 = (opcode_EX == `BRANCH) || (opcode_EX == `STORE) || (opcode_EX == `CAL_R);

always @(*) begin
    // handle MEM->EX forward
    forward_detect_rs1[`FORWARD_COLLISION_IN_MEM] = 0;
    if(EX_use_rs1 && rs1_EX==rd_MEM && rd_MEM!=0 && reg_write_MEM) forward_detect_rs1[`FORWARD_COLLISION_IN_MEM] = 1;
    // handle WB->EX forward
    forward_detect_rs1[`FORWARD_COLLISION_IN_WB] = 0;
    if(EX_use_rs1 && rs1_EX==rd_WB && rd_WB!=0 && reg_write_WB) forward_detect_rs1[`FORWARD_COLLISION_IN_WB] = 1;
    // handle WB->ID forward
    forward_detect_rs1[`FORWARD_COLLISION_IN_ID] = 0;
    if(ID_use_rs1 && rs1_ID==rd_WB && rd_WB!=0 && reg_write_WB) forward_detect_rs1[`FORWARD_COLLISION_IN_ID] = 1;
end

always @(*) begin
    // handle MEM->EX forward
    forward_detect_rs2[`FORWARD_COLLISION_IN_MEM] = 0;
    if(EX_use_rs2 && rs2_EX==rd_MEM && rd_MEM!=0 && reg_write_MEM) forward_detect_rs2[`FORWARD_COLLISION_IN_MEM] = 1;
    // handle WB->EX forward
    forward_detect_rs2[`FORWARD_COLLISION_IN_WB] = 0;
    if(EX_use_rs2 && rs2_EX==rd_WB && rd_WB!=0 && reg_write_WB) forward_detect_rs2[`FORWARD_COLLISION_IN_WB] = 1;
    // handle WB->ID forward
    forward_detect_rs2[`FORWARD_COLLISION_IN_ID] = 0;
    if(ID_use_rs2 && rs2_ID==rd_WB && rd_WB!=0 && reg_write_WB) forward_detect_rs2[`FORWARD_COLLISION_IN_ID] = 1;
end

endmodule