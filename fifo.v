`default_nettype none

module fifo(
    input clk, reset, ine, adv,
    input [width-1:0] in,
    output [width-1:0] out,
    output oute, full
);
    parameter width = 40;

    reg [11:0] wpos;
    reg [11:0] rpos;
    reg [width-1:0] m[2047:0];

    assign full = (wpos[11] != rpos[11]) && (wpos[10:0] == rpos[10:0]);
    assign out = m[rpos[10:0]];
    assign oute = ~reset && (rpos != wpos);

    always @(posedge clk) begin
        if(reset) begin
            wpos <= 0;
            rpos <= 0;
        end else begin
            if (~full && ine) begin
                m[wpos[10:0]] <= in;
                wpos <= wpos + 1;
            end

            if (adv && oute)
                rpos <= rpos + 1;
        end
    end
endmodule
