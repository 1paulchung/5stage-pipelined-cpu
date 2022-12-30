// Top level module of a 64-bit ARM pipelined CPU. 
// The CPU performs all of the specified instructions
// within the Lab 4 handout. The only inputs into the CPU
// are a clock and a reset. The waveform file should be included 
// within the turn in.

`timescale 10ps/1fs 
module cpu(clk, reset);
	// Declare signals
	input logic clk, reset; 
	logic [31:0] instruction; //instruction
	logic [3:0] xfer_size; // size for datamem
	
	// ALU flags and signals
	logic overflow, negative, zero, carry_out, is_neg, is_zero, is_overflow, is_carryOut;
	
	// Control signal declarations
	logic [10:0] opcode; 
	logic [2:0] ALUOp; 
	logic Reg2Loc, UncondBr, BrTaken, MemRead, MemtoReg, MemWrite, ALUSrc, RegWrite, Flag, immediate, BL_op, BR_op, 
			cbz_op, sturop, loadop;
			
	// Forwarding unit declarations 
	logic [1:0] forwardA, forwardB, forward_store, forward_br;
	logic forward_zero, forward_load, forward_bl;
 
	// Stage 1: Fetch Instruction declarations
	logic [63:0] noBrPC;
	logic [4:0] idRn, idRm;
	
	// Stage 2: Decode Instruction declarations
	logic [31:0] decInstruction;
	logic [63:0] decnoBrPC, muxDataB, stur_Db, DAddr_Imm_out, WriteData, Da, Db, WriteData_or_noBrPC, ex_DAddr9;
	logic [4:0] decRd_or_X30, decRd, Rd, Rd_or_X30;
	
	// Stage 3: Execute declarations
	logic [63:0] exDa, exDb, exImm12, exWriteData_or_noBrPC, exnoBrPC, exex_DAddr9, ex_stur_Db, alu_result;
	logic [31:0] exinstruction;
	logic [4:0] exRn, exRm, exRd_or_X30;
	logic exFlag, exUncondBr, exBrTaken, exMemRead, exALUSrc, eximmediate, exBL_op, exMemWrite, exMemtoReg, 
			exRegWrite, exloadop;
	logic [3:0] exxfer_size;
	logic [2:0] exALUOp;
	
	// Stage 4: Memory declarations
	logic [63:0] memalu_result, memDb, memDa, mem_stur_Db, memnoBrPC, memWriteData_or_noBrPC, memex_DAddr9, read_data;
	logic [4:0] memRd, memRd_or_X30;
	logic [3:0] memxfer_size;
	logic memis_neg, memis_overflow, memRegWrite, memMemRead, memloadop, memMemWrite, memBL_op, 
			memMemtoReg;
	
	// Stage 5: Write back declarations
	logic [63:0] wbWriteData_or_noBrPC, wbnoBrPC, wbalu_result, wbWriteData_or_noBrPC_temp, wbread_data;
	logic [4:0] wbRd, wbRd_or_X30;
	logic wbBL_op, wbRegWrite, wbMemRead, wbMemtoReg, wbMemWrite;
	
	// Control Unit
	control controlModule (.clk, .reset, .decRd(decInstruction[4:0]), .decopcode(decInstruction[31:21]), .ALUOp, 
								  .Reg2Loc, .UncondBr, .BrTaken, .MemRead, .MemtoReg, .MemWrite, .ALUSrc, .RegWrite, .Flag, 
								  .is_overflow, .is_neg, .immediate, .xfer_size, .is_zero, .BL_op, .BR_op, .Da, .cbz_op, 
								  .sturop, .loadop,.overflow, .negative, .exFlag);
	
	
	// -----------------------Stage 1: Instruction Fetch (IF)-----------------------
	
	
	// Fetch Instruction
	fetchInstruct stage1 (.clk, .reset, .instruction, .noBrPC, .BR_op, .BL_op, .Db, .Rd_or_X30, .UncondBr, 
								 .BrTaken, .decInstruction, .alu_result, .forward_br, .read_data);

	// IF-ID Pipeline Register
	IFIDPipeReg IFID (.clk, .reset, .instruction, .noBrPC, .Rd_or_X30, .decInstruction, .decnoBrPC, .decRd_or_X30);
	
	// -----------------------Stage 2: Instruction Decode (ID)-----------------------
	
	
	// Forwarding unit
	forwardingUnit forwardModule (.ex_memRd(memRd_or_X30), .id_exRn(exRn), .id_exRm(exRm), .mem_wbRd(wbRd_or_X30), 
										.mem_wbRegWrite(wbRegWrite), .ex_memRegWrite(memRegWrite), .forwardA, .forwardB, .eximmediate,
										.decRd(decRd_or_X30), .exRd(exRd_or_X30), .forward_zero, .cbzop(cbz_op), .sturop, .exRegWrite, .forward_store,
										.loadop(memloadop), .forward_load, .memMemRead, .if_idRn(instruction[9:5]), .wbMemRead,
										.forward_br, .BR_op, .forward_bl, .BL_op(wbBL_op));

	// Invert the clock so we write on positive edge and read on negative edge.
	logic invertClk;
	not #5 (invertClk, clk);

	// Decode Instruction
	instructDecode stage2 (.clk(invertClk), .writeToRd(wbRd_or_X30), .Rd(decInstruction[4:0]), .Rm(decInstruction[20:16]), .Rn(decInstruction[9:5]), 
								  .Reg2Loc, .Da, .Db, .WriteData_or_noBrPC, .Rd_or_X30(decRd_or_X30), .RegWrite(wbRegWrite), 
								  .DAddr9(decInstruction[20:12]), .ex_DAddr9, .WriteData(wbWriteData_or_noBrPC_temp), .BL_op, .noBrPC, .cbz_op,
								  .exalu_result(alu_result), .forward_zero, .forward_store, .sturop, .exDa, .wbnoBrPC, .wbBL_op, .memalu_result);

	// Select ex_DAddr9 or extended Imm12 where selector is immediate. Output is DAddr_Imm_out.
	mux_128 largeMux (.input0(ex_DAddr9), .input1({{52{1'b0}}, decInstruction[21:10]}), .select(immediate), .out(DAddr_Imm_out));
	// Select Db or DAddr_Imm_out where selector is ALUSrc. Output is muxDataB.
	mux_128 largeMux0 (.input0(Db), .input1(DAddr_Imm_out), .select(ALUSrc), .out(muxDataB)); 

	// ID-EX Pipeline Register
	IDEXPipeReg IDEX (.clk, .reset, .Da, .Db(muxDataB), .ex_DAddr9, .ALUOp, .ALUSrc(ALUSrc), .immediate, .Imm12({{52{1'b0}}, decInstruction[21:10]}), .BL_op, .WriteData_or_noBrPC, 
						  .noBrPC(decnoBrPC), .xfer_size, .MemWrite, .MemRead, .MemtoReg, .Rd_or_X30(decRd_or_X30), .exALUSrc, .eximmediate, .exBL_op, .exMemWrite,
						  .exMemRead, .exMemtoReg, .exDa, .exDb, .exImm12, .exWriteData_or_noBrPC, .exnoBrPC, .exALUOp, 
						  .exex_DAddr9, .exxfer_size, .exRd_or_X30, .idRn(decInstruction[9:5]), .exRn, .idRm(decInstruction[20:16]), .exRm, .RegWrite, .exRegWrite,
						  .Flag, .exFlag, .UncondBr, .exUncondBr, .BrTaken, .exBrTaken, .decInstruction, .exinstruction, .stur_Db(Db), .ex_stur_Db,
						  .loadop, .exloadop);
	
	// -----------------------Stage 3: Execute (EX)-----------------------
	
	
	// Execute
	execute stage3 (.Da(exDa), .Db(exDb), .ALUOp(exALUOp), .alu_result, .is_neg, .is_zero, .is_overflow, .is_carryOut, 
						 .ALUSrc(exALUSrc), .ex_DAddr9(exex_DAddr9), .Imm12(exImm12[11:0]), .immediate(eximmediate),
						 .forwardA, .forwardB, .wbalu_result, .memalu_result, .forward_load, .loadop, .read_data(wbread_data),
						 .forward_bl, .WriteData(wbWriteData_or_noBrPC_temp));
	
	// Indicate zero, negative, carry_out, and overflow only if operation asks to. The signal "Flag" is used to 
	// enable the D flip flop and write to the zero, negative, carry_out, and overflow flags.
	DFF_enable checkZero (.q(zero), .d(is_zero), .en(exFlag), .clk);
	DFF_enable checkNegative (.q(negative), .d(is_neg), .en(exFlag), .clk);
	DFF_enable checkCarryOut (.q(carry_out), .d(is_carryOut), .en(exFlag), .clk);
	DFF_enable checkOverflow (.q(overflow), .d(is_overflow), .en(exFlag), .clk);
	
	// EX-MEM Pipeline Register
	EXMEMPipeReg EXMEM (.clk, .reset, .alu_result, .Db(exDb), .MemWrite(exMemWrite), .MemRead(exMemRead), 
							  .xfer_size(exxfer_size), .noBrPC(exnoBrPC), .BL_op(exBL_op), .WriteData_or_noBrPC(exWriteData_or_noBrPC), 
							  .ex_DAddr9(exex_DAddr9), .MemtoReg(exMemtoReg), .memMemWrite, .memMemRead, .memBL_op,
							  .memMemtoReg, .memalu_result, .memDb, .memnoBrPC, .memWriteData_or_noBrPC, .memex_DAddr9,
							  .memxfer_size, .exRd_or_X30, .memRd_or_X30, .exRegWrite, .memRegWrite, .exDa, .memDa, .ex_stur_Db, .mem_stur_Db,
							  .exloadop, .memloadop, .is_neg, .memis_neg, .is_overflow, .memis_overflow);
	
	// -----------------------Stage 4: Memory Access (MEM)-----------------------
	
	// Memory 
	memory stage4 (.clk, .alu_result(memalu_result), .MemWrite(memMemWrite), .MemRead(memMemRead), .Db(mem_stur_Db), .xfer_size(memxfer_size), 
						.read_data);

	
	// MEM-WB Pipeline Register
	MEMWBPipeReg MEMWB (.clk, .reset, .alu_result(memalu_result), .read_data, .MemtoReg(memMemtoReg), .MemWrite(memMemWrite), 
							  .noBrPC(memnoBrPC), .BL_op(memBL_op), .WriteData_or_noBrPC(memWriteData_or_noBrPC), .wbMemtoReg,
							  .wbMemWrite, .wbBL_op, .wbalu_result, .wbread_data, .wbnoBrPC, .wbWriteData_or_noBrPC, .memRd_or_X30, .wbRd_or_X30,
							  .memRegWrite, .wbRegWrite, .memMemRead, .wbMemRead);
	
	// -----------------------Stage 5: Write Back (WB)-----------------------
	
	// Write back
	writeBack stage5 (.alu_result(wbalu_result), .read_data(wbread_data), .MemtoReg(wbMemtoReg), .noBrPC(wbnoBrPC), .BL_op(wbBL_op), 
							.WriteData_or_noBrPC(wbWriteData_or_noBrPC_temp));

endmodule