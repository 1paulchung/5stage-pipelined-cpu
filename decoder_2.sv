// A simple 2:1 decoder. Inputs include in, the inputted data,
// and en, the enabler. The output is out. 

`timescale 10ps/1fs 

module decoder_2 (in, out, en);
	input logic in, en;
	output logic [1:0] out;
	
	wire w;
	
	// Logic
	not #5 not1 (w, in);
	and #5 and1 (out[0], en, w);
	and #5 and2 (out[1], en, in);

endmodule

// Use testbench for decoder. 
module decoder_2_testbench();
	logic in, en;
	logic [1:0] out;
	
	decoder_2 dut (.in, .out, .en);
	
	initial begin
		in = 0; en = 0; #10;
		in = 0; en = 1; #10; // Out = [0, 1]
		in = 1; en = 0; #10;
		in = 1; en = 1; #10; // Out = [1, 0]
	end
	
endmodule