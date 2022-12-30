// A 32:5 decoder made of four 8:3 decoders. Inputs include in, the
// inputted data, and en, the enabler. The output is out. 

module decoder_32 (in, out, en);
	input logic [4:0] in;
	input logic en;
	output logic [31:0] out;

	wire [3:0] w;
	
	// Output from 2x4 decoder tells which 3x8 decoder to enable
	decoder_4 d_1 (.in(in[4:3]), .out(w[3:0]), .en(en));
	// Each 3x8 decoder has 8 output lines to make 32 total lines
	decoder_8 d_2 (.in(in[2:0]), .out(out[7:0]), .en(w[0]));
	decoder_8 d_3 (.in(in[2:0]), .out(out[15:8]), .en(w[1]));
	decoder_8 d_4 (.in(in[2:0]), .out(out[23:16]), .en(w[2]));
	decoder_8 d_5 (.in(in[2:0]), .out(out[31:24]), .en(w[3]));
endmodule

// We don't have to test every possibility to ensure the decoder
// works, just a few test values. 
module decoder_32_testbench();
	logic [4:0] in;
	logic en;
	logic [31:0] out;
	
	decoder_32 dut (.in, .out, .en);
	
	initial begin
		in = 5'b00000; en = 0; #10; 
		in = 5'b00000; en = 1; #10; // out = [0, 0, 0...0, 0, 1] (32 bits)
		in = 5'b00001; en = 1; #10; // out = [0, 0, 0...0, 1, 0] 
		in = 5'b00010; en = 1; #10; // out = [0, 0, 0...1, 0, 0]
		in = 5'b11101; en = 1; #10; // out = [0, 0, 1...0, 0, 0]
		in = 5'b11110; en = 1; #10; // out = [0, 1, 0...0, 0, 0]
		in = 5'b11111; en = 1; #10; // out = [1, 0, 0...0, 0, 0]
	
	end
endmodule