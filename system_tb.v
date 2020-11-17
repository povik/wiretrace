`timescale 1ns/1ps
`default_nettype none

module tb_system;
    reg clk24;
    reg [7:0] probes = 0;
    wire tx;

    system f(.clk24(clk24), .probes(probes), .tx(tx));

    always
        #21 clk24 = ~clk24;
    
    initial
    begin
        clk24 = 1'b0;
		#21000000 $finish;
    end

    integer i;

    initial
    begin
        for (i = 0; i < 30; i++)
            #20000 probes <= probes + 1;
    end

    integer stdin, stdout;
    reg [7:0] b;
    initial
    begin
        stdout = $fopen("/dev/stdout", "wb");
        forever begin
            @(negedge tx);
            #4340;
            #8736;

            repeat (7) begin
                b = {tx, b[7:1]};
                #8736;
            end
            b = {tx, b[7:1]};
            $fwrite(stdout, "%c", b);
            $fflush(stdout);
        end
    end
endmodule
