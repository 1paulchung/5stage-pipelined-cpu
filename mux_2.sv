// A simple 2:1 mux. The inputs are in, the inputted data, and sel, 
// the selector. The output is the selected input data based on the
// selector.

`timescale 10ps/1fs
module mux_2 (in, sel, out);
	input logic [1:0] in;
	input logic sel;
	output logic out;
	
	logic [2:0] x;
	
	// Gate-level logic for 2:1 mux
	not #5 not1 (x[0], sel);
	and #5 and1 (x[1], x[0], in[0]);
	and #5 and2 (x[2], sel, in[1]);
	or  #5 or1  (out, x[1], x[2]);
endmodule

// Testing all possible combinations (8) of in and sel
// for a 2x1 mux.
module mux_2_testbench();
	logic [1:0] in;
	logic sel, out;
	
	mux_2 dut (.in, .sel, .out);
	
	// Testing all occassions where "in" is an input
	// value, and we test if the sel signal chooses 
	// the respective bit.
	initial begin		
		// To test all possible combinations of in and sel
		for (int i = 0; i < 4; i++) begin
			for (int j = 0; j < 2; j++) begin
				in = i; sel = j; #1000;
			end
		end
		$stop;
	end
endmodule