// A 32:5 mux that is broken down into 2 seperate 16:4 muxes.
// The inputs are in, the inputted data, and sel, the selector. 
// The output is the selected input data based on the selector.

module mux_32 (in, sel, out);
	input logic [31:0] in;
	input logic [4:0] sel;
	output logic out;
	
	wire [1:0] w;
	
	// 2 16:1 multiplexers creates 32 input lines and a single
	// 2:1 multiplexer selects which of the two 16:1 muxes to output
	mux_16 mux_1 (.in(in[15:0]), .sel(sel[3:0]), .out(w[0]));
	mux_16 mux_2 (.in(in[31:16]), .sel(sel[3:0]), .out(w[1]));
	mux_2  mux_3 (.in(w[1:0]), .sel(sel[4]), .out(out));  
endmodule 

// We don't have to test every possibility to ensure the mux works, just 
// a few test values. 
module mux_32_testbench();
	logic [31:0] in;
	logic [4:0] sel;
	logic out;
	
	mux_32 dut (.in, .sel, .out);
	
	initial begin
		in <= 32'b0000000000000000; sel <= 5'b00000; #10; // Out = 0
		in <= 32'b0000000000000000; sel <= 5'b11111; #10; // Out = 0
		in <= 32'b0000000000000001; sel <= 5'b00000; #10; // Out = 1
		in <= 32'b0000000000000001; sel <= 5'b00001; #10; // Out = 0
		in <= 32'b1010101010101010; sel <= 5'b00000; #10; // Out = 0
		in <= 32'b1010101010101010; sel <= 5'b00001; #10; // Out = 1
		in <= 32'b1010101010101010; sel <= 5'b00010; #10; // Out = 0
		in <= 32'b1010101010101010; sel <= 5'b00011; #10; // Out = 1
		in <= 32'b1111000000000000; sel <= 5'b00000; #10; // Out = 0
		in <= 32'b1111000000000000; sel <= 5'b00100; #10; // Out = 0
		in <= 32'b1111000000000000; sel <= 5'b11110; #10; // Out = 1
		$stop;
	end
endmodule