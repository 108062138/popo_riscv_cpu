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
    $display("hahah");
    $readmemh("/home/popo/Desktop/popo_train_cpu/popo_cpu/tb/word_data.mem", mem);
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
                if(cpu_data_mem_write_strobe==4'b1111)begin
                    concat_cpu_data_mem_wdata_0 = cpu_data_mem_wdata;
                    concat_cpu_data_mem_wdata_1 = mem[write_base_word_number+1];
                end else if(cpu_data_mem_write_strobe==4'b0011)begin
                    concat_cpu_data_mem_wdata_0 = {mem[write_base_word_number][32-1:16], cpu_data_mem_wdata[16-1:0]};
                    concat_cpu_data_mem_wdata_1 = mem[write_base_word_number+1];
                end else if(cpu_data_mem_write_strobe==4'b0001)begin
                    concat_cpu_data_mem_wdata_0 = {mem[write_base_word_number][32-1:8], cpu_data_mem_wdata[8-1:0]};
                    concat_cpu_data_mem_wdata_1 = mem[write_base_word_number+1];
                end else begin
                    concat_cpu_data_mem_wdata_0 = 32'h09107519;
                    concat_cpu_data_mem_wdata_1 = 32'h12345678;
                end
            end 
            1:begin
                if(cpu_data_mem_write_strobe==4'b1111)begin
                    concat_cpu_data_mem_wdata_0 = {cpu_data_mem_wdata[24-1:0], mem[write_base_word_number][8-1:0]};
                    concat_cpu_data_mem_wdata_1 = {mem[write_base_word_number+1][32-1:8], cpu_data_mem_wdata[32-1:24]};
                end else if(cpu_data_mem_write_strobe==4'b0011)begin
                    concat_cpu_data_mem_wdata_0 = {mem[write_base_word_number][32-1:24], cpu_data_mem_wdata[16-1:0], mem[write_base_word_number][8-1:0]};
                    concat_cpu_data_mem_wdata_1 = mem[write_base_word_number+1];
                end else if(cpu_data_mem_write_strobe==4'b0001) begin
                    concat_cpu_data_mem_wdata_0 = {mem[write_base_word_number][32-1:16], cpu_data_mem_wdata[8-1:0], mem[write_base_word_number][8-1:0]};
                    concat_cpu_data_mem_wdata_1 = mem[write_base_word_number+1];
                end else begin
                    concat_cpu_data_mem_wdata_0 = 32'h45645748;
                    concat_cpu_data_mem_wdata_1 = 32'h80776168;
                end
            end
            2:begin
                if(cpu_data_mem_write_strobe == 4'b1111)begin
                    concat_cpu_data_mem_wdata_0 = {cpu_data_mem_wdata[16-1:0], mem[write_base_word_number][16-1:0]};
                    concat_cpu_data_mem_wdata_1 = {mem[write_base_word_number+1][32-1:16], cpu_data_mem_wdata[32-1:16]};
                end else if(cpu_data_mem_write_strobe == 4'b0011)begin
                    concat_cpu_data_mem_wdata_0 = {cpu_data_mem_wdata[16-1:0], mem[write_base_word_number][16-1:0]};
                    concat_cpu_data_mem_wdata_1 = mem[write_base_word_number+1];
                end else if(cpu_data_mem_write_strobe == 4'b0001) begin
                    concat_cpu_data_mem_wdata_0 = {mem[write_base_word_number][32-1:24], cpu_data_mem_wdata[8-1:0], mem[write_base_word_number][16-1:0]};
                    concat_cpu_data_mem_wdata_1 = mem[write_base_word_number+1];
                end else begin
                    concat_cpu_data_mem_wdata_0 = 32'h09107519;
                    concat_cpu_data_mem_wdata_1 = 32'h12345678;
                end
            end
            3:begin
                if(cpu_data_mem_write_strobe == 4'b1111)begin
                    concat_cpu_data_mem_wdata_0 = {cpu_data_mem_wdata[8-1:0], mem[write_base_word_number][24-1:0]};
                    concat_cpu_data_mem_wdata_1 = {mem[write_base_word_number+1][32-1:24], cpu_data_mem_wdata[32-1:8]};
                end else if(cpu_data_mem_write_strobe==4'b0011)begin
                    concat_cpu_data_mem_wdata_0 = {cpu_data_mem_wdata[8-1:0], mem[write_base_word_number][24-1:0]};
                    concat_cpu_data_mem_wdata_1 = {mem[write_base_word_number+1][32-1:8], cpu_data_mem_wdata[16-1:8]};
                end else if(cpu_data_mem_write_strobe==4'b0001) begin
                    concat_cpu_data_mem_wdata_0 = {cpu_data_mem_wdata[8-1:0], mem[write_base_word_number][24-1:0]};
                    concat_cpu_data_mem_wdata_1 = mem[write_base_word_number+1];
                end else begin
                    concat_cpu_data_mem_wdata_0 = 32'h09107519;
                    concat_cpu_data_mem_wdata_1 = 32'h12345678;
                end 
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

reg [DATA_WIDTH-1:0] word_0,   word_1,  word_2,  word_3,  word_4,  word_5,  word_6,  word_7,  word_8,  word_9;
reg [DATA_WIDTH-1:0] word_10, word_11, word_12, word_13, word_14, word_15, word_16, word_17, word_18, word_19;
reg [DATA_WIDTH-1:0] word_20, word_21, word_22, word_23, word_24, word_25, word_26, word_27, word_28, word_29;
reg [DATA_WIDTH-1:0] word_30, word_31, word_32, word_33, word_34, word_35, word_36, word_37, word_38, word_39;
reg [DATA_WIDTH-1:0] word_40, word_41, word_42, word_43, word_44, word_45, word_46, word_47, word_48, word_49;
reg [DATA_WIDTH-1:0] word_50, word_51, word_52, word_53, word_54, word_55, word_56, word_57, word_58, word_59;
reg [DATA_WIDTH-1:0] word_60, word_61, word_62, word_63, word_64, word_65, word_66, word_67, word_68, word_69;
reg [DATA_WIDTH-1:0] word_70, word_71, word_72, word_73, word_74, word_75, word_76, word_77, word_78, word_79;
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