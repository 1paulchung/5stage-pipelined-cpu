// Test bench for ALU

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

`timescale 1ns/10ps
module alustim();

	parameter delay = 100000;

	logic		[63:0]	A, B;
	logic		[2:0]		cntrl;
	logic		[63:0]	result;
	logic					negative, zero, overflow, carry_out ;
	logic [59:0] extra_zeros; // 60 zeros

	parameter ALU_PASS_B=3'b000, ALU_ADD=3'b010, ALU_SUBTRACT=3'b011, ALU_AND=3'b100, ALU_OR=3'b101, ALU_XOR=3'b110;
	

	alu dut (.A, .B, .cntrl, .result, .negative, .zero, .overflow, .carry_out);

	// Force %t's to print in a nice format.
	initial $timeformat(-9, 2, " ns", 10);

	integer i;
	logic [63:0] test_val;
	initial begin
		
		// Test single add operation (test was given in starter files)
		$display("%t testing addition", $time);
		cntrl = ALU_ADD;
		A = 64'h0000000000000001; B = 64'h0000000000000001;
		#(delay);
		assert(result == 64'h0000000000000002 && carry_out == 0 && overflow == 0 && negative == 0 && zero == 0);
		
		// Test0: pass a operation when control = 1
		// out == a
		$display("%t testing when control = 1 (should pass in value a)", $time);
		cntrl = 3'b001;
		for (i=0; i<100; i++) begin
			A = $random(); B = $random();
			#(delay);
			assert(result == A && negative == A[63] && zero == (A == '0));
		end
		
		// Test 0: pass b operation when control = 7
		// out == a
		$display("%t testing when control = 7 (should pass in value a)", $time);
		cntrl = 3'b0111;
		for (i=0; i<100; i++) begin
			A = $random(); B = $random();
			#(delay);
			assert(result == A && negative == A[63] && zero == (A == '0));
		end
		
		// Tests 1 - 5 assert: the test_val is equal to the result from the alu.
		// The last bit output from the alu indicates if it's positive or negative
		// (negative = 0 means positive, negative = 1 means negative), and
		// if the result from alu is zero or not (zero = 1 means result is 0 and
		// zero = 0 means results is 1)
		
		// Test 1: pass b operation 
		$display("%t testing PASS_B operation", $time);
		cntrl = ALU_PASS_B;
		for (i=0; i<100; i++) begin
			A = $random(); B = $random();
			#(delay);
			assert(result == B && negative == B[63] && zero == (B == '0));
		end
		
		// Test 2: 100 add operations
		$display("%t testing add operation", $time);
		cntrl =  ALU_ADD;
		for (i=0; i< 50; i++) begin
			A = $random();
			B = $random();
			test_val = A + B;
			#(delay);
			assert(test_val == result);
			assert(test_val[63] == negative);
			assert((test_val == 64'h0000000000000000) == zero);
		end
		
		
		// Test 3: 100 subtract operations
		$display("%t testing subtract operation", $time);
		cntrl =  ALU_SUBTRACT;
		for (i=0; i< 50; i++) begin
			A = $random(); 
			B = $random();
			test_val = A - B;
			#(delay);
			assert(test_val == result);
			assert(test_val[63] == negative);
			assert((test_val == 64'h0000000000000000) == zero);
		end
		
		
		// Test 4: bitwise AND operation
		$display("%t testing AND operation", $time);
		cntrl =  ALU_AND;
		for (i=0; i<50; i++) begin
			A = $random(); 
			B = $random();
			test_val = A & B;
			#(delay);
			assert(test_val == result);
			assert(test_val[63] == negative);
			assert((test_val == 64'h0000000000000000) == zero);
		end
		
		// Test 5: bitwise OR operation
		$display("%t testing OR operation", $time);
		cntrl =  ALU_OR;
		for (i=0; i<50; i++) begin
			A = $random(); 
			B = $random();
			test_val = A | B;
			#(delay);
			assert(test_val == result);
			assert(test_val[63] == negative);
			assert((test_val == 64'h0000000000000000) == zero);
		end
		
		// Test 6: bitwise XOR operation
		$display("%t testing XOR operation", $time);
		cntrl =  ALU_XOR;
		for (i=0; i<50; i++) begin
			A = $random(); 
			B = $random();
			test_val = A ^ B;
			#(delay);
			assert(test_val == result);
			assert(test_val[63] == negative);
			assert((test_val == 64'h0000000000000000) == zero);
		end
		
		// Test 7: check if carry-out, overflow, negative, and zero are function for add operation
		$display("%t testing carry-out, overflow, negative, and zero during add operation", $time);
		extra_zeros = 60'h000000000000000;
		cntrl = ALU_ADD;
		A = {4'b1111, extra_zeros}; 
		B = {4'b1000, extra_zeros};
		#(delay);
		assert(result == ({4'b0111, extra_zeros}));
		assert(carry_out == 1);
		assert(overflow == 1);
		assert(negative == 0);
		assert(zero == 0);
		
		A = {4'b0101, extra_zeros}; 
		B = {4'b0010, extra_zeros};
		#(delay);
		assert(result == ({4'b0111, extra_zeros}));
		assert(carry_out == 0);
		assert(overflow == 0);
		assert(negative == 0);
		assert(zero == 0);
		
		A = {4'b1000, extra_zeros}; 
		B = {4'b1000, extra_zeros};
		#(delay);
		assert(result == ({4'b0000, extra_zeros}));
		assert(carry_out == 1);
		assert(overflow == 1);
		assert(negative == 0);
		assert(zero == 1);

		A = {4'b0111, extra_zeros}; 
		B = {4'b0001, extra_zeros};
		#(delay);
		assert(result == ({4'b1000, extra_zeros}));
		assert(carry_out == 0);
		assert(overflow == 1);
		assert(negative == 1);
		assert(zero == 0);
		
		// Test 8: check if carry-out, overflow, negative, and zero are functional for subtract operation
		$display("%t testing carry-out, overflow, negative, and zero during subtract operation", $time);
		cntrl = ALU_SUBTRACT;

		A = {4'b1111, extra_zeros}; 
		B = {4'b1111, extra_zeros};
		#(delay);
		assert(result == ({4'b0000, extra_zeros}));
		assert(carry_out == 1);
		assert(overflow == 0);
		assert(negative == 0);
		assert(zero == 1);
		
		A = {4'b1000, extra_zeros}; 
		B = {4'b1111, extra_zeros};
		#(delay);
		assert(result == ({4'b1001, extra_zeros}));
		assert(carry_out == 0);
		assert(overflow == 0);
		assert(negative == 1);
		assert(zero == 0);
		
		A = {4'b0101, extra_zeros}; 
		B = {4'b1100, extra_zeros};
		#(delay);
		assert(result == ({4'b1001, extra_zeros}));
		assert(carry_out == 0);
		assert(overflow == 1);
		assert(negative == 1);
		assert(zero == 0);
		
		A = {4'b0111, extra_zeros}; 
		B = {4'b0010, extra_zeros};
		#(delay);
		assert(result == ({4'b0101, extra_zeros}));
		assert(carry_out == 1);
		assert(overflow == 0);
		assert(negative == 0);
		assert(zero == 0);
		
		$stop;
		
	end
endmodule
