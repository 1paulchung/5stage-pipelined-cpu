// This is a 1-bit adder with a carry in and carry out.
// The inputs are a, b, and cin (carry in), and the
// outputs are sum (a + b + c) and cout (carry out).

`timescale 10ps/1fs
module fullAdder (a, b, cin, sum, cout);
	input  logic a, b, cin;
	output logic sum, cout;
	
	// Gate signals
	logic xorAB, andAB, andABCin; 
	
	// Gate-level logic
	xor #5 xor0 (xorAB, a, b);
	xor #5 xor1 (sum, xorAB, cin);
	and #5 and0 (andAB, a, b);
	and #5 and1 (andABCin, xorAB, cin);
	or #5 or0 (cout, andAB, andABCin);

endmodule

// Test all input combinations of a, b, and cin
// and ensure the correct outputs for sum and cout
module fullAdder_testbench();

	logic a, b, cin, sum, cout;
	
	fullAdder dut (a, b, cin, sum, cout);
	
	initial begin
	// Iterate through all possible eight input combinations
		for (int i = 0; i < 8; i++) begin
		// Assign signals each one bit
			{a, b, cin} = i; #1000;
		end  
	end 

endmodule  
