// This module represents the data within the ALU. The input signals 
// a and b are 1-bit values from the two 64-bit inputs.The input signal 
// cntrl determines what result is outputted from this module. The outputs 
//	for this module are out, which is stored in the 64-bit "result" signal 
// in alu.sv, and cout which stores the carry out for the next bit.

`timescale 10ps/1fs
module alu1bit(a, b, out, cin, cout, cntrl);
	input logic a, b, cin;
	input logic [2:0] cntrl;
	output logic out, cout;
	
	// This will be the result of each control operation and will
	// be the input for the final mux, where cntr will be the selector.
	logic [7:0] results; 
	
	// Results of operations
	logic adderAB, andAB, orAB, xorAB; 
	// notB is used to determine whether we are adding or subtracting.
	// adderB is the value of b decided via mux.
	logic adderB, notB; 
	
	// If addition, b=b since A+B and cin is initially 0.
	// If subtraction, b=~b since A+(-B) and cin is initially 1.
	// sel is the last bit of cntrl since 010 is add, and 011 is subtract.
	not #5 not0 (notB, b);
	mux_2 determineB (.in({notB, b}), .sel(cntrl[0]), .out(adderB));
	
	// Add a and adderB and put result in result[2]
	fullAdder adderOrSub (.a, .b(adderB), .cin, .sum(results[2]), .cout);
	
	// Gate operations
	and #5 andOp (andAB, a, b);
	or #5 orOp (orAB, a, b);
	xor #5 xorOp (xorAB, a, b);
	
	// Result assignments
	assign results[0] = b;
	// Add and sum is determined in the mux and control, so results[2] & [3] 
	// will be the same value.
	assign results[3] = results[2];
	assign results[4] = andAB;
	assign results[5] = orAB;
	assign results[6] = xorAB;
	// We don't care about results[1] and results[7], so the default
	// for them is a. 
	assign results[1] = a;
	assign results[7] = a;
	
	// 8:3 mux to determine output signal "out" from results by cntrl.
	logic [1:0] selMux;
	mux_4 firstMux (.in(results[3:0]), .sel(cntrl[1:0]), .out(selMux[0]));
	mux_4 secondMux (.in(results[7:4]), .sel(cntrl[1:0]), .out(selMux[1]));
	mux_2 decidingMux (.in(selMux[1:0]), .sel(cntrl[2]), .out);
	
endmodule

// Conducting tests for all six possible control inputs and then 
// ensure that outputs for control signals 1 and 7 output a, which 
// is the default case.
module alu1bit_testbench();
	logic a, b, cin;
	logic [2:0] cntrl;
	logic out, cout;
	
	alu1bit dut (.a, .b, .out, .cin, .cout, .cntrl);
	
	initial begin		
		cntrl = 0; a = 0; b = 0; cin = 0; #1000;
		// Test 1: out should equal whatever b is assigned
		for (int i = 0; i < 2; i++) begin
			b = i; #1000;
		end
		
		// Test 2: out should equal whatever a is assigned since cntrl = 1
		// results in default output of a
		cntrl = 1;
		for (int i = 0; i < 4; i++) begin
			{a, b} = i; #1000;
		end
		
		// Test 3: adding a and b
		cntrl = 2; #1000;
		for (int i = 0; i < 8; i++) begin
			{a, b, cin} = i; #1000;
		end
		
		// Test 4: subtract a and b
		cntrl = 3; #1000;
		for (int i = 0; i < 4; i++) begin
			{a, b} = i; cin = 1; #1000;
		end

		// Test 5: bitwise a and b
		// Out should equal 1 only when a = b = 1
		// and 0 otherwise.
		cntrl = 4; cin = 0; cout = 0; #1000;
		for (int i = 0; i < 4; i++) begin
			a = i[0]; b = i[1]; #1000;
		end
		
		// Test 6: bitwise a or b
		// Out should equal 0 only if a = b = 0
		// and 1 otherwise
		cntrl = 5; #1000;
		for (int i = 0; i < 4; i++) begin
			a = i[0]; b = i[1]; #1000;
		end
		
		// Test 7: bitwises a xor b
		// a = b = 0 should make out = 0
		// a = b = 1 should make out = 0
		// and out = 1 otherwise
		cntrl = 6; #1000;
		for (int i = 0; i < 4; i++) begin
			a = i[0]; b = i[1]; #1000;
		end
		
		// Test 8: out should equal whatever a is assigned since cntrl = 7
		// results in default output of a
		cntrl = 7;
		for (int i = 0; i < 4; i++) begin
			{a, b} = i; #1000;
		end
		$stop;
	end

endmodule