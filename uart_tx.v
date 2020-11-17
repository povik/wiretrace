`default_nettype none

module uart_tx(
	input	clk, reset, start,
	input [7:0] data,
	output  tx, busy
);
	localparam period = 24000000 / 115200;
	reg [10:0] cnt;
	reg [3:0] stage;
	reg [8:0] datah;

	assign tx = datah[0];
	assign busy = ~((cnt == 0) && (stage == 0));

	always @(posedge clk) begin
		if (reset) begin
			cnt <= 0;
			stage <= 0;
			datah <= 9'b111111111;
		end else begin
			if (busy) begin
				if (cnt == 0) begin
					datah <= {1'b1, datah[8:1]};
					cnt <= period;
					stage <= stage - 1;
				end else begin
					cnt <= cnt - 1;
				end
			end else begin
				if (start) begin
					stage <= 10;
					cnt <= period;
					datah <= {data, 1'b0};
				end
			end
		end
	end
endmodule
