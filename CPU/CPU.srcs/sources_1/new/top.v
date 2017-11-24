`timescale 1ns / 1ps
module top(
	input CLK_BUTN,
	input mclk,
	input Reset,
	input [1:0] SW_in,
	output [7:0] code,
	output [3:0] place
	);

wire PCWre;
wire ALUSrcA;
wire ALUSrcB;
wire DBDataSrc;
wire RegWre;
wire InsMemRW;
wire RD;
wire WR;
wire RegDst;
wire ExtSel;
wire [1:0] PCSrc;
wire [2:0] ALUOp;
wire [31:0] IAddrIn; //From PCSel
wire [31:0] IAddrOut;
wire [31:0] IDataIn;
wire [31:0] IDataOut;

//wire CLK;


assign IDataIn = 32'b0;

PC pc_inst(
	.CLK(CLK),
	.Reset(Reset),
	.PCWre(PCWre),
	.IAddrIn(IAddrIn),
	.IAddrOut(IAddrOut)
	);

wire [31:0] PCAddedFour;

assign PCAddedFour = IAddrOut + 4;

Instruction_Memory Ins_Mem_inst(
	.IAddr(IAddrOut),
	.IDataIn(IDataIn),
	.RW(InsMemRW),
	.IDataOut(IDataOut)
	);

//从指令中拆解出来�?
wire [5:0] op;
wire [4:0] rs;
wire [4:0] rt;
wire [4:0] rd;
wire [4:0] sa;
wire [31:0] Ext_sa;
wire [15:0] immediate;
wire [31:0] Ext_immediate;
wire [25:0] address;

assign op = IDataOut[31:26]; 
assign rs = IDataOut[25:21]; 
assign rt = IDataOut[20:16]; 
assign rd = IDataOut[15:11];
assign sa = IDataOut[10:6]; 
assign Ext_sa = {27'b0000_0000_0000_0000_0000_0000_000,sa}; 
assign immediate = IDataOut[15:0]; 
assign address = IDataOut[25:0];

Extend ext_imm(
	.ExtSel(ExtSel),
	.OriData(immediate),
	.ExtData(Ext_immediate)
	);

wire [4:0] Write_reg;


assign Write_reg = (0 == RegDst)? rt:rd;

wire [31:0] Read_data1;
wire [31:0] Read_data2;
wire [31:0] DBData; //from the two_way_sel behind RAM 

RegisterFile regFile(
	.Read_reg1(rs),
	.Read_reg2(rt),
	.WE(RegWre),
	.CLK(CLK),
	.Write_reg(Write_reg),
	.Write_data(DBData),
	.Read_data1(Read_data1),
	.Read_data2(Read_data2)
	);

wire [31:0] result; //from ALU32
wire [31:0] DataOutFromRAM;

RAM ram_inst(
	.Daddr(result),
	.DataIn(Read_data2),
	.RD(RD),
	.WR(WR),
	.CLK(CLK),
	.DataOut(DataOutFromRAM)
	);

assign DBData = (0 == DBDataSrc)? result:DataOutFromRAM;

wire [31:0] InALU_A;
wire [31:0] InALU_B;

assign InALU_A = (0 == ALUSrcA)? Read_data1:Ext_sa;
assign InALU_B = (0 == ALUSrcB)? Read_data2:Ext_immediate;

wire zero;
wire sign;

ALU32 alu32(
	.ALUopcode(ALUOp),
	.rega(InALU_A),
	.regb(InALU_B),
	.zero(zero),
	.sign(sign),
	.result(result)
	);

ControlUnit control_unit(
	.op(op),
	.zero(zero),
	.sign(sign),
	.PCWre(PCWre),
	.ALUSrcA(ALUSrcA),
	.ALUSrcB(ALUSrcB),
	.DBDataSrc(DBDataSrc),
	.RegWre(RegWre),
	.InsMemRW(InsMemRW),
	.RD(RD),
	.WR(WR),
	.RegDst(RegDst),
	.ExtSel(ExtSel),
	.PCSrc(PCSrc),
	.ALUOp(ALUOp)
	);

//PCSel
wire [31:0] PCFromJIns;
wire [31:0] PCFromBranch;
//PCFromJrIns is Read_data1

assign PCFromBranch = (Ext_immediate << 2) + PCAddedFour;
assign PCFromJIns = {PCAddedFour[31:28], address, 1'b0, 1'b0};

Four_Way_Selector PCSel(
	.In0(PCAddedFour),
	.In1(PCFromBranch),
	.In2(PCFromJIns),
	.In3(Read_data1),
	.Selector(PCSrc),
	.Out(IAddrIn)
	);

wire clk1000, clk190;
	
clkdiv clk(
    .reset(Reset),
    .mclk(mclk),
    .clk190(clk190),
    .clk1000(clk1000)
);

wire [7:0]out1;
wire [7:0]out2;

display dis(
    .SW_in(SW_in),
    .reset(Reset),
    .PC(IAddrOut[7:0]),
    .PCNext(IAddrIn[7:0]),
    .RSAddr({3'b000,rs}),
    .RSData(Read_data1[7:0]),
    .RTAddr({3'b000,rt}),
    .RTData(Read_data2[7:0]),
    .ALUResult(result[7:0]),
    .DB(DBData[7:0]),
    .out1(out1),
    .out2(out2)
);

Show show(
    .Reset(Reset),
    .CLK(clk190),
    .in1(out1),
    .in2(out2),
    .place(place),
    .code(code)
);

avoidShake avshake(
	.clk1000(clk1000),
//	.Reset(Reset),
	.key_in(CLK_BUTN),
	.key_out(CLK)
	);

endmodule
