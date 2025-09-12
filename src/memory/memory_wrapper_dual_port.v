module memory_wrapper_dual_port #(
    parameter INIT_BY = 0,
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 32,
    parameter NUM_WORDS = 128
)(
    input wire clk,
    input wire rst_n,
    input wire wen,
    input wire [ADDR_WIDTH-1:0] waddr,
    input wire [DATA_WIDTH-1:0] wdata,
    input wire ren,
    input wire [ADDR_WIDTH-1:0] raddr,
    output reg [DATA_WIDTH-1:0] rdata
);

reg [DATA_WIDTH-1:0] mem [0:NUM_WORDS-1];

initial begin
    if(INIT_BY==0)$readmemh("/home/popo/Desktop/popo_train_cpu/popo_cpu/tb/slow_data.mem", mem);
end

always@(posedge clk)begin
    if(!rst_n)begin
        rdata <= #10 0;
    end else begin
        if(ren)begin
            if(raddr==waddr && wen) rdata <= #10 wdata;
            else rdata <= #10 mem[raddr];
        end else begin
            rdata <= #10 0;
        end
    end
end

always @(posedge clk) begin
    if(wen)begin
        mem[waddr] <= wdata;
    end
end

// Declare word_0 to word_50
reg [DATA_WIDTH-1:0] word_0;
reg [DATA_WIDTH-1:0] word_1;
reg [DATA_WIDTH-1:0] word_2;
reg [DATA_WIDTH-1:0] word_3;
reg [DATA_WIDTH-1:0] word_4;
reg [DATA_WIDTH-1:0] word_5;
reg [DATA_WIDTH-1:0] word_6;
reg [DATA_WIDTH-1:0] word_7;
reg [DATA_WIDTH-1:0] word_8;
reg [DATA_WIDTH-1:0] word_9;
reg [DATA_WIDTH-1:0] word_10;
reg [DATA_WIDTH-1:0] word_11;
reg [DATA_WIDTH-1:0] word_12;
reg [DATA_WIDTH-1:0] word_13;
reg [DATA_WIDTH-1:0] word_14;
reg [DATA_WIDTH-1:0] word_15;
reg [DATA_WIDTH-1:0] word_16;
reg [DATA_WIDTH-1:0] word_17;
reg [DATA_WIDTH-1:0] word_18;
reg [DATA_WIDTH-1:0] word_19;
reg [DATA_WIDTH-1:0] word_20;
reg [DATA_WIDTH-1:0] word_21;
reg [DATA_WIDTH-1:0] word_22;
reg [DATA_WIDTH-1:0] word_23;
reg [DATA_WIDTH-1:0] word_24;
reg [DATA_WIDTH-1:0] word_25;
reg [DATA_WIDTH-1:0] word_26;
reg [DATA_WIDTH-1:0] word_27;
reg [DATA_WIDTH-1:0] word_28;
reg [DATA_WIDTH-1:0] word_29;
reg [DATA_WIDTH-1:0] word_30;
reg [DATA_WIDTH-1:0] word_31;
reg [DATA_WIDTH-1:0] word_32;
reg [DATA_WIDTH-1:0] word_33;
reg [DATA_WIDTH-1:0] word_34;
reg [DATA_WIDTH-1:0] word_35;
reg [DATA_WIDTH-1:0] word_36;
reg [DATA_WIDTH-1:0] word_37;
reg [DATA_WIDTH-1:0] word_38;
reg [DATA_WIDTH-1:0] word_39;
reg [DATA_WIDTH-1:0] word_40;
reg [DATA_WIDTH-1:0] word_41;
reg [DATA_WIDTH-1:0] word_42;
reg [DATA_WIDTH-1:0] word_43;
reg [DATA_WIDTH-1:0] word_44;
reg [DATA_WIDTH-1:0] word_45;
reg [DATA_WIDTH-1:0] word_46;
reg [DATA_WIDTH-1:0] word_47;
reg [DATA_WIDTH-1:0] word_48;
reg [DATA_WIDTH-1:0] word_49;
reg [DATA_WIDTH-1:0] word_50;

always @(*) begin
    word_0 = mem[0];
    word_1 = mem[1];
    word_2 = mem[2];
    word_3 = mem[3];
    word_4 = mem[4];
    word_5 = mem[5];
    word_6 = mem[6];
    word_7 = mem[7];
    word_8 = mem[8];
    word_9 = mem[9];
    word_10 = mem[10];
    word_11 = mem[11];
    word_12 = mem[12];
    word_13 = mem[13];
    word_14 = mem[14];
    word_15 = mem[15];
    word_16 = mem[16];
    word_17 = mem[17];
    word_18 = mem[18];
    word_19 = mem[19];
    word_20 = mem[20];
    word_21 = mem[21];
    word_22 = mem[22];
    word_23 = mem[23];
    word_24 = mem[24];
    word_25 = mem[25];
    word_26 = mem[26];
    word_27 = mem[27];
    word_28 = mem[28];
    word_29 = mem[29];
    word_30 = mem[30];
    word_31 = mem[31];
    word_32 = mem[32];
    word_33 = mem[33];
    word_34 = mem[34];
    word_35 = mem[35];
    word_36 = mem[36];
    word_37 = mem[37];
    word_38 = mem[38];
    word_39 = mem[39];
    word_40 = mem[40];
    word_41 = mem[41];
    word_42 = mem[42];
    word_43 = mem[43];
    word_44 = mem[44];
    word_45 = mem[45];
    word_46 = mem[46];
    word_47 = mem[47];
    word_48 = mem[48];
    word_49 = mem[49];
    word_50 = mem[50];
end

endmodule
