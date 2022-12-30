/* Control signal unit.
 *	Inputs include clock, reset, overflow, negative, is_zero, and opcode.
 *		Ouputs include ALUOp, xfer_size, BL_op, BR_op, and the following signals: Reg2Loc, 
 *		UncondBr, BrTaken, MemRead, MemtoReg, MemWrite, ALUSrc, RegWrite, Flag, and immediate.
 *
 */
 
`timescale 10ps/1fs

// Given op code, this module will return control signals (controls muxes, ALU, reg file, data 
// memory, etc.) to execute the provided instruction. The inputs "overflow" and "negative"
// come from the ALU, and they help execute the B.LT instruction. The output logic signals 
// beside Flag and immediate are perform the same function as the control datapath provided in lecture.
// Flag sets the flag for overflow, carry out, negative, or zero from the ALU result. 
// Signal immediate tells the CPU that an immediate operation is being performed. BL_op and BR_op
// indicate if the BL or BR instruction is called. cbz_op, sturop, and loadop signal whether a CBZ, STUR,
// or LDUR instruction is the current instruction. 
module control(
	input logic clk, reset,
	input logic [10:0] decopcode,
	input logic [4:0] decRd,
	input logic is_zero, is_overflow, is_neg, negative, overflow, exFlag,
	input logic [63:0] Da,
	output logic BL_op, BR_op, cbz_op, sturop, loadop,
	output logic [2:0] ALUOp,
	output logic Reg2Loc, UncondBr, BrTaken, MemRead, MemtoReg, MemWrite, ALUSrc, RegWrite, Flag, immediate,
	output logic [3:0] xfer_size
);
	
	// B.LT brTaken
	logic brTakenSignal;
	assign brTakenSignal = (~exFlag & (negative ^ overflow)) | (exFlag & (is_neg ^ is_overflow));
	
	// CBZ brTaken
	logic cbzSignal;
	assign cbzSignal = (Da == 64'b0);

	// Use an always_comb block to determine correct control signals given an op code
	always_comb begin
			// Use casex since the bits with "x" are don't cares
			casex(decopcode)
				// ADDI: 1001000100
				11'b1001000100x: begin
					Reg2Loc = 1'bx;
					UncondBr = 1'b0; 
					BrTaken = 1'b0; 
					MemRead = 1'b0;
					MemtoReg = 1'b0;
					ALUOp = 3'b010; 
					MemWrite = 1'b0; 
					ALUSrc = 1'b1;
					RegWrite = (decRd == 5'b11111) ? 1'b0 : 1'b1;
					Flag = 1'b0;
					immediate = 1'b1;
					xfer_size = 4'bxxxx;
					BL_op = 1'b0;
					BR_op = 1'b0;
					cbz_op = 1'b0;
					sturop = 1'b0;
					loadop = 1'b0;
				end
				
				// ADDS: 10101011000
				11'b10101011000: begin
					Reg2Loc = 1'b1;
					UncondBr = 1'bx;
					BrTaken = 1'b0; 
					MemRead = 1'b0;
					MemtoReg = 1'b0;
					ALUOp = 3'b010; 
					MemWrite = 1'b0; 
					ALUSrc = 1'b0;
					RegWrite = 1'b1;
					Flag = 1'b1;
					immediate = 1'b0;
					xfer_size = 4'bxxxx;
					BL_op = 1'b0;
					BR_op = 1'b0;
					cbz_op = 1'b0;
					sturop = 1'b0;
					loadop = 1'b0;
				end
				
				// B Imm26: 000101
				11'b000101xxxxx: begin
					Reg2Loc = 1'bx;
					UncondBr = 1'b1;
					BrTaken = 1'b1; 
					MemRead = 1'bx;
					MemtoReg = 1'bx;
					ALUOp = 3'bxxx; 
					MemWrite = 1'b0; 
					ALUSrc = 1'bx;
					RegWrite = 1'b0;
					Flag = 1'b0;
					xfer_size = 4'bxxxx;
					immediate = 1'b0;
					BL_op = 1'b0;
					BR_op = 1'b0;
					cbz_op = 1'b0;
					sturop = 1'b0;
					loadop = 1'b0;
				end

				
				// B.LT Imm19: 01010100 
				// if (flags.negative != flags.overflow) PC = PC + SE(Imm19<<2) ... get flags from execute
				11'b01010100xxx: begin
					Reg2Loc = 1'bx;
					UncondBr = 1'b0;
					BrTaken = (brTakenSignal); // 1 if negative != overflow 
					MemRead = 1'b0;
					MemtoReg = 1'bx; 
					ALUOp = 3'bxxx; 
					MemWrite = 1'b0;
					ALUSrc = 1'bx; 
					RegWrite = 1'b0;
					Flag = 1'b0;
					immediate = 1'bx;
					xfer_size = 4'bxxxx;
					BL_op = 1'b0;
					BR_op = 1'b0;
					cbz_op = 1'b0;
					sturop = 1'b0;
					loadop = 1'b0;
				end
				
				// BL Imm26: 100101
				// PC = PC + SE(Imm26<<2)
				// X30 = PC + 4
				11'b100101xxxxx: begin
					Reg2Loc = 1'bx;
					UncondBr = 1'b1;
					BrTaken = 1'b1; 
					MemRead = 1'b0;
					MemtoReg = 1'b0; 
					ALUOp = 3'b010;
					MemWrite = 1'b0;
					ALUSrc = 1'b1; 
					RegWrite = 1'b1; 
					Flag = 1'b0;
					immediate = 1'b1;
					xfer_size = 4'bxxxx;
					BL_op = 1'b1;
					BR_op = 1'b0;
					cbz_op = 1'b0;
					sturop = 1'b0;
					loadop = 1'b0;
				end
				
				
				// BR Rd: 11010110000
				// PC = Reg[Rd]
				11'b11010110000: begin
					Reg2Loc = 1'b0;
					UncondBr = 1'bx;
					BrTaken = 1'b0; 
					MemRead = 1'b0;
					MemtoReg = 1'bx; 
					ALUOp = 3'bxxx; 
					MemWrite = 1'b0;
					ALUSrc = 1'b0; 
					RegWrite = 1'b0;
					Flag = 1'b0;
					BL_op = 1'b0;
					BR_op = 1'b1;
					cbz_op = 1'b0;
					sturop = 1'b0;
					loadop = 1'b0;
				end
				
				// CBZ: 10110100
				11'b10110100xxx: begin
					Reg2Loc = 1'b0;
					UncondBr = 1'b0;
					BrTaken = cbzSignal;
					MemRead = 1'bx;
					MemtoReg = 1'bx; 
					ALUOp = 3'b000; 
					MemWrite = 1'b0;
					ALUSrc = 1'b0; 
					RegWrite = 1'b0;
					Flag = 1'b0;
					BL_op = 1'b0;
					BR_op = 1'b0;
					cbz_op = 1'b1;
					sturop = 1'b0;
					loadop = 1'b0;
				end
				
				// LDUR: 11111000010
				11'b11111000010: begin
					Reg2Loc = 1'bx;
 				   UncondBr = 1'bx;
					BrTaken = 1'b0; 
					MemRead = 1'b1; 
					MemtoReg = 1'b1;
					ALUOp = 3'b010; 
					MemWrite = 1'b0; 
					ALUSrc = 1'b1;
					RegWrite = 1'b1;
					Flag = 1'b0;
					immediate = 1'b0;
					xfer_size = 4'b1000;
					BL_op = 1'b0;
					BR_op = 1'b0;
					cbz_op = 1'b0;
					sturop = 1'b0;
					loadop = 1'b1;
				end
				
				// STUR: 11111000000
				11'b11111000000: begin
					Reg2Loc = 1'b0;
					UncondBr = 1'bx;
					BrTaken = 1'b0; 
					MemRead = 1'b0; 
					MemtoReg = 1'bx;
					ALUOp = 3'b010; 
					MemWrite = 1'b1;
					ALUSrc = 1'b1;
					RegWrite = 1'b0;
					Flag = 1'b0;
					immediate = 1'b0;
					xfer_size = 4'b1000;
					BL_op = 1'b0;
					BR_op = 1'b0;
					cbz_op = 1'b0;
					sturop = 1'b1;
					loadop = 1'b0;
				end
				
				// SUBS: 11101011000
				11'b11101011000: begin
					Reg2Loc = 1'b1;
					UncondBr = 1'b0;
					BrTaken = 1'b0;
					MemRead = 1'b0;
					MemtoReg = 1'b0;
					ALUOp = 3'b011; 
					MemWrite = 1'b0; 
					ALUSrc = 1'b0;
					RegWrite = 1'b1;
					Flag = 1'b1;
					immediate = 1'b0;
					xfer_size = 4'bxxxx;
					BL_op = 1'b0;
					BR_op = 1'b0;
					cbz_op = 1'b0;
					sturop = 1'b0;
					loadop = 1'b0;
				end
			endcase
	end
endmodule

//// Ensure that for the given opcode, the signal outputs for control signals are correct. 
//// This module tests all instructions required for Lab 4. 
module control_testbench();
	logic clk, reset, is_overflow, is_neg;
	logic [10:0] decopcode;
	logic [4:0] decRd;
	logic [2:0] ALUOp;
	logic Reg2Loc, UncondBr, BrTaken, MemRead, MemtoReg, MemWrite, ALUSrc, RegWrite, Flag, immediate;
	logic [3:0] xfer_size;
	logic is_zero;
	logic BL_op, BR_op;
	logic [63:0] Da;
	logic cbz_op, sturop, loadop;
	logic negative, overflow;
	logic exFlag;
	
	control dut (.clk, .reset, .is_overflow, .is_neg, .decopcode, .decRd, .ALUOp, .Reg2Loc, .UncondBr, .BrTaken, .MemRead, .MemtoReg, .MemWrite, .ALUSrc, .RegWrite, .Flag, .immediate, .xfer_size, .is_zero, .BL_op, .BR_op, .Da, .cbz_op, .sturop, .loadop, .negative, .overflow, .exFlag);

	// Set up a simulated clock.
	parameter CLOCK_PERIOD=100;
	initial begin
		clk <= 0;
		forever #(CLOCK_PERIOD/2) clk <= ~clk; #1000;
	end
	
	initial begin
	
		reset <= 0; overflow <= 0; negative <= 0; is_zero <= 0; decRd <= 5'b11111; #1000;
		
		// ADDI
		decopcode <= 11'b1001000100x; #1000;
		for (int i = 0; i < 64; i++) begin
			{overflow, negative, is_zero, is_overflow, is_neg, exFlag} = i; #1000;
			if (i >= 32) begin
				decRd = 5'b11110; #1000;
			end
		end
		
		// ADDS
		decopcode <= 11'b10101011000; #1000;
		for (int i = 0; i < 64; i++) begin
			{overflow, negative, is_zero, is_overflow, is_neg, exFlag} = i; #1000;
		end
		
		// B Imm26
		decopcode <= 11'b000101xxxxx; #1000;
		for (int i = 0; i < 64; i++) begin
			{overflow, negative, is_zero, is_overflow, is_neg, exFlag} = i; #1000;
		end
		
		// B.LT Imm19
		// if (flags.negative != flags.overflow) PC = PC + SE(Imm19<<2)
		decopcode <= 11'b01010100xxx; #1000;
		for (int i = 0; i < 64; i++) begin
			{overflow, negative, is_zero, is_overflow, is_neg, exFlag} = i; #1000;
		end
		
		// BL Imm26
		// PC = PC + SE(Imm26<<2)
		decopcode <= 11'b100101xxxxx; #1000;
		for (int i = 0; i < 64; i++) begin
			{overflow, negative, is_zero, is_overflow, is_neg, exFlag} = i; #1000;
		end
		
		// BR Rd
		// PC = Reg[Rd]
		decopcode <= 11'b11010110000; #1000;
		for (int i = 0; i < 64; i++) begin
			{overflow, negative, is_zero, is_overflow, is_neg, exFlag} = i; #1000;
		end
		
		// CBZ
		decopcode <= 11'b10110100xxx; #1000;
		for (int i = 0; i < 64; i++) begin
			{overflow, negative, is_zero, is_overflow, is_neg, exFlag} = i; #1000;
		end
		
		// LDUR
		decopcode <= 11'b11111000010; #1000;
		for (int i = 0; i < 64; i++) begin
			{overflow, negative, is_zero, is_overflow, is_neg, exFlag} = i; #1000;
		end
		
		// STUR
		decopcode <= 11'b11111000000; #1000;
		for (int i = 0; i < 64; i++) begin
			{overflow, negative, is_zero, is_overflow, is_neg, exFlag} = i; #1000;
		end
		
		// SUBS
		decopcode <= 11'b11101011000; #1000;
		for (int i = 0; i < 64; i++) begin
			{overflow, negative, is_zero, is_overflow, is_neg, exFlag} = i; #1000;
		end
		
	end
	
endmodule