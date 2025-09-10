module memory_wrapper_single_port #(
    parameter INIT_BY = 0,
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 32,
    parameter NUM_WORDS = 128
)(
    input wire clk,
    input wire rst_n,
    input wire we,
    input wire request,
    input wire [ADDR_WIDTH-1:0] addr,
    input wire [DATA_WIDTH-1:0] data_i,
    output reg [DATA_WIDTH-1:0] data_o
);

reg [32-1:0] mem [0:NUM_WORDS-1];

integer i;
initial begin
    // INIT_BY: 0-none, 1-inst.txt, 2-data.txt
    if(INIT_BY==1)      $readmemh("/home/popo/Desktop/popo_train_cpu/popo_cpu/tb/inst.mem", mem);
    else if(INIT_BY==2) $readmemh("/home/popo/Desktop/popo_train_cpu/popo_cpu/tb/data.mem", mem);
end

always@(posedge clk)begin
    if(!rst_n)begin
        data_o <= 0;//32'hDEAD_BEEF;
    end else begin
        if(request)begin
            if(we)begin // store
                data_o <= 0;//32'hDEAD_BEEF;
            end else begin // load
                data_o <= mem[addr];
            end
        end else begin
            data_o <= 0;//32'h1234_5678;
        end
    end
end

always@(posedge clk)begin
    if(request && we)begin
        mem[addr] <= data_i;
    end
end

wire [32-1:0] word_0, word_1, word_2, word_3, word_4;
assign word_0 = mem[0];
assign word_1 = mem[1];
assign word_2 = mem[2];
assign word_3 = mem[3];
assign word_4 = mem[4];

endmodule