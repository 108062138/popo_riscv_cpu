module read_pointer_handler #(
    parameter ADDR_WIDTH = 4
)(
    input wire rclk,
    input wire rrst_n,
    input wire rpull,
    input wire [ADDR_WIDTH:0] rq2_wptr,
    output reg rempty,
    output wire [ADDR_WIDTH-1:0] raddr,
    output reg [ADDR_WIDTH:0] rptr
);

reg n_rempty;
reg [ADDR_WIDTH:0] rbin, n_rbin;
reg [ADDR_WIDTH:0] n_rgray;

assign raddr = rbin[ADDR_WIDTH-1:0];

always@(*)begin
    n_rbin = rbin + (rpull && !rempty);
    n_rgray = (n_rbin >> 1) ^ n_rbin;
    n_rempty = (n_rgray == rq2_wptr);
end

always@(posedge rclk)begin
    if(!rrst_n)begin
        rbin <= 0;
        rptr <= 0;
        rempty <= 0;
    end else begin
        rbin <= n_rbin;
        rptr <= n_rgray;
        rempty <= n_rempty;
    end
end

endmodule