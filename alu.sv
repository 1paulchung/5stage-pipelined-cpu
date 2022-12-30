// Meaning of signals in and out of the ALU:

// Flags:
// negative: whether the result output is negative if interpreted as 2's comp.
// zero: whether the result output was a 64-bit zero.
// overflow: on an add or subtract, whether the computation overflowed if the inputs are interpreted as 2's comp.
// carry_out: on an add or subtract, whether the computation produced a carry-out.

// cntrl			Operation						Notes:
// 000:			result = B						value of overflow and carry_out unimportant
// 010:			result = A + B
// 011:			result = A - B
// 100:			result = bitwise A & B		value of overflow and carry_out unimportant
// 101:			result = bitwise A | B		value of overflow and carry_out unimportant
// 110:			result = bitwise A XOR B	value of overflow and carry_out unimportant

// This module represents the entire ALU. The input signals are A, B, and cntrl.
// The signal cntrl determines what operation to run (indicated in the comment block above). 
// The outputs for the ALU are result (output of the operation), negative (indicates if the result
// is negative), zero (indicates if result is zero), overflow (if result overflowed), and carry_out
// (indicates if add or subtract had a carry out).

`timescale 10ps/1fs
module alu(
	input logic	[63:0] A, B, // input values
	input logic	[2:0]	cntrl, // determines operation 
	output logic [63:0] result, // output result
	output logic negative, zero, overflow, carry_out // flags
);
	// Track the carry for each bit.
	// We only need 63 bits since the the 64th value is the carry out flag.
	logic [62:0] aluCout;
	
	// Sets up the first 1 bit alu outside the loop to change cin
	// if we're subtracting, cin will be 1 to account for A+(-B)+1
	// if we're adding, cin will be 0 so A+B+0
	alu1bit firstAlu (.a(A[0]), .b(B[0]), .out(result[0]), .cin(cntrl[0]), .cout(aluCout[0]), .cntrl(cntrl[2:0]));
	
	// Generates the ALUs for bits 2-63 of the result.
	genvar i;
	generate 
		for (i = 1; i < 63; i++) begin: createAlu
			// cin is the cout from the previous operation, which is why we use i-1.
			alu1bit theAlu (.a(A[i]), .b(B[i]), .out(result[i]), .cin(aluCout[i - 1]), .cout(aluCout[i]), .cntrl(cntrl[2:0]));
		end
	endgenerate
	
	// Sets up the last 1 bit alu outside the loop to set the carry_out flag.
	alu1bit lastAlu (.a(A[63]), .b(B[63]), .out(result[63]), .cin(aluCout[62]), .cout(carry_out), .cntrl(cntrl[2:0]));
	
	// Check for zero flag.
	zero_flag check (.result, .checkZero(zero));
	
	// In 2's comp, last digit determines pos/neg number. 0=pos, 1=neg
	assign negative = result[63];
	
	// Check overflow by xor between cin and cout of the last bit.
	xor #5 checkOverflow (overflow, carry_out, aluCout[62]);

endmodule
