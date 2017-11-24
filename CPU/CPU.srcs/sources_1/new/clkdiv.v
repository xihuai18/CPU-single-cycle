`timescale 1ns / 1ps
module clkdiv(
	input wire reset,
	input wire mclk,
	output wire clk190,
	output wire clk1000
	);
reg [26:0] q;

always @(posedge mclk) begin
begin
	if (reset == 0)
		q <= 0;
	else
		q <= q + 1;		
	end
end
assign clk190 = q[14];
assign clk1000 = q[18];

endmodule