/***********************************************************************************************/
/*********************************  MIPS 5-stage pipeline implementation ***********************/
/***********************************************************************************************/

module cpu(input clock, input reset);
 reg [31:0] PC;
 reg [31:0] IFID_PCplus4,IDEX_PCplus4,EXMEM_PCplus4;
 reg [31:0] IFID_instr;
 reg [31:0] IDEX_rdA, IDEX_rdB, IDEX_signExtend;
 reg [4:0]  IDEX_instr_rt, IDEX_instr_rs, IDEX_instr_rd;
 reg        IDEX_RegDst, IDEX_ALUSrc;
 reg [1:0]  IDEX_ALUcntrl;
 reg        IDEX_Branch, IDEX_MemRead, IDEX_MemWrite;
 reg        IDEX_MemToReg, IDEX_RegWrite;
 reg [4:0]  EXMEM_RegWriteAddr, EXMEM_instr_rd;
 reg [31:0] EXMEM_ALUOut;
 reg [31:0] EXMEM_MemWriteData,EXMEM_signExtend;
 reg        EXMEM_Branch, EXMEM_MemRead, EXMEM_MemWrite, EXMEM_RegWrite, EXMEM_MemToReg,EXMEM_Zero;
 reg [31:0] MEMWB_DMemOut;
 reg [4:0]  MEMWB_RegWriteAddr, MEMWB_instr_rd;
 reg [31:0] MEMWB_ALUOut;
 reg        MEMWB_MemToReg, MEMWB_RegWrite,IDEX_BneFlag, EXMEM_BneFlag;
 wire [31:0] instr, ALUOut, rdA, rdB, signExtend,shamtExtended, DMemOut, wRegData, PCIncr;
 wire Zero, RegDst, MemRead, MemWrite, MemToReg, ALUSrc, RegWrite, Branch, BneFlag,branching;
 wire [31:0] PC_Jump, PC_Branch;
 wire [5:0] opcode, func;
 wire [4:0] instr_rs, instr_shamt, instr_rt, instr_rd, RegWriteAddr;
 wire [3:0] ALUOp;
 wire [1:0] ALUcntrl;
 wire [15:0] imm;
 wire [1:0] ForwardA,ForwardB;
 wire [31:0] ALUInA, ALUInB,Mux_InA,Mux_InB;
 wire PC_Write,IFID_Write, bubble_idex,Jump,PCSrc;
 wire [4:0] shamt;
 reg [4:0] IDEX_shamt;

/***************** Instruction Fetch Unit (IF)  ****************/
 always @(posedge clock or negedge reset)
  begin
    if (reset == 1'b0)
       PC <= -1;
    else if (PC == -1)
       PC <= 0;
    else if ( PCSrc == 1 )
       PC <= PC_Branch;
    else if (PC_Write == 0)
       PC <= PC;
    else if ( Jump )
       PC <= PC_Jump;
    else
       PC <= PC + 4;
  end

assign branching = (EXMEM_BneFlag? ~EXMEM_Zero : EXMEM_Zero);
assign PCSrc = (branching&&EXMEM_Branch);
assign PC_Branch = (EXMEM_signExtend << 2) + EXMEM_PCplus4;
assign PC_Jump = { IFID_PCplus4 [31:28], IFID_instr [25:0], 2'b00 };



  // IFID pipeline register
 always @(posedge clock or negedge reset)
  begin
    if (reset == 1'b0 || Jump == 1'b1 || PCSrc == 1'b1)
      begin
       IFID_PCplus4 <= 32'b0;
       IFID_instr <= 32'b0;
    end
    else
      begin
	if(IFID_Write == 1)
      begin
       IFID_PCplus4 <= PC + 32'd4;
       IFID_instr <= instr;
      end
    end
  end

// Instruction memory 1KB
Memory cpu_IMem(clock, reset, 1'b1, 1'b0, PC>>2, 32'b0, instr);

/***************** Instruction Decode Unit (ID)  ****************/
assign opcode = IFID_instr[31:26];
assign func = IFID_instr[5:0];
assign instr_rs = IFID_instr[25:21];
assign instr_rt = IFID_instr[20:16];
assign instr_rd = IFID_instr[15:11];
assign instr_shamt = IFID_instr[10:6];
assign shamtExtended = {{27{instr_shamt[4]}}, instr_shamt};
assign imm = IFID_instr[15:0];
assign signExtend = {{16{imm[15]}}, imm};
assign shamt = IFID_instr[10:6];

// Register file
RegFile cpu_regs(clock, reset, instr_rs, instr_rt, MEMWB_RegWriteAddr, MEMWB_RegWrite, wRegData, rdA, rdB);

  // IDEX pipeline register
 always @(posedge clock or negedge reset)
  begin
    if (reset == 1'b0 ||  bubble_idex == 1'b1 || PCSrc == 1'b1)
      begin
       IDEX_rdA <= 32'b0;
       IDEX_PCplus4 <= 32'b0;
       IDEX_rdB <= 32'b0;
       IDEX_signExtend <= 32'b0;
       IDEX_instr_rd <= 5'b0;
       IDEX_instr_rs <= 5'b0;
       IDEX_instr_rt <= 5'b0;
       IDEX_RegDst <= 1'b0;
       IDEX_ALUcntrl <= 2'b0;
       IDEX_ALUSrc <= 1'b0;
       IDEX_Branch <= 1'b0;
       IDEX_MemRead <= 1'b0;
       IDEX_MemWrite <= 1'b0;
       IDEX_MemToReg <= 1'b0;
       IDEX_RegWrite <= 1'b0;
       IDEX_shamt <= 0;
       IDEX_BneFlag <= 0;
    end
    else
      begin
       IDEX_rdA <= rdA;
       IDEX_rdB <= rdB;
       IDEX_PCplus4 <= IFID_PCplus4;
       IDEX_signExtend <= signExtend;
       IDEX_instr_rd <= instr_rd;
       IDEX_instr_rs <= instr_rs;
       IDEX_instr_rt <= instr_rt;
       IDEX_RegDst <= RegDst;
       IDEX_ALUcntrl <= ALUcntrl;
       IDEX_ALUSrc <= ALUSrc;
       IDEX_Branch <= Branch;
       IDEX_MemRead <= MemRead;
       IDEX_MemWrite <= MemWrite;
       IDEX_MemToReg <= MemToReg;
       IDEX_RegWrite <= RegWrite;
       IDEX_shamt <= shamt;
       IDEX_BneFlag <= BneFlag;
    end
  end

// Main Control Unit
control_main control_main (RegDst,
                  Branch,
                  MemRead,
                  MemWrite,
                  MemToReg,
                  ALUSrc,
                  RegWrite,
                  ALUcntrl,
                  opcode,
		  BneFlag,
		  Jump);

// Instantiation of Control Unit that generates stalls goes here

Hazard_Detection_Unit hazard_detector(IDEX_instr_rt,IDEX_MemRead,instr_rt,instr_rs,PC_Write,IFID_Write, bubble_idex);

/***************** Execution Unit (EX)  ****************/

assign Mux_InA = IDEX_rdA;
assign ALUInB = (IDEX_ALUSrc == 1'b0) ? Mux_InB  : IDEX_signExtend;

//  ALU
ALU  #32 cpu_alu(ALUOut, Zero, ALUInA, ALUInB, ALUOp ,IDEX_shamt);

assign RegWriteAddr = (IDEX_RegDst==1'b0) ? IDEX_instr_rt : IDEX_instr_rd;

 // EXMEM pipeline register
 always @(posedge clock or negedge reset)
  begin
    if (reset == 1'b0 || PCSrc == 1'b1)
      begin
       EXMEM_ALUOut <= 32'b0;
       EXMEM_PCplus4 <= 32'b0;
       EXMEM_signExtend <= 32'b0;
       EXMEM_RegWriteAddr <= 5'b0;
       EXMEM_MemWriteData <= 32'b0;
       EXMEM_Zero <= 1'b0;
       EXMEM_Branch <= 1'b0;
       EXMEM_MemRead <= 1'b0;
       EXMEM_MemWrite <= 1'b0;
       EXMEM_MemToReg <= 1'b0;
       EXMEM_RegWrite <= 1'b0;
       EXMEM_BneFlag <= 1'b0;
      end
    else
      begin
       EXMEM_ALUOut <= ALUOut;
       EXMEM_PCplus4 <= IDEX_PCplus4;
       EXMEM_signExtend <= IDEX_signExtend;
       EXMEM_RegWriteAddr <= RegWriteAddr;
       EXMEM_MemWriteData <= Mux_InB;
       EXMEM_Zero <= Zero;
       EXMEM_Branch <= IDEX_Branch;
       EXMEM_MemRead <= IDEX_MemRead;
       EXMEM_MemWrite <= IDEX_MemWrite;
       EXMEM_MemToReg <= IDEX_MemToReg;
       EXMEM_RegWrite <= IDEX_RegWrite;
       EXMEM_BneFlag <= IDEX_BneFlag;
      end
  end

  // ALU control
  control_alu control_alu(ALUOp, IDEX_ALUcntrl, IDEX_signExtend[5:0]);

  // Instantiation of control logic for Forwarding goes here
  control_bypass_ex Forwarding_Unit(ForwardA, ForwardB,IDEX_instr_rs, IDEX_instr_rt, EXMEM_RegWriteAddr, MEMWB_RegWriteAddr, EXMEM_RegWrite, MEMWB_RegWrite);

assign ALUInA = ((ForwardA == 0) ? Mux_InA : ((ForwardA == 1) ? wRegData :  ((ForwardA == 2)? EXMEM_ALUOut : 2'bxx)));
assign Mux_InB = ((ForwardB == 0) ? IDEX_rdB : ((ForwardB == 1) ? wRegData :  ((ForwardB == 2)? EXMEM_ALUOut : 2'bxx)));

/***************** Memory Unit (MEM)  ****************/

// Data memory 1KB
Memory cpu_DMem(clock, reset, EXMEM_MemRead, EXMEM_MemWrite, EXMEM_ALUOut, EXMEM_MemWriteData, DMemOut);

// MEMWB pipeline register
 always @(posedge clock or negedge reset)
  begin
    if (reset == 1'b0)
      begin
       MEMWB_DMemOut <= 32'b0;
       MEMWB_ALUOut <= 32'b0;
       MEMWB_RegWriteAddr <= 5'b0;
       MEMWB_MemToReg <= 1'b0;
       MEMWB_RegWrite <= 1'b0;
      end
    else
      begin
       MEMWB_DMemOut <= DMemOut;
       MEMWB_ALUOut <= EXMEM_ALUOut;
       MEMWB_RegWriteAddr <= EXMEM_RegWriteAddr;
       MEMWB_MemToReg <= EXMEM_MemToReg;
       MEMWB_RegWrite <= EXMEM_RegWrite;
      end
  end

/***************** WriteBack Unit (WB)  ****************/
assign wRegData = (MEMWB_MemToReg == 1'b0) ? MEMWB_ALUOut : MEMWB_DMemOut;

endmodule
