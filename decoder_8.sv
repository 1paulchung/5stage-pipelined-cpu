// A 8:3 decoder made of two 4:2 decoders. Inputs include in, the
// inputted data, and en, the enabler. The output is out. 

module decoder_8 (in, out, en);
	input logic [2:0] in;
	input logic en;
	output logic [7:0] out;
	
	wire [1:0] w;
	
	decoder_2 d_1 (.in(in[2]), .out(w[1:0]), .en(en));
	decoder_4 d_2 (.in(in[1:0]), .out(out[3:0]), .en(w[0]));
	decoder_4 d_3 (.in(in[1:0]), .out(out[7:4]), .en(w[1]));	
endmodule

// Test decoder with testbench.
module decoder_8_testbench();
	logic [2:0] in;
	logic en;
	logic [7:0] out;
	
	decoder_8 dut (.in, .out, .en);
	
	initial begin
		in = 3'b000; en = 0; #10; 
		in = 3'b000; en = 1; #10; // out = [0, 0, 0, 0, 0, 0, 0, 1]
		in = 3'b001; en = 1; #10; // out = [0, 0, 0, 0, 0, 0, 1, 0]
		in = 3'b010; en = 1; #10; // out = [0, 0, 0, 0, 0, 1, 0, 0]
		in = 3'b011; en = 1; #10; // out = [0, 0, 0, 0, 1, 0, 0, 0]
		in = 3'b100; en = 1; #10; // out = [0, 0, 0, 1, 0, 0, 0, 0]
		in = 3'b101; en = 1; #10; // out = [0, 0, 1, 0, 0, 0, 0, 0]
		in = 3'b110; en = 1; #10; // out = [0, 1, 0, 0, 0, 0, 0, 0]
		in = 3'b111; en = 1; #10; // out = [1, 0, 0, 0, 0, 0, 0, 0]
	end
endmodule