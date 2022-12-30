// A simple 4:2 mux. The inputs are in, the inputted data, and sel, 
// the selector. The output is the selected input data based on the
// selector.

`timescale 10ps/1fs
module mux_4(in, sel, out);
	input logic [3:0] in;
	input logic [1:0] sel;
	output logic out;
	logic [5:0] x;
	
	// Gate-level logic for 4:1 mux
	not #5 not1 (x[0], sel[0]);
	not #5 not2 (x[1], sel[1]);
	and #5 and1 (x[2], in[0], x[0], x[1]);
	and #5 and2 (x[3], in[1], sel[0], x[1]);
	and #5 and3 (x[4], in[2], x[0], sel[1]);
	and #5 and4 (x[5], in[3], sel[0], sel[1]);
	or  #5 or1  (out, x[2], x[3], x[4], x[5]);
endmodule

// Testing every input/select possibility to ensure the mux works.
module mux_4_testbench();
	logic [3:0] in;
	logic [1:0] sel;
	logic out;
	
	mux_4 dut (.in, .sel, .out);
	
	// Testing all occassions where "in" is an input
	// value, and we test if the sel signal chooses 
	// the respective bit.
	initial begin
		// Test all possible combinations of sel and in for
		// 4:1 mux
		for (int i = 0; i < 16; i++) begin
			for (int j = 0; j < 4; j++) begin
				in = i; sel = j; #1000;
			end
		end
		
		$stop;
	end
endmodule