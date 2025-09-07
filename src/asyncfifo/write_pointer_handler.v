module write_pointer_handler #(
    parameter ADDR_WIDTH = 4
)(
    input wire wclk,
    input wire wrst_n,
    input wire [ADDR_WIDTH:0] wq2_rptr,
    input wire wpush,
    output reg [ADDR_WIDTH:0] wptr,
    output wire [ADDR_WIDTH-1:0] waddr,
    output reg wfull
);

reg [ADDR_WIDTH:0] n_gray;
reg [ADDR_WIDTH:0] wbin, n_wbin;
reg n_wfull;

assign waddr = wbin[ADDR_WIDTH-1:0];

always@(*)begin
    n_wbin = wbin + (wpush & !wfull);
    n_gray = (n_wbin >> 1) ^ n_wbin;
    n_wfull = (n_gray=={~wq2_rptr[ADDR_WIDTH: ADDR_WIDTH-1], wq2_rptr[ADDR_WIDTH-2:0]});
end

always@(posedge wclk)begin
    if(!wrst_n)begin
        wptr <= 0;
        wbin <= 0;
        wfull <= 0;
    end else begin
        wptr <= n_gray;
        wbin <= n_wbin;
        wfull <= n_wfull;
    end
end

wire check;
wire [ADDR_WIDTH:0] tmp_bin, tmp_gray;
gray2binary #(.WIDTH(ADDR_WIDTH+1)) u_gray2binary(.gray(n_gray), .binary(tmp_bin));
binary2gray #(.WIDTH(ADDR_WIDTH+1)) u_binary2gray(.binary(tmp_bin), .gray(tmp_gray));
assign check = n_wbin == tmp_bin; // check should be one cycle before wfull

endmodule