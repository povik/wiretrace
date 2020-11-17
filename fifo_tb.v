`timescale 1ns/1ps

module fifo_tb;
    reg clk24;
    reg reset;

    reg [39:0] in = 32'hbeeffdfd;
    reg ine;
    reg adv;

    wire [39:0] out;
    wire oute, full;

    fifo f(.clk(clk24), .reset(reset), .in(in), .ine(ine),
           .out(out), .oute(oute), .full(full), .adv(adv));

    always
        #21 clk24 = ~clk24;

    initial
    begin
        $dumpfile("fifo_tb.vcd");
        $dumpvars;
        clk24 = 1'b0;
        reset = 1'b1;
        adv = 1'b0;
        #210
        reset = 1'b0;
        ine = 1'b1;
        #2100000 $finish;
    end

    always @(posedge clk24)
        if (reset)
            in <= 0;
        else
            if (~full)
                in <= in + 1;

    reg [3:0] clkdiv;
    always @(posedge clk24)
        if (reset)
            clkdiv <= 0;
        else
            clkdiv <= clkdiv + 1;

    always @(posedge clk24)
        if (reset)
            adv <= 0;
        else
            adv <= (clkdiv == 4'b1111);
endmodule
