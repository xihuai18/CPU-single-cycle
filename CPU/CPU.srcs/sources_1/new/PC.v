module PC(
	input CLK,
	input Reset, //0, initialize; 1, receive new address
	input PCWre, //0, PC remains; 1, PC changes
	input [31:0] IAddrIn,
	output [31:0] IAddrOut
	);

reg [31:0] IAddrOut_reg; 

initial 
    IAddrOut_reg = 32'b0;

assign IAddrOut = IAddrOut_reg;

always @(posedge CLK) begin
    if(Reset == 1)begin
        if(1 == PCWre) begin
            IAddrOut_reg <= IAddrIn;
        end
        else begin
            IAddrOut_reg <= IAddrOut_reg;
        end
	end
	else IAddrOut_reg <= 32'b0;
end

endmodule