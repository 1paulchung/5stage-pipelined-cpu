// A 16:4 mux that is broken down into 3 seperate 4:2 muxes.
// The inputs are in, the inputted data, and sel, the selector. 
// The output is the selected input data based on the selector.

module mux_16 (in, sel, out);
	input logic [15:0] in;
	input logic [3:0] sel;
	output logic out;
	
	wire [3:0] w;
	
	// Four 4:1 muxes have a total of 16 input lines
	mux_4 mux_1 (.in(in[3:0]), .sel(sel[1:0]), .out(w[0]));
	mux_4 mux_2 (.in(in[7:4]), .sel(sel[1:0]), .out(w[1]));
	mux_4 mux_3 (.in(in[11:8]), .sel(sel[1:0]), .out(w[2]));
	mux_4 mux_4 (.in(in[15:12]), .sel(sel[1:0]), .out(w[3]));
	// The output from the above muxes will be input into a fifth
	// mux where the selection lines (sel[3:2]) will output a signal
	mux_4 mux_5 (.in(w[3:0]), .sel(sel[3:2]), .out(out));
endmodule

// We don't have to test every possibility to ensure the mux works, just 
// a few test values. 
module mux_16_testbench();
	logic [15:0] in;
	logic [3:0] sel;
	logic out;
	
	mux_16 dut (.in, .sel, .out);
	
	initial begin
		in <= 16'b0000000000000000; sel <= 4'b0000; #10; // Out = 0
		in <= 16'b1000000000000000; sel <= 4'b0000; #10; // Out = 1
		in <= 16'b1010101010101010; sel <= 4'b0000; #10; // Out = 1
		in <= 16'b1010101010101010; sel <= 4'b0001; #10; // Out = 0
		in <= 16'b1010101010101010; sel <= 4'b0010; #10; // Out = 1
		in <= 16'b1010101010101010; sel <= 4'b0011; #10; // Out = 0
		in <= 16'b0000000000001111; sel <= 4'b0001; #10; // Out = 0
		in <= 16'b0000000000001111; sel <= 4'b1110; #10; // Out = 1
	end
endmodule