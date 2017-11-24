`timescale 1ns / 1ps

module top_sim();
reg CLK;
reg Reset;

top top_test(
	.CLK(CLK),
	.Reset(Reset)
	);

initial begin
	CLK = 0;
	Reset = 0;
	
	#100 Reset = 1;
end

always #50 CLK = !CLK;

endmodule