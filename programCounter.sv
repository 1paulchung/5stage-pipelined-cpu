// Keeps track of the current instruction and updates
// as instruction address is updated.
// In is the instruction as it updates, out is the held instruction value.

`timescale 10ps/1fs
module programCounter(clk, reset, in, out);

	// Declare signals
	input logic clk, reset;
	input logic [63:0] in;
	output logic [63:0] out;
	
	// Use 64 flip flops to hold each bit value for the instruction
	genvar i;
	generate
		for (i = 0; i < 64; i++) begin: register
			D_FF dff1 (.q(out[i]), .d(in[i]), .reset, .clk);
		end
	endgenerate

endmodule

// Module to test the program counter to ensure for a given
// value in, the correct output signal "out" is output. 
module programCounter_testbench();

	logic clk, reset;
	logic [63:0] in;
	logic [63:0] out;
	
	programCounter dut (.clk, .reset, .in, .out);
	
	// Set up a simulated clock.
	parameter CLOCK_PERIOD=100;
	initial begin
		clk <= 0;
		forever #(CLOCK_PERIOD/2) clk <= ~clk; #1000;
	end
	
	// Begin testing
	initial begin
		reset <= 0; #1000;
		for (int i = 0; i < 32; i++) begin
			{in} <= i; #1000;
		end
	end
	
endmodule