module mini_tb;
    reg clk;
    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        $dumpfile("mini.vcd");
        $dumpvars(0, mini_tb);
        #100;
        $finish;
    end
endmodule
