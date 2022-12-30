// A simple 4:2 decoder. Inputs include in, the inputted data,
// and en, the enabler. The output is out. 

`timescale 10ps/1fs

module decoder_4(in, out, en);
	output logic [3:0] out;
	input logic [1:0] in;
	input en;

	wire [1:0] w;
	
	// Logic
	not #5 not0 (w[0], in[0]);
	not #5 not1 (w[1], in[1]);
	and #5 and0 (out[0], en, w[0], w[1]);
	and #5 and1 (out[1], en, in[0], w[1]);
	and #5 and2 (out[2], en, w[0], in[1]);
	and #5 and3 (out[3], en, in[0], in[1]);

endmodule
 
// Test decoder with testbench.
module decoder_4_testbench();
	logic [1:0] in;
	logic en;
	logic [3:0] out;
	
	decoder_4 dut (.in, .out, .en);
	
	initial begin
		in = 2'b00; en = 0; #10; 
		in = 2'b00; en = 1; #10; // out = [0, 0, 0, 1]
		in = 2'b01; en = 1; #10; // out = [0, 0, 1, 0]
		in = 2'b10; en = 1; #10; // out = [0, 1, 0, 0]
		in = 2'b11; en = 1; #10; // out = [1, 0, 0, 0]
	end
	
endmodule