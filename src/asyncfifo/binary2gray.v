module binary2gray #(
    parameter WIDTH = 5
)(
    input wire [WIDTH-1:0] binary,
    output wire [WIDTH-1:0] gray
);

assign gray = (binary>>1) ^ binary;

endmodule