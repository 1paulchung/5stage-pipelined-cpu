// A 10:1 mux broken down into 5 2:1 muxes. This module
// is used to output a 5-bit signal when choosing between
// two different 5-bit signals. 
`timescale 10ps/1fs
module mux_10 (input0, input1, select, out);
	// Declare signals
	input logic [4:0] input0, input1;
	input logic select;
	output logic [4:0] out;

	// Generate 5 2:1 muxes to output a 5-bit signal into signal "out"
	genvar i;
	generate 
		for (i = 0; i < 5; i++) begin : eachRouteMux
			mux_2 aMux (.in({input1[i], input0[i]}), .sel(select), .out(out[i]));
		end
	endgenerate 

endmodule

// Testing every input/select possibility to ensure the mux works.
module mux_10_testbench();
	logic [4:0] input0, input1;
	logic select;
	logic [4:0] out;
	
	mux_10 dut (.input0, .input1, .select, .out);
	
	// Begin testing
	initial begin
		// Load the values for input0 and input1
		for (int i = 0; i < 2**4; i++) begin
			input0[i] = i**2;
			input1[i] = ~i**2;
		end
		// Determine the output based off the provided select value
		for (int i = 0; i < 2; i++) begin
			select = i; #1000;
		end
		
	end
endmodule