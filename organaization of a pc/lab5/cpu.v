// Top level CPU unit. This is where you instantiate and interconnect all modules
// in library.v and fsm.v

module cpu (input clock, input reset);
 input clock, reset;
 //reg [31:0] PC;
integer i;
 wire [31:0] instr, ALUOut, rdA, rdB, wRegData, DMemOut,PC,inputB;
 wire [3:0] ADD_OP;
 wire [5:0] opcode, func;
 wire [4:0] instr_rs, instr_rt, instr_rd;
 wire [4:0] wAddr;
 wire IMem_ren;
 wire IMem_wen;
 reg IMemRead;
 reg [31:0] IMem_din,extended;
 wire [3:0] ALUCtrl;
 wire [4:0] raA, raB, wa;
 wire RegWrite;
 wire [15:0] immediate;
 wire [1:0] ALUOp;
 wire branching;
 wire BneFlag,Branch,zero;
 wire [31:0] pc_four,pc_new,pc_branch;
 wire [31:0] plus4;

//connecting ProgCounter with Instruction Mem
assign IMem_ren=1'b1;
assign IMem_wen=1'b0;
assign plus4=32'd4; //MUST BE PC = PC + 4 BUT IT DOES NOT WORK
assign ADD_OP=4'd2;
assign opcode = instr[31:26];
assign func = instr[5:0];
assign raA = instr[25:21];
assign raB = instr[20:16];
assign wa = instr[15:11];
assign immediate = instr[15:0];


//Instruction Memory
Memory cpu_IMem(.ren(IMem_ren), .wen(IMem_wen), .addr(PC>>2), .din(IMem_din), .dout(instr)); // Instruction memory 1KB

//Program Counter.
ProgCounter pcount(.clock(clock),.reset(reset),.pc_new(pc_new),.pc(PC));
//ALU used to increase our Program counter by a standard amount.
ALU pcount_ALU4(.out(pc_four) , .zero(zero) , .inA(PC) , .inB(plus4) , .op(ADD_OP));
//ALUresult used when we have to execute branch commmands
ALU pcount_ALUbranch(.out(pc_branch) , .zero(zero) , .inA(pc_four) , .inB(extended), .op(ADD_OP));

/*always@(posedge clock)begin
	PC=PC+4;
		if(BneFlag)
			if(Branch & (~zero))
				PC <= PC + extended;
		else
			if(Branch & zero)
				PC <= PC + extended;
end
*/

//Control Unit starts
//Main Decoder
MainDecoder decoder(.RegWrite(RegWrite),.RegDst(RegDst),.ALUSrc(ALUSrc),.Branch(Branch),.MemWrite(MemWrite),.MemToReg(MemToReg),.MemRead(MemRead),.BneFlag(BneFlag),.OPcode(opcode),.ALUOp(ALUOp));
//Connecting ALUDecoder with our MIPS ALU
ALUDecoder aluctl(.Function(func) , .ALUOp(ALUOp), .ALUCtrl(ALUCtrl));
//Control Unit ends

// MIPS ALU
ALU myALU(.out(ALUOut) , .zero(zero) , .inA(rdA) , .inB(inputB) , .op(ALUCtrl));

// Register file
RegFile cpu_regs(.clock(clock), .reset(reset), .raA(raA), .raB(raB), .wa(wAddr), .wen(RegWrite), .wd(wRegData), .rdA(rdA), .rdB(rdB));

//Data Memory
Memory DataMemory(.ren(MemRead),.wen(MemWrite),.addr(ALUOut),.din(rdB),.dout(DMemOut));

 //"MUXes" are coming
assign wAddr = (RegDst? wa:raB); //WriteAddress
	//sign extension
//assign extended [15:0] = immediate[15:0];
//assign extended = {{16{immediate[15]}}, immediate};
always@(immediate)begin
	for (i = 0; i < 16; i = i+1)
		extended[i] = immediate[i];
	for (i = 0; i < 32; i = i+1)
		extended[15+i] = immediate[15];
	extended = extended << 2;
end
	//ALU input MUX
assign inputB = (ALUSrc? extended:rdB);
	//Data to write
assign wRegData = (MemToReg? DMemOut:ALUOut);
	//shift left by 2
//assign extended = extended << 2;
	//Program counter's new value depending on what our command is. (Branch or R-Format)
assign branching = (BneFlag? ~zero : zero);
assign pc_new = ((branching&&Branch) ? pc_branch:pc_four);

endmodule
