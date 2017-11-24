module RegisterFile(
	input [4:0] Read_reg1, 
	input [4:0] Read_reg2, 
	input WE, 
	input CLK, 
	input [4:0] Write_reg, 
	input [31:0] Write_data, 
	output [31:0] Read_data1,
	output [31:0] Read_data2
	);

reg [31:0] regFile[1:31]; 

assign Read_data1 = (Read_reg1 == 5'b0)? 0:regFile[Read_reg1];
assign Read_data2 = (Read_reg2 == 5'b0)? 0:regFile[Read_reg2];

always @(negedge CLK) begin
	if (1 == WE && Write_reg != 0) begin
		regFile[Write_reg] <= Write_data;
	end
end
endmodule