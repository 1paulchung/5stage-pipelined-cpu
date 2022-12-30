/*	Stage 3: Execute Stage and ALU. ALU inputs are determined by forward and control signals.
 *	Inputs include ALUSrc, immediate, forward_load, loadop, forward_bl, ALUOp, Da, Db, ex_DAddr9, wbalu_result, 
 * 	memalu_result, read_data, WriteData, Imm12, forwardA, and forwardB. Outputs include is_neg, is_zero, 
 *		is_overflow, is_carryOut, and alu_result.
 */

`timescale 10ps/1fs
module execute(Da, Db, ALUOp, alu_result, is_neg, is_zero, is_overflow, is_carryOut, ALUSrc, ex_DAddr9, 
					Imm12, immediate, forwardA, forwardB, wbalu_result, memalu_result, forward_load, loadop, read_data, 
					forward_bl, WriteData);

	input logic ALUSrc, immediate, forward_load, loadop, forward_bl; // Control & forwarding signals
	input logic [2:0] ALUOp; // ALU opcode
	input logic [63:0] Da, Db, ex_DAddr9, wbalu_result, memalu_result, read_data, WriteData; // Data into ALU and forwarding data 
	input logic [11:0] Imm12; // Immediate value
	input logic [1:0] forwardA, forwardB; // Forwarding signals
	
	output logic is_neg, is_zero, is_overflow, is_carryOut; // Flag signals
	output logic [63:0] alu_result; // ALU result
	
	logic [63:0] DaInALU, DbInALU, Da_load, Da_bl; // Results of forwarding
	
	// ForwardA
	// If forwarding, Da becomes either memory or write back alu result. If not forwarding, Da goes into ALU.
	genvar i;
	generate  
		for (i = 0; i < 64; i++) begin: forwardingA
			mux_4 forwardingMuxA (.in({1'b0, memalu_result[i], wbalu_result[i], Da[i]}), .sel(forwardA), .out(DaInALU[i]));
		end
	endgenerate
	
	// ForwardB
	// If forwarding, Db becomes either memory or write back alu result. If not forwarding, Db goes into ALU.
	generate 
		for (i = 0; i < 64; i++) begin: forwardingB
			mux_4 forwardingMuxB (.in({1'b0, memalu_result[i], wbalu_result[i], Db[i]}), .sel(forwardB), .out(DbInALU[i]));
		end
	endgenerate
	
	// Forwarding for LDUR. If forward_load = 1, Da becomes data from memory.
	mux_128 loadedge (.input0(DaInALU), .input1(read_data), .select(forward_load), .out(Da_load));
	
	// Forwarding for BL. If forward_bl = 1, Da becomes WriteData from write back. 
	mux_128 bledge (.input0(Da_load), .input1(WriteData), .select(forward_bl), .out(Da_bl));
	
	// ALU file
	alu theALU (.A(Da_bl), .B(DbInALU), .cntrl(ALUOp), .result(alu_result), .negative(is_neg), .zero(is_zero), .overflow(is_overflow), .carry_out(is_carryOut));
endmodule

// Testbench module
module execute_testbench();	
	 logic [2:0] ALUOp;
	 logic ALUSrc, immediate, forward_load, loadop, forward_bl;
	 logic [63:0] Da, Db, ex_DAddr9, wbalu_result, memalu_result, read_data, WriteData;
	 logic [11:0] Imm12;
	 logic [1:0] forwardA, forwardB;
	
	 logic is_neg, is_zero, is_overflow, is_carryOut;
	 logic [63:0] alu_result;
	
	execute dut (.Da, .Db, .ALUOp, .alu_result, .is_neg, .is_zero, .is_overflow, .is_carryOut, .ALUSrc, .ex_DAddr9, 
					.Imm12, .immediate, .forwardA, .forwardB, .wbalu_result, .memalu_result, .forward_load, .loadop, .read_data, 
					.forward_bl, .WriteData);
		
	initial begin
	
		ALUSrc <= 0; immediate <= 0; Da <= 64'b0; Db <= 64'b0; ex_DAddr9 <= 64'b0; wbalu_result <= 64'b0; 
		memalu_result = 64'b0; Imm12 <= 12'b0; forwardA <= 00; forwardB <= 00;
		
		// ALUop = 000 result = B
		ALUOp <= 000; Db <= 64'd5; #100; // alu_result = 5
		
		// ALUop = 010 result = A + B
		ALUOp <= 010; Da <= 64'd10; #100; // alu_result = 15
		
		// ALUOp = 011 result = A - B
		ALUOp <= 011; #100; // alu_result = 5
		
		// ALUOp = 100 result = bitwise A & B
		ALUOp <= 100; #100; // alu_result = 0
		Da <= 64'd11; #100; // alu_result = 1
		
		// ALUOp = 101 result = bitwise A | B
		ALUOp <= 101; #100; // alu_result = 15
		Da <= 64'b0; #100; // alu_result = 5
		
		// ALUOp = 110 result = bitwise A XOR B
		ALUOp <= 110; #100; // alu_result = 5
		Da <= 64'd10; #100; // alu_result = 15
		
		// test forwarding
		ALUOp <= 010; // add
		wbalu_result <= 64'd3; memalu_result <= 64'd9;
		forwardA <= 01; #100; // DaInALU = 64'd3, alu_result = 3 + 5 = 8
		
		forwardA <= 10; #100; // DaInALU = 64'd9, alu_result = 9 + 5 = 14
		
		forwardA <= 00; forwardB <= 01; #100; // DbinALU = 64'd3, alu_result = 10 + 3 = 13
		
		forwardB <= 10; #100; // DbinALU = 64'd9, alu_result = 10 + 9 = 20
		
		
	end

endmodule