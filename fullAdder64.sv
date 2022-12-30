// Full Adder with 64 bit inputs. Generates 64 1-bit full adders
// to compute sum and cout.
// 	Inputs include a, b, and cin. Outputs include sum and cout. 

`timescale 10ps/1fs
module fullAdder64(a, b, cin, sum, cout);
	// Delcare logical signals
	input  logic [63:0] a, b;
	input  logic cin;
	output logic [63:0] sum;
	output logic cout;
	// Signal carries will hold all the carries for the respective bit
	logic [63:0] carries;
	
	// Create the first adder
	fullAdder firstAdder (.a(a[0]), .b(b[0]), .cin(cin), .sum(sum[0]), .cout(carries[0]));
	
	// Create adders 1 - 62
	genvar i;
	generate 
		for (i = 1; i < 63; i++) begin: createAdders
			fullAdder theOtherAdders (.a(a[i]), .b(b[i]), .cin(carries[i-1]), .sum(sum[i]), .cout(carries[i]));
		end
	endgenerate
	
	// Create the second adder
	fullAdder lastAdder (.a(a[63]), .b(b[63]), .cin(carries[62]), .sum(sum[63]), .cout(carries[63]));

endmodule

// Tests several input combinations for a, b, and cin to 
// fully ensure the full adder is working correct. 
module fullAdder64_testbench();

	logic [63:0] a, b;
	logic cin;
	logic [63:0] sum;
	logic cout;
	
	fullAdder64 dut (.a, .b, .cin, .sum, .cout);
	
	// Test input combinations
	initial begin
		cin = 0; #1000;
		for (int i = 0; i < 2**64; i++) begin
			{a, b} = i; cin = ~cin; #1000;
		end
	end

endmodule