module gray2binary #(
    parameter WIDTH = 5
)(
    input [WIDTH-1:0] gray,
    output reg [WIDTH-1:0] binary
);
integer i;
always@(*)begin
    binary[WIDTH-1] = gray[WIDTH-1];
    for(i=WIDTH-2;i>=0;i=i-1)begin
        binary[i] = binary[i+1] ^ gray[i];
    end
end
endmodule