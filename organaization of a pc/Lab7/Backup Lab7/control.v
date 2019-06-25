`include "constants.h"

/************** Main control in ID pipe stage  *************/
module control_main(output reg RegDst,
                output reg Branch,  
                output reg MemRead,
                output reg MemWrite,  
                output reg MemToReg,  
                output reg ALUSrc,  
                output reg RegWrite,  
                output reg [1:0] ALUcntrl,  
                input [5:0] opcode,
		output reg BneFlag,
		output reg Jump);

  always @(*) 
   begin
     case (opcode)
      `R_FORMAT: 
          begin 
	    BneFlag = 1'b0;
	    Jump = 1'b0;
            RegDst = 1'b1;
            MemRead = 1'b0;
            MemWrite = 1'b0;
            MemToReg = 1'b0;
            ALUSrc = 1'b0;
            RegWrite = 1'b1;
            Branch = 1'b0;         
            ALUcntrl  = 2'b10; // R             
          end
       `LW :   
           begin
	    BneFlag = 1'b0; 
	    Jump = 1'b0;
            RegDst = 1'b0;
            MemRead = 1'b1;
            MemWrite = 1'b0;
            MemToReg = 1'b1;
            ALUSrc = 1'b1;
            RegWrite = 1'b1;
            Branch = 1'b0;
            ALUcntrl  = 2'b00; // add
           end
        `SW :   
           begin
	    BneFlag = 1'b0; 
	    Jump = 1'b0;
            RegDst = 1'b0;
            MemRead = 1'b0;
            MemWrite = 1'b1;
            MemToReg = 1'b0;
            ALUSrc = 1'b1;
            RegWrite = 1'b0;
            Branch = 1'b0;
            ALUcntrl  = 2'b00; // add
           end
       `BEQ:  
           begin
	    BneFlag = 1'b0;
            Jump = 1'b0; 
            RegDst = 1'b0;
            MemRead = 1'b0;
            MemWrite = 1'b0;
            MemToReg = 1'b0;
            ALUSrc = 1'b0;
            RegWrite = 1'b0;
            Branch = 1'b1;
            ALUcntrl = 2'b01; // sub
           end
	`BNE:  
           begin
	    Jump = 1'b0; 
            RegDst = 1'b0;
            MemRead = 1'b0;
            MemWrite = 1'b0;
            MemToReg = 1'b0;
            ALUSrc = 1'b0;
            RegWrite = 1'b0;
	    BneFlag <= 1'b1;
            Branch = 1'b1;
            ALUcntrl = 2'b01; // sub
           end
	 `ADDI:
	   begin
	    BneFlag = 1'b0;
            Jump = 1'b0; 
            RegDst = 1'b0;
            MemRead = 1'b0;
            MemWrite = 1'b0;
            MemToReg = 1'b0;
            ALUSrc = 1'b1;
            RegWrite = 1'b1;
            Branch = 1'b0;
            ALUcntrl = 2'b00;
	   end
	`JUMP:
	   begin
	    BneFlag = 1'b0;
	    Jump = 1'b1;
	    RegDst = 1'b0;
	    MemRead = 1'b0;
            MemWrite = 1'b0;
            MemToReg = 1'b0;
            ALUSrc = 1'b0;
            RegWrite = 1'b0;
            Branch = 1'b0;
            ALUcntrl = 2'b00; //add	
	   end
       default:
           begin
	    BneFlag = 1'b0;
            Jump = 1'b0;
            RegDst = 1'b0;
            MemRead = 1'b0;
            MemWrite = 1'b0;
            MemToReg = 1'b0;
            ALUSrc = 1'b0;
            RegWrite = 1'b0;
            ALUcntrl = 2'b00; 
         end
      endcase
    end // always
endmodule


/**************** Module for Bypass Detection in EX pipe stage goes here  *********/
 module  control_bypass_ex(output reg [1:0] bypassA,
                       output reg [1:0] bypassB,
                       input [4:0] idex_rs,
                       input [4:0] idex_rt,
                       input [4:0] exmem_rd,
                       input [4:0] memwb_rd,
                       input       exmem_regwrite,
                       input       memwb_regwrite);
       
	always@* begin
		if(exmem_regwrite && (exmem_rd != 0) && (exmem_rd == idex_rs))
			bypassA = 2;
		else if(memwb_regwrite && (memwb_rd != 0) && (memwb_rd == idex_rs) && ((exmem_rd != idex_rs) || (exmem_regwrite == 0)))
			bypassA = 1;
		else 
			bypassA = 0;
	end

	always @* begin
		if(exmem_regwrite && (exmem_rd != 0) && (exmem_rd == idex_rt))
			bypassB = 2;
		else if(memwb_regwrite && (memwb_rd != 0) && (memwb_rd == idex_rt) && ((exmem_rd != idex_rt) || (exmem_regwrite == 0)))
			bypassB = 1;
		else 
			bypassB = 0;
	end
endmodule          
                       

/**************** Module for Stall Detection in ID pipe stage goes here  *********/
module Hazard_Detection_Unit(idex_rt,idex_memread,ifid_register_rt,ifid_register_rs,PC_Write,IFID_Write,bubble_idex);          
 	input wire [4:0] idex_rt;
	input wire idex_memread;
	input wire [4:0] ifid_register_rt,ifid_register_rs;
	output reg PC_Write,IFID_Write, bubble_idex;
	
	always@*begin
		if((idex_memread == 1) && ((idex_rt == ifid_register_rs) || (idex_rt == ifid_register_rt)))
			begin
				PC_Write <= 0;
				IFID_Write <= 0;
				 bubble_idex <= 1;
			end		
		else
			begin
				PC_Write <= 1;
				IFID_Write <= 1;
				 bubble_idex <= 0;
			end
	end
endmodule                      

/************** control for ALU control in EX pipe stage  *************/
module control_alu(output reg [3:0] ALUOp,                  
               input [1:0] ALUcntrl,
               input [5:0] func);

  always @(ALUcntrl or func)  
    begin
      case (ALUcntrl)
        2'b10: 
           begin
             case (func)//R-FORMAT
              6'b100000: ALUOp = 4'b0010; // add
              6'b100010: ALUOp = 4'b0110; // sub
              6'b100100: ALUOp = 4'b0000; // and
              6'b100101: ALUOp = 4'b0001; // or
              6'b100111: ALUOp = 4'b1100; // nor
              6'b101010: ALUOp = 4'b0111; // slt
              6'b000000: ALUOp = 4'b1010; // sll
              6'b000100: ALUOp = 4'b1010; // sllv
	      6'b100110: ALUOp = 4'b0100; // xor
              default: ALUOp = 4'b0000;       
             endcase 
          end   
        2'b00: 
              ALUOp  = 4'b0010; // add
        2'b01: 
              ALUOp = 4'b0110; // sub
        default:
              ALUOp = 4'b0000;
     endcase
    end
endmodule

