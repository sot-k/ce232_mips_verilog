`include "constants.h"
`timescale 1ns/1ps

//
// Small ALU. Inputs: inA, inB. Output: out. 
// Operations: bitwise and (op = 0)
//             bitwise or  (op = 1)
//             addition (op = 2)
//             subtraction (op = 6)
//             slt  (op = 7)
//             nor (op = 12)
module ALU (out, zero, inA, inB, op);
  parameter N = 32;
  output reg [N-1:0] out;
  output zero;
  input  [N-1:0] inA, inB;
  input    [3:0] op;

  always @(op,inA,inB) begin
	case(op)
		0: out <= inA & inB;
		1: out <= inA | inB;
		2: out <= inA + inB;
		6: out <= inA - inB;
		7: out <= ((inA<inB)?1:0);
		12: out <= ~(inA | inB);
 		default:begin
		 out <= 32'bx;
		 $display("[ALU] [WARN] Unknown Op code: %4d\n", op);
		end
	endcase
	end 	
	assign zero = (out == 0);
endmodule


// Memory (active 1024 words, from 10 address lsbs).
// Read : enable ren, address addr, data dout
// Write: enable wen, address addr, data din.
module Memory (ren, wen, addr, din, dout);
  input         ren, wen;
  input  [31:0] addr, din;
  output [31:0] dout;

  reg [31:0] data[1023:0];
  wire [31:0] dout;

  always @(ren or wen)
    if (ren & wen)
      $display ("\nMemory ERROR (time %0d): ren and wen both active!\n", $time);

  always @(posedge ren or posedge wen) begin
    if (addr[31:12] != 0)
      $display("Memory WARNING (time %0d): address msbs are not zero\n", $time);
  end  

  assign dout = ((wen==1'b0) && (ren==1'b1)) ? data[addr[9:0]] : 32'bx;
  
  always @(din or wen or ren or addr)
   begin
    if ((wen == 1'b1) && (ren==1'b0))
        data[addr[9:0]] = din;
   end
endmodule


// Register File. Read ports: address raA, data rdA
//                            address raB, data rdB
//                Write port: address wa, data wd, enable wen.
module RegFile (clock, reset, raA, raB, wa, wen, wd, rdA, rdB);
  input clock, reset;
  input   [4:0] raA, raB, wa;
  input         wen;
  input  [31:0] wd;
  output reg [31:0] rdA, rdB;
  integer position;
  reg [31:0] data[31:0];
	
	always @(raA or raB or posedge reset)begin
		rdA =  data[raA];
		rdB =  data[raB];
		$display("[REGFILE] [%4d] ReadDataA %d,ReadDataB%d )\n",$time, rdA, rdB);
	end

	always @( negedge clock)begin //sync write
		if (wen&&reset)begin
			data[wa] <= wd;
			$display("[REGFILE] [%4d] Wrote data %2d, to %2d (WriteEnable: %d)\n",$time, wd, wa, wen);
		end
	end
	
	always @(negedge reset)begin //async reset
		for(position=0; position<32; position = position+1)begin
			data[position] = position;
		end
	end
endmodule


module ProgCounter(clock, reset, pc_new, pc);
input clock,reset;
output reg [31:0] pc;
input wire [31:0] pc_new;

	always@(posedge clock)begin
		pc= pc_new;
	end

	always@(negedge reset)begin
		pc=0;
	end
	
endmodule

module ALUDecoder(Function, ALUOp, ALUCtrl);
output reg [3 : 0] ALUCtrl;
input wire [1 : 0] ALUOp;
input wire [5 : 0] Function;
	
	always @(ALUOp or Function)begin
		case(ALUOp)
			2'b00:ALUCtrl=4'b0010; //lw and sw
			2'b01:ALUCtrl=4'b0110; // branch
			2'b10:begin
			case(Function)
				6'b100000:ALUCtrl<=4'd2; //(2)add
				6'b100010:ALUCtrl<=4'd6; //(6)sub
				6'b100100:ALUCtrl<=4'd0; //(0)and
				6'b100101:ALUCtrl<=4'd1; //(1)or
				6'b101010:ALUCtrl<=4'd7; //(7)slt
				default:ALUCtrl<=4'bxxxx;
			endcase
			end
			default:ALUCtrl=4'bxxxx;
		endcase
	end
endmodule 

module MainDecoder(RegWrite,RegDst,ALUSrc,Branch,MemWrite,MemToReg,MemRead,BneFlag,OPcode,ALUOp);
	output reg RegWrite,RegDst,ALUSrc,Branch,MemWrite,MemToReg,MemRead,BneFlag;
	output reg [1:0] ALUOp;
	input wire [5:0] OPcode;
	
	always@(OPcode)begin
		case(OPcode)
			6'b000000 :begin //R-Format
				RegWrite <= 1'b1;
				RegDst <= 1'b1;
				ALUSrc <= 1'b0;
				Branch <= 1'b0;
				MemWrite <= 1'b0;
				MemToReg <= 1'b0;
				MemRead <= 1'b0;
				BneFlag <= 1'b0;
				ALUOp <= 2'b10;
			end
			6'b100011 :begin //lw
				RegWrite <= 1'b1;
				RegDst <= 1'b0;
				ALUSrc <= 1'b1;
				Branch <= 1'b0;
				MemWrite <= 1'b0;
				MemToReg <= 1'b1;
				MemRead <= 1'b1;
				BneFlag <= 1'b0;
				ALUOp <= 2'b00;
			end
			6'b101011 :begin //sw
				RegWrite <= 1'b0;
				RegDst <= 1'bx;
				ALUSrc <= 1'b1;
				Branch <= 1'b0;
				MemWrite <= 1'b1;
				MemToReg <= 1'bx;
				MemRead <= 1'b0;
				BneFlag <= 1'b0;
				ALUOp <= 2'b00;
			end
			6'b000100 :begin //beq
				RegWrite <= 1'b0;
				RegDst <= 1'bx;
				ALUSrc <= 1'b0;
				Branch <= 1'b1;
				MemWrite <= 1'b0;
				MemToReg <= 1'bx;
				MemRead <= 1'b0;
				BneFlag <= 1'b0;
				ALUOp <= 2'b01;
			end
			6'b000101 :begin //BNE
				RegWrite <= 1'b0;
				RegDst <= 1'bx;
				ALUSrc <= 1'b0;
				Branch <= 1'b1;
				MemWrite <= 1'b0;
				MemToReg <= 1'bx;
				MemRead <= 1'b0;
				BneFlag <= 1'b1;
				ALUOp <= 2'b01;
			end
			default :begin
				RegWrite <= 1'b0;
				RegDst <= 1'b0;
				ALUSrc <= 1'bx;
				Branch <= 1'b0;
				MemWrite <= 1'b0;
				MemToReg <= 1'b0;
				MemRead <= 1'b0;
				BneFlag <= 1'b0;
				ALUOp <= 2'bxx;
			end
		endcase
	end
endmodule
