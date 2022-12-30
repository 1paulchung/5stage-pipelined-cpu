/* ID-EX Pipeline Register: Holds values between Instruction Decode (Stage 2) and Execute (Stage 3).
 * Inputs include clk, reset, ALUSrc, immediate, BL_op, MemWrite, MemRead, MemtoReg, RegWrite, Flag, UncondBr, 
 * 		BrTaken, loadop, Da, Db, ex_DAddr9, WriteData_or_noBrPC, noBrPC, Imm12, stur_Db, decInstruction,
 *			xfer_size, ALUOp, Rd_or_X30, idRn, and idRm. Outputs include exALUSrc, eximmediate, exBL_op, exMemWrite, 
 *			exMemRead, exMemtoReg, exRegWrite, exFlag, exUncondBr, exBrTaken, exloadop, exDa, exDb, exImm12, 
 *			exWriteData_or_noBrPC, exnoBrPC, exex_DAddr9, ex_stur_Db, exALUOp, exxfer_size, exRd_or_X30, exRn, exRm,
 *			and exinstruction;
 */

`timescale 10ps/1fs
module IDEXPipeReg (clk, reset, Da, Db, ex_DAddr9, ALUOp, ALUSrc, immediate, Imm12, BL_op, WriteData_or_noBrPC, 
						  noBrPC, xfer_size, MemWrite, MemRead, MemtoReg, Rd_or_X30, exALUSrc, eximmediate, exBL_op, exMemWrite,
						  exMemRead, exMemtoReg, exDa, exDb, exImm12, exWriteData_or_noBrPC, exnoBrPC, exALUOp, 
						  exex_DAddr9, exxfer_size, exRd_or_X30, idRn, exRn, idRm, exRm, RegWrite, exRegWrite, Flag, exFlag,
						  UncondBr, exUncondBr, BrTaken, exBrTaken, decInstruction, exinstruction, stur_Db, ex_stur_Db,
						  loadop, exloadop);

	input logic clk, reset;
	
	// ID signals
	input logic ALUSrc, immediate, BL_op, MemWrite, MemRead, MemtoReg, RegWrite, Flag, UncondBr, BrTaken, loadop;
	input logic [63:0] Da, Db, ex_DAddr9, WriteData_or_noBrPC, noBrPC, Imm12, stur_Db;
	input logic [31:0] decInstruction;
	input logic [3:0] xfer_size;
	input logic [2:0] ALUOp;
	input logic [4:0] Rd_or_X30, idRn, idRm;
	
	// EX signals
	output logic exALUSrc, eximmediate, exBL_op, exMemWrite, exMemRead, exMemtoReg, exRegWrite, exFlag, exUncondBr, exBrTaken, exloadop;
	output logic [63:0] exDa, exDb, exImm12, exWriteData_or_noBrPC, exnoBrPC, exex_DAddr9, ex_stur_Db; 
	output logic [2:0] exALUOp;
	output logic [3:0] exxfer_size;
	output logic [4:0] exRd_or_X30, exRn, exRm;
	output logic [31:0] exinstruction;

	// Da
	genvar i;
	generate 
		for (i = 0; i < 64; i++) begin: DaPipe
			D_FF holdDa(.q(exDa[i]), .d(Da[i]), .reset, .clk);
		end
	endgenerate
	
	// Db
	generate 
		for (i = 0; i < 64; i++) begin: DbPipe
			D_FF holdDb(.q(exDb[i]), .d(Db[i]), .reset, .clk);
		end
	endgenerate
	
	// stur_Db (for STUR operation)
	generate 
		for (i = 0; i < 64; i++) begin: DbsturPipe
			D_FF holdDb(.q(ex_stur_Db[i]), .d(stur_Db[i]), .reset, .clk);
		end
	endgenerate
	
	// Imm12
	generate 
		for (i = 0; i < 64; i++) begin: Imm12Pipe
			D_FF holdImm12(.q(exImm12[i]), .d(Imm12[i]), .reset, .clk);
		end
	endgenerate
	
	// WriteData_or_noBrPC
	generate 
		for (i = 0; i < 64; i++) begin: WriteData_or_noBrPCPipe
			D_FF holdWriteData_or_noBrPC(.q(exWriteData_or_noBrPC[i]), .d(WriteData_or_noBrPC[i]), .reset, .clk);
		end
	endgenerate
	
	// noBrPC
	generate 
		for (i = 0; i < 64; i++) begin: noBrPCPipe
			D_FF holdnoBrPC(.q(exnoBrPC[i]), .d(noBrPC[i]), .reset, .clk);
		end
	endgenerate
	
	// ex_DAddr9
	generate 
		for (i = 0; i < 64; i++) begin: ex_DAddr9Pipe
			D_FF holdex_DAddr9(.q(exex_DAddr9[i]), .d(ex_DAddr9[i]), .reset, .clk);
		end
	endgenerate
	
	// ALUOp
	generate 
		for (i = 0; i < 3; i++) begin: ALUOpPipe
			D_FF holdALUOp(.q(exALUOp[i]), .d(ALUOp[i]), .reset, .clk);
		end
	endgenerate
	
	// xfer_size
	generate 
		for (i = 0; i < 4; i++) begin: xfer_sizePipe
			D_FF holdxfer_size(.q(exxfer_size[i]), .d(xfer_size[i]), .reset, .clk);
		end
	endgenerate
	
	// Rd_or_X30
	generate 
		for (i = 0; i < 5; i++) begin: Rd_or_X30Pipe
			D_FF holdRd_or_X30(.q(exRd_or_X30[i]), .d(Rd_or_X30[i]), .reset, .clk);
		end
	endgenerate
	
	// Rn
	generate 
		for (i = 0; i < 5; i++) begin: RnPipe
			D_FF holdRn (.q(exRn[i]), .d(idRn[i]), .reset, .clk);
		end
	endgenerate
	
	// Rm
	generate 
		for (i = 0; i < 5; i++) begin: RmPipe
			D_FF holdRm (.q(exRm[i]), .d(idRm[i]), .reset, .clk);
		end
	endgenerate
	
	// instruction
	generate 
		for (i = 0; i < 32; i++) begin: instructionPipe
			D_FF holdinstruction (.q(exinstruction[i]), .d(decInstruction[i]), .reset, .clk);
		end
	endgenerate
	
	// ALUSrc
	D_FF holdALUSrc(.q(exALUSrc), .d(ALUSrc), .reset, .clk);
	
	// immediate
	D_FF holdimmediate(.q(eximmediate), .d(immediate), .reset, .clk);
	
	// BL_op
	D_FF holdBL_op(.q(exBL_op), .d(BL_op), .reset, .clk);
	
	// MemWrite
	D_FF holdMemWrite(.q(exMemWrite), .d(MemWrite), .reset, .clk);
	
	// MemRead
	D_FF holdMemRead(.q(exMemRead), .d(MemRead), .reset, .clk);
	
	// MemtoReg
	D_FF holdMemtoReg(.q(exMemtoReg), .d(MemtoReg), .reset, .clk);
	
	// RegWrite
	D_FF holdRegWrite (.q(exRegWrite), .d(RegWrite), .reset, .clk);
	
	// Flag
	D_FF holdFlag (.q(exFlag), .d(Flag), .reset, .clk);
	
	// UncondBr
	D_FF holdUncondBr (.q(exUncondBr), .d(UncondBr), .reset, .clk);
	
	// BrTaken
	D_FF holdBrTaken (.q(exBrTaken), .d(BrTaken), .reset, .clk);
	
	// loadop
	D_FF holdloadop (.q(exloadop), .d(loadop), .reset, .clk);
	
endmodule

// Testing the pipeline registers. This module ensures that all the registers are updated each clock cycle. 
module IDEXPipeReg_testbench();

	 logic clk, reset, ALUSrc, immediate, BL_op, MemWrite, MemRead, MemtoReg, RegWrite, Flag, UncondBr, BrTaken, loadop;
	 logic [63:0] Da, Db, ex_DAddr9, WriteData_or_noBrPC, noBrPC, Imm12, stur_Db;
	 logic [31:0] decInstruction;
	 logic [3:0] xfer_size;
	 logic [2:0] ALUOp;
	 logic [4:0] Rd_or_X30, idRn, idRm;
	
	 logic exALUSrc, eximmediate, exBL_op, exMemWrite, exMemRead, exMemtoReg, exRegWrite, exFlag, exUncondBr, exBrTaken, exloadop;
	 logic [63:0] exDa, exDb, exImm12, exWriteData_or_noBrPC, exnoBrPC, exex_DAddr9, ex_stur_Db; 
	 logic [2:0] exALUOp;
	 logic [3:0] exxfer_size;
	 logic [4:0] exRd_or_X30, exRn, exRm;
	 logic [31:0] exinstruction;
	
	IDEXPipeReg dut (.clk, .reset, .Da, .Db, .ex_DAddr9, .ALUOp, .ALUSrc, .immediate, .Imm12, .BL_op, .WriteData_or_noBrPC, 
						  .noBrPC, .xfer_size, .MemWrite, .MemRead, .MemtoReg, .Rd_or_X30, .exALUSrc, .eximmediate, .exBL_op, .exMemWrite,
						  .exMemRead, .exMemtoReg, .exDa, .exDb, .exImm12, .exWriteData_or_noBrPC, .exnoBrPC, .exALUOp, 
						  .exex_DAddr9, .exxfer_size, .exRd_or_X30, .idRn, .exRn, .idRm, .exRm, .RegWrite, .exRegWrite, .Flag, .exFlag,
						  .UncondBr, .exUncondBr, .BrTaken, .exBrTaken, .decInstruction, .exinstruction, .stur_Db, .ex_stur_Db,
						  .loadop, .exloadop);
							  
	// Set up a simulated clock.
	parameter CLOCK_PERIOD=100;
	initial begin
		clk <= 0;
		forever #(CLOCK_PERIOD/2) clk <= ~clk; #100;
	end
	
	initial begin
	// Test with values to ensure the data is updated next clock cycle.
		reset <= 1; reset <= 0; #10;
		MemtoReg <= 0; MemWrite <= 0; BL_op <= 0; MemRead <= 0; ALUSrc <= 0; immediate <= 0; #10;
		for (int i = 0; i < 10; i++) begin
			MemtoReg <= ~MemtoReg; #10;
			MemWrite <= ~MemWrite; #10;
			BL_op <= ~BL_op; #10;
			MemtoReg <= ~MemRead; #10;
			ALUSrc <= ~ALUSrc; #10;
			immediate <= ~immediate; #10;
		end
		
		// Test with values to ensure the data is updated next clock cycle.
		Da <= 64'd0; Db <= 64'b 0; noBrPC <= 64'd0; WriteData_or_noBrPC <= 64'd0; ex_DAddr9 <= 64'd0; xfer_size <= 4'd0; 
		noBrPC <= 64'd0; Imm12 <= 64'd0; xfer_size <= 4'd0; ALUOp <= 3'd0; #10;
		for (int i = 0; i < 10; i++) begin
			Da <= i*1; #10;
			noBrPC <= i*2; #10;
			WriteData_or_noBrPC <= i*3; #10;
			Db <= i*4; #10;
			ex_DAddr9 <= i*5; #10;
			Imm12 <= i*6; #10;
			xfer_size <= i; #10;
			ALUOp <= i/2; #10;
		end
		
		$stop;
		
	end

endmodule