// 64 input line mux that is implemented at the gate-level. 
module mux_64 (in, sel, out);
	input logic [63:0] in;
	input logic [4:0] sel;
	output logic out;
	
	wire [3:0] w;
	wire [1:0] w2;
	
	// 4 16:1 multiplexers creates 64 input lines and a three
	// 2:1 multiplexer selects which of the four 16:1 muxes to output
	mux_16 mux_1 (.in(in[15:0]), .sel(sel[3:0]), .out(w[0]));
	mux_16 mux_2 (.in(in[31:16]), .sel(sel[3:0]), .out(w[1]));
	mux_16 mux_3 (.in(in[47:32]), .sel(sel[3:0]), .out(w[2]));
	mux_16 mux_4 (.in(in[63:48]), .sel(sel[3:0]), .out(w[3]));
	mux_2  mux_5 (.in(w[1:0]), .sel(sel[4]), .out(w2[0])); 
	mux_2  mux_6 (.in(w[3:2]), .sel(sel[4]), .out(w2[1])); 
	mux_2  mux_7 (.in(w2[1:0]), .sel(sel[4]), .out(out)); 
endmodule 

// Test mux with testbench. 
module mux_64_testbench();
	logic [63:0] in;
	logic [4:0] sel;
	logic out;
	
	mux_64 dut (.in, .sel, .out);
	
	initial begin
		in <= 64'b0000000000000000; sel <= 5'b00000; #10; // Out = 0
		in <= 64'b0000000000000000; sel <= 5'b11111; #10; // Out = 0
		in <= 64'b0000000000000001; sel <= 5'b00000; #10; // Out = 1
		in <= 64'b0000000000000001; sel <= 5'b00001; #10; // Out = 0
		in <= 64'b1010101010101010; sel <= 5'b00000; #10; // Out = 0
		in <= 64'b1010101010101010; sel <= 5'b00001; #10; // Out = 1
		in <= 64'b1010101010101010; sel <= 5'b00010; #10; // Out = 0
		in <= 64'b1010101010101010; sel <= 5'b00011; #10; // Out = 1
		in <= 64'b1111000000000000; sel <= 5'b00000; #10; // Out = 0
		in <= 64'b1111000000000000; sel <= 5'b00100; #10; // Out = 0
		in <= 64'b1111000000000000; sel <= 5'b11110; #10; // Out = 1
		$stop;
	end
endmodule