module led_indication(
    input in,
    output nout,
    input clk
);
    reg [9:0] cnt = 0;
    assign nout = (cnt == 0);
    always @(posedge clk) begin
        if (in) begin
            cnt <= {10{1'b1}};
        end else begin
            if (cnt > 0)
                cnt <= cnt - 1;
            else
                cnt <= 0;
        end
    end
endmodule

module system(
    input   clk24,          // clock, reset
    input   [7:0] probes,
    output  tx,
    output  led_overflow,
    output  led_activity
);
    reg reset = 1;
    reg [9:0] resetcnt = 0;
    always @(posedge clk24)
        if (resetcnt != {10{1'b1}})
            resetcnt <= resetcnt + 1;
        else
            reset <= 0;

    reg [31:0] stamp;
    always @(posedge clk24)
        if (~reset)
            stamp <= stamp + 1;
        else
            stamp <= 0;

    reg [7:0] probessampled;
    always @(posedge clk24)
        probessampled <= probes;

    reg [7:0] oldprobes;
    always @(posedge clk24)
        oldprobes <= probessampled;

    wire [39:0] fifoin = {probessampled, stamp};
    wire fifoine = |(probessampled ^ oldprobes);
    wire [39:0] fifoout;
    wire fifooute;
    wire fifofull;

    reg [47:0] txbytes;
    reg [2:0] txbytespos = 6;
    wire txbytesarmed = (txbytespos != 6);
    wire willconsume = fifooute && ~txbytesarmed;

    fifo f(.in(fifoin), .ine(fifoine),
            .out(fifoout), .oute(fifooute),
            .adv(willconsume), .reset(reset),
            .full(fifofull), .clk(clk24));

    wire tx_busy;
    reg  tx_start = 0;
    reg [7:0] tx_dat;

    always @(posedge clk24) begin
        if (reset) begin
            txbytes <= {48'h68656c6c6f0a};
            txbytespos <= 0;
        end else begin
            if (willconsume) begin
                    txbytes <= {8'haa, fifoout};
                    txbytespos <= 0;
            end

            if (txbytesarmed && ~tx_busy && ~tx_start) begin
                txbytes <= {txbytes[39:0], 8'h00};
                txbytespos <= txbytespos + 1;
                tx_dat <= txbytes[47:40];
                tx_start <= 1;
            end else begin
                tx_start <= 0;
            end
        end
    end

    uart_tx serial(.clk(clk24), .reset(reset), .data(tx_dat),
                   .start(tx_start), .tx(tx), .busy(tx_busy));

    led_indication overflow(
        .nout(led_overflow), .in(fifofull), .clk(clk24)
    );
    led_indication activity(
        .nout(led_activity), .in(fifoine), .clk(clk24)
    );
endmodule
