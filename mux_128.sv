// // A 128:1 mux broken down into 64 2:1 muxes.
// The purpose of this module is to output a 64-bit
// output signal when choosing between two different
// 64 bit signals. 
`timescale 10ps/1fs
module mux_128 (input0, input1, select, out);
	// Declare signals
	input logic [63:0] input0, input1;
	input logic select;
	output logic [63:0] out;

	// The output signal is stored into 64-bit "out"
	genvar i;
	generate 
		for (i = 0; i < 64; i++) begin : eachRouteMux
			mux_2 aMux (.in({input1[i], input0[i]}), .sel(select), .out(out[i]));
		end
	endgenerate 

endmodule

// Testing every input/select possibility to ensure the mux works.
module mux_128_testbench();
	logic [63:0] input0, input1;
	logic select;
	logic [63:0] out;
	
	mux_128 dut (.input0, .input1, .select, .out);
	
	// Begin testing
	initial begin
		// Fill input0 and input1 with values
		for (int i = 0; i < 2**10; i++) begin
			input0[i] = i**4;
			input1[i] = ~i**4;
		end
		// Test different select values to see the output
		for (int i = 0; i < 2; i++) begin
			select = i; #1000;
		end
	
	end
	
endmodule