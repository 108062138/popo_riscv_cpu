// module data_mem #(
//     parameter DATA_WIDTH = 32, // word address
//     parameter DATA_ADDR_WIDTH = 32,
//     parameter NUM_WORDS = 128
// )(
//     input wire cpu_clk,
//     input wire cpu_rst_n,
//     input wire [DATA_ADDR_WIDTH-1:0] cpu_data_mem_raddr,
//     input wire [DATA_ADDR_WIDTH-1:0] dma_data_mem_raddr,
//     input wire data_mem_read_ctrl_by,
//     output reg [DATA_WIDTH-1:0] data_mem_rdata,
//     output reg data_mem_hazard,

//     input wire [DATA_ADDR_WIDTH-1:0] cpu_data_mem_waddr,
//     input wire [DATA_WIDTH-1:0] cpu_data_mem_wdata,
//     input wire [DATA_ADDR_WIDTH-1:0] dma_data_mem_waddr,
//     input wire [DATA_WIDTH-1:0] dma_data_mem_wdata,
//     input wire data_mem_write,
//     input wire data_mem_write_ctrl_by
// );
// localparam cpu_ctrl = 0;
// localparam dma_ctrl = 1;
// reg [DATA_WIDTH-1:0] mem [0:NUM_WORDS-1];
// initial begin
//     $readmemh("/home/popo/Desktop/popo_train_cpu/popo_cpu/tb/data.mem", mem);
// end
// always @(*) begin
//     data_mem_hazard = #1 0;
//     if(data_mem_read_ctrl_by==cpu_ctrl)
//         data_mem_rdata = #1 mem[cpu_data_mem_raddr];
//     else
//         data_mem_rdata = #1 mem[dma_data_mem_raddr];
// end
// always @(posedge cpu_clk) begin
//     if(data_mem_write)begin
//         if(data_mem_write_ctrl_by==cpu_ctrl)
//             mem[cpu_data_mem_waddr] <= #1 cpu_data_mem_wdata;
//         else
//             mem[dma_data_mem_waddr] <= #1 dma_data_mem_wdata;
//     end
// end

// reg [DATA_WIDTH-1:0] word_0;
// reg [DATA_WIDTH-1:0] word_1;
// reg [DATA_WIDTH-1:0] word_2;
// reg [DATA_WIDTH-1:0] word_3;
// reg [DATA_WIDTH-1:0] word_4;
// reg [DATA_WIDTH-1:0] word_5;
// reg [DATA_WIDTH-1:0] word_6;
// reg [DATA_WIDTH-1:0] word_7;
// reg [DATA_WIDTH-1:0] word_8;
// reg [DATA_WIDTH-1:0] word_9;
// reg [DATA_WIDTH-1:0] word_10;

// always @(*) begin
//     word_0 = mem[0];
//     word_1 = mem[1];
//     word_2 = mem[2];
//     word_3 = mem[3];
//     word_4 = mem[4];
//     word_5 = mem[5];
//     word_6 = mem[6];
//     word_7 = mem[7];
//     word_8 = mem[8];
//     word_9 = mem[9];
//     word_10 = mem[10];
// end

// endmodule

module data_mem #(
    parameter DATA_WIDTH = 32, // word address
    parameter DATA_ADDR_WIDTH = 32,
    parameter NUM_WORDS = 128
)(
    input wire cpu_clk,
    input wire cpu_rst_n,
    input wire [DATA_ADDR_WIDTH-1:0] cpu_data_mem_raddr,
    input wire [DATA_ADDR_WIDTH-1:0] dma_data_mem_raddr,
    input wire data_mem_read_ctrl_by,
    output reg [DATA_WIDTH-1:0] data_mem_rdata,
    output reg data_mem_hazard,

    input wire [DATA_ADDR_WIDTH-1:0] cpu_data_mem_waddr,
    input wire [DATA_WIDTH-1:0] cpu_data_mem_wdata,
    input wire [DATA_ADDR_WIDTH-1:0] dma_data_mem_waddr,
    input wire [DATA_WIDTH-1:0] dma_data_mem_wdata,
    input wire data_mem_write,
    input wire [3:0] cpu_data_mem_write_strobe,
    input wire data_mem_write_ctrl_by
);

localparam cpu_ctrl = 0;
localparam dma_ctrl = 1;
reg [DATA_WIDTH-1:0] mem [0:NUM_WORDS-1];

initial begin
    $readmemh("/home/popo/Desktop/popo_train_cpu/popo_cpu/tb/data.mem", mem);
end

reg [1:0] read_offset;
reg [DATA_ADDR_WIDTH-1:0] read_base_word_number;
reg [DATA_WIDTH-1:0] concat_cpu_data_mem_rdata;

always @(*) begin
    read_offset = 0;
    read_base_word_number = 0;
    concat_cpu_data_mem_rdata = 0;
    if(data_mem_read_ctrl_by==cpu_ctrl)begin
        read_offset = cpu_data_mem_raddr[1:0];
        read_base_word_number = cpu_data_mem_raddr >> 2;
        case (read_offset)
            0: concat_cpu_data_mem_rdata = mem[read_base_word_number];
            1: concat_cpu_data_mem_rdata = {mem[read_base_word_number+1][8-1:0], mem[read_base_word_number][32-1:8]};
            2: concat_cpu_data_mem_rdata = {mem[read_base_word_number+1][16-1:0], mem[read_base_word_number][32-1:16]};
            3: concat_cpu_data_mem_rdata = {mem[read_base_word_number+1][24-1:0], mem[read_base_word_number][32-1:24]};
            default: concat_cpu_data_mem_rdata = mem[read_base_word_number];
        endcase
    end
end

reg [1:0] write_offset;
reg [DATA_ADDR_WIDTH-1:0] write_base_word_number;
reg [DATA_WIDTH-1:0] concat_cpu_data_mem_wdata_0, concat_cpu_data_mem_wdata_1;

always @(*) begin
    write_offset = 0;
    write_base_word_number = 0;
    concat_cpu_data_mem_wdata_0 = 0;
    concat_cpu_data_mem_wdata_1 = 0;
    if(data_mem_write_ctrl_by==cpu_ctrl)begin
        write_offset = cpu_data_mem_waddr[1:0];
        write_base_word_number = cpu_data_mem_waddr >> 2;
        case (write_offset)
            0:begin
                concat_cpu_data_mem_wdata_0 = cpu_data_mem_wdata;
                concat_cpu_data_mem_wdata_1 = mem[write_base_word_number+1];
            end 
            1:begin
                concat_cpu_data_mem_wdata_0 = {cpu_data_mem_wdata[24-1:0], mem[write_base_word_number][8-1:0]};
                concat_cpu_data_mem_wdata_1 = {mem[write_base_word_number+1][32-1:8], cpu_data_mem_wdata[32-1:24]};
            end
            2:begin
                concat_cpu_data_mem_wdata_0 = {cpu_data_mem_wdata[16-1:0], mem[write_base_word_number][16-1:0]};
                concat_cpu_data_mem_wdata_1 = {mem[write_base_word_number+1][32-1:16], cpu_data_mem_wdata[32-1:16]};
            end
            3:begin
                concat_cpu_data_mem_wdata_0 = {cpu_data_mem_wdata[8-1:0], mem[write_base_word_number][24-1:0]};
                concat_cpu_data_mem_wdata_1 = {mem[write_base_word_number+1][32-1:24], cpu_data_mem_wdata[32-1:8]};
            end
            default: begin
                concat_cpu_data_mem_wdata_0 = cpu_data_mem_wdata;
                concat_cpu_data_mem_wdata_1 = mem[write_base_word_number+1];
            end
        endcase
    end
end

always @(*) begin
    data_mem_hazard = #1 0;
    if(data_mem_read_ctrl_by==cpu_ctrl)
        data_mem_rdata = #1 concat_cpu_data_mem_rdata;
    else
        data_mem_rdata = #1 mem[dma_data_mem_raddr];
end
always @(posedge cpu_clk) begin
    if(data_mem_write)begin
        if(data_mem_write_ctrl_by==cpu_ctrl)begin
            mem[write_base_word_number] <= #1 concat_cpu_data_mem_wdata_0;
            mem[write_base_word_number+1] <= #1 concat_cpu_data_mem_wdata_1;
        end else begin
            mem[dma_data_mem_waddr] <= #1 dma_data_mem_wdata;
        end
    end
end

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
reg [DATA_WIDTH-1:0] word_51;
reg [DATA_WIDTH-1:0] word_52;
reg [DATA_WIDTH-1:0] word_53;
reg [DATA_WIDTH-1:0] word_54;
reg [DATA_WIDTH-1:0] word_55;
reg [DATA_WIDTH-1:0] word_56;
reg [DATA_WIDTH-1:0] word_57;
reg [DATA_WIDTH-1:0] word_58;
reg [DATA_WIDTH-1:0] word_59;
reg [DATA_WIDTH-1:0] word_60;
reg [DATA_WIDTH-1:0] word_61;
reg [DATA_WIDTH-1:0] word_62;
reg [DATA_WIDTH-1:0] word_63;
reg [DATA_WIDTH-1:0] word_64;
reg [DATA_WIDTH-1:0] word_65;
reg [DATA_WIDTH-1:0] word_66;
reg [DATA_WIDTH-1:0] word_67;
reg [DATA_WIDTH-1:0] word_68;
reg [DATA_WIDTH-1:0] word_69;
reg [DATA_WIDTH-1:0] word_70;
reg [DATA_WIDTH-1:0] word_71;
reg [DATA_WIDTH-1:0] word_72;
reg [DATA_WIDTH-1:0] word_73;
reg [DATA_WIDTH-1:0] word_74;
reg [DATA_WIDTH-1:0] word_75;
reg [DATA_WIDTH-1:0] word_76;
reg [DATA_WIDTH-1:0] word_77;
reg [DATA_WIDTH-1:0] word_78;
reg [DATA_WIDTH-1:0] word_79;
reg [DATA_WIDTH-1:0] word_80;

always @(*) begin
    word_0  = mem[0];
    word_1  = mem[1];
    word_2  = mem[2];
    word_3  = mem[3];
    word_4  = mem[4];
    word_5  = mem[5];
    word_6  = mem[6];
    word_7  = mem[7];
    word_8  = mem[8];
    word_9  = mem[9];
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
    word_51 = mem[51];
    word_52 = mem[52];
    word_53 = mem[53];
    word_54 = mem[54];
    word_55 = mem[55];
    word_56 = mem[56];
    word_57 = mem[57];
    word_58 = mem[58];
    word_59 = mem[59];
    word_60 = mem[60];
    word_61 = mem[61];
    word_62 = mem[62];
    word_63 = mem[63];
    word_64 = mem[64];
    word_65 = mem[65];
    word_66 = mem[66];
    word_67 = mem[67];
    word_68 = mem[68];
    word_69 = mem[69];
    word_70 = mem[70];
    word_71 = mem[71];
    word_72 = mem[72];
    word_73 = mem[73];
    word_74 = mem[74];
    word_75 = mem[75];
    word_76 = mem[76];
    word_77 = mem[77];
    word_78 = mem[78];
    word_79 = mem[79];
    word_80 = mem[80];
end

endmodule

// module data_mem #(
//     parameter DATA_WIDTH = 32, // word address
//     parameter DATA_ADDR_WIDTH = 32,
//     parameter NUM_WORDS = 128
// )(
//     input wire cpu_clk,
//     input wire cpu_rst_n,
//     input wire [DATA_ADDR_WIDTH-1:0] cpu_data_mem_raddr,
//     input wire [DATA_ADDR_WIDTH-1:0] dma_data_mem_raddr,
//     input wire data_mem_read_ctrl_by,
//     output reg [DATA_WIDTH-1:0] data_mem_rdata,
//     output reg data_mem_hazard,

//     input wire [DATA_ADDR_WIDTH-1:0] cpu_data_mem_waddr,
//     input wire [DATA_WIDTH-1:0] cpu_data_mem_wdata,
//     input wire [DATA_ADDR_WIDTH-1:0] dma_data_mem_waddr,
//     input wire [DATA_WIDTH-1:0] dma_data_mem_wdata,
//     input wire data_mem_write,
//     input wire [3:0] cpu_data_mem_write_strobe,
//     input wire data_mem_write_ctrl_by
// );

// localparam cpu_ctrl = 0;
// localparam dma_ctrl = 1;
// reg [8-1:0] mem [0:1024-1];

// initial begin
//     $readmemh("/home/popo/Desktop/popo_train_cpu/popo_cpu/tb/byte_data.mem", mem);
// end

// reg [DATA_WIDTH-1:0] concat_cpu_data_mem_rdata;
// reg [8-1:0] seperate_cpu_data_mem_wdata [0:3];

// always @(*) begin
//     concat_cpu_data_mem_rdata = {mem[cpu_data_mem_raddr+3], mem[cpu_data_mem_raddr+2], mem[cpu_data_mem_raddr+1], mem[cpu_data_mem_raddr]};
// end

// always @(*) begin
//     seperate_cpu_data_mem_wdata[0] = mem[cpu_data_mem_waddr];
//     if(cpu_data_mem_write_strobe[0])
//         seperate_cpu_data_mem_wdata[0] = cpu_data_mem_wdata[8*1-1:8*0];
    
//     seperate_cpu_data_mem_wdata[1] = mem[cpu_data_mem_waddr+1];
//     if(cpu_data_mem_write_strobe[1])
//         seperate_cpu_data_mem_wdata[1] = cpu_data_mem_wdata[8*2-1:8*1];
    
//     seperate_cpu_data_mem_wdata[2] = mem[cpu_data_mem_waddr+2];
//     if(cpu_data_mem_write_strobe[2])
//         seperate_cpu_data_mem_wdata[2] = cpu_data_mem_wdata[8*3-1:8*2];
    
//     seperate_cpu_data_mem_wdata[3] = mem[cpu_data_mem_waddr+3];
//     if(cpu_data_mem_write_strobe[3])
//         seperate_cpu_data_mem_wdata[3] = cpu_data_mem_wdata[8*4-1:8*3];
// end

// always @(*) begin
//     data_mem_hazard = #1 0;
//     if(data_mem_read_ctrl_by==cpu_ctrl)
//         data_mem_rdata = #1 concat_cpu_data_mem_rdata;
//     else
//         data_mem_rdata = #1 0;
// end
// always @(posedge cpu_clk) begin
//     if(data_mem_write)begin
//         if(data_mem_write_ctrl_by==cpu_ctrl)begin
//             mem[cpu_data_mem_waddr+0] <= seperate_cpu_data_mem_wdata[0];
//             mem[cpu_data_mem_waddr+1] <= seperate_cpu_data_mem_wdata[1];
//             mem[cpu_data_mem_waddr+2] <= seperate_cpu_data_mem_wdata[2];
//             mem[cpu_data_mem_waddr+3] <= seperate_cpu_data_mem_wdata[3];
//         end else begin
//             mem[dma_data_mem_waddr] <= #1 0;
//         end
//     end
// end

// reg [8-1:0] byte_0;
// reg [8-1:0] byte_1;
// reg [8-1:0] byte_2;
// reg [8-1:0] byte_3;
// reg [8-1:0] byte_4;
// reg [8-1:0] byte_5;
// reg [8-1:0] byte_6;
// reg [8-1:0] byte_7;
// reg [8-1:0] byte_8;
// reg [8-1:0] byte_9;
// reg [8-1:0] byte_10;
// reg [8-1:0] byte_11;
// reg [8-1:0] byte_12;
// reg [8-1:0] byte_13;
// reg [8-1:0] byte_14;
// reg [8-1:0] byte_15;
// reg [8-1:0] byte_16;
// reg [8-1:0] byte_17;
// reg [8-1:0] byte_18;
// reg [8-1:0] byte_19;
// reg [8-1:0] byte_20;
// reg [8-1:0] byte_21;
// reg [8-1:0] byte_22;
// reg [8-1:0] byte_23;
// reg [8-1:0] byte_24;
// reg [8-1:0] byte_25;
// reg [8-1:0] byte_26;
// reg [8-1:0] byte_27;
// reg [8-1:0] byte_28;
// reg [8-1:0] byte_29;
// reg [8-1:0] byte_30;
// reg [8-1:0] byte_31;
// reg [8-1:0] byte_32;
// reg [8-1:0] byte_33;
// reg [8-1:0] byte_34;
// reg [8-1:0] byte_35;
// reg [8-1:0] byte_36;
// reg [8-1:0] byte_37;
// reg [8-1:0] byte_38;
// reg [8-1:0] byte_39;
// reg [8-1:0] byte_40;
// reg [8-1:0] byte_41;
// reg [8-1:0] byte_42;
// reg [8-1:0] byte_43;
// reg [8-1:0] byte_44;
// reg [8-1:0] byte_45;
// reg [8-1:0] byte_46;
// reg [8-1:0] byte_47;
// reg [8-1:0] byte_48;
// reg [8-1:0] byte_49;
// reg [8-1:0] byte_50;
// reg [8-1:0] byte_51;
// reg [8-1:0] byte_52;
// reg [8-1:0] byte_53;
// reg [8-1:0] byte_54;
// reg [8-1:0] byte_55;
// reg [8-1:0] byte_56;
// reg [8-1:0] byte_57;
// reg [8-1:0] byte_58;
// reg [8-1:0] byte_59;

// always @(*) begin
//     byte_0  = mem[0];
//     byte_1  = mem[1];
//     byte_2  = mem[2];
//     byte_3  = mem[3];
//     byte_4  = mem[4];
//     byte_5  = mem[5];
//     byte_6  = mem[6];
//     byte_7  = mem[7];
//     byte_8  = mem[8];
//     byte_9  = mem[9];
//     byte_10 = mem[10];
//     byte_11 = mem[11];
//     byte_12 = mem[12];
//     byte_13 = mem[13];
//     byte_14 = mem[14];
//     byte_15 = mem[15];
//     byte_16 = mem[16];
//     byte_17 = mem[17];
//     byte_18 = mem[18];
//     byte_19 = mem[19];
//     byte_20 = mem[20];
//     byte_21 = mem[21];
//     byte_22 = mem[22];
//     byte_23 = mem[23];
//     byte_24 = mem[24];
//     byte_25 = mem[25];
//     byte_26 = mem[26];
//     byte_27 = mem[27];
//     byte_28 = mem[28];
//     byte_29 = mem[29];
//     byte_30 = mem[30];
//     byte_31 = mem[31];
//     byte_32 = mem[32];
//     byte_33 = mem[33];
//     byte_34 = mem[34];
//     byte_35 = mem[35];
//     byte_36 = mem[36];
//     byte_37 = mem[37];
//     byte_38 = mem[38];
//     byte_39 = mem[39];
//     byte_40 = mem[40];
//     byte_41 = mem[41];
//     byte_42 = mem[42];
//     byte_43 = mem[43];
//     byte_44 = mem[44];
//     byte_45 = mem[45];
//     byte_46 = mem[46];
//     byte_47 = mem[47];
//     byte_48 = mem[48];
//     byte_49 = mem[49];
//     byte_50 = mem[50];
//     byte_51 = mem[51];
//     byte_52 = mem[52];
//     byte_53 = mem[53];
//     byte_54 = mem[54];
//     byte_55 = mem[55];
//     byte_56 = mem[56];
//     byte_57 = mem[57];
//     byte_58 = mem[58];
//     byte_59 = mem[59];
// end

// endmodule