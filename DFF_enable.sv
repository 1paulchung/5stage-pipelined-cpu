// Creates and enables D flipflops. A 2:1 mux is used to select
// either the old or new value depending on the enabler. Inputs 
// include d, the input data, en, the enabler that determines 
// if the new value is written or not, and the clock. The output 
// is q, the value stored in the flip flop whether it was rewritten 
// or not. 

module DFF_enable (q, d, en, clk);
	input logic d, en, clk;
	output logic q;
	logic muxOut;
	logic [1:0] in;
	
	assign in[0] = q;
	assign in[1] = d;

	// Create a flip flop from the submodule D_FF
	D_FF dFlipFlop (.q(q), .d(muxOut), .reset(1'b0), .clk);
	
	// Create a MUX through the submodule mux_2.
	// Purpose of 2x1`mux is that if enable signal is high that means
	// the mux will choose the new input value of d, and if enable is
	// low, the mux will choose the old value that was initially in DFF.
	mux_2 theMux (.in(in[1:0]), .sel(en), .out(muxOut));
	
endmodule 

module Dff_enable_testbench();
	logic q, d, en, clk; 
	
	DFF_enable dut (.q, .d, .en, .clk);
	
	// Set up a simulated clock.
	parameter CLOCK_PERIOD=100;
	initial begin
		clk <= 0;
		forever #(CLOCK_PERIOD/2) clk <= ~clk;
	end
	
	initial begin
		d <= 0; en <= 0; // input is 0, enable is off, value is not rewritten.
		d <= 1; en <= 0; // input is 1, enable is off, value is not rewritten.
		d <= 0; en <= 1; // input is 0, enable is on, so new value (0) will be stored in DFF.
		d <= 1; en <= 1; // input is 1, enable is on, so new value (1) will be stored in DFF.
		$stop;
	end
endmodule
	