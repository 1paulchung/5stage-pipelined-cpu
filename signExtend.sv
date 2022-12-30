// Extend biggest bit so output is 64 bits
// 19 is the default value (condAddr19). Module's purpose
// is to extend the sign bits of the given input signal "in."
module signExtend #(parameter N = 19) (in, out);

	// module declarations
	input logic [N-1:0] in;
	output logic [63:0] out;
	
	// The first part of out should equal in.
	assign out[N-1:0] = in[N-1:0];
	
	// The remaining bits are equal to the largest bit of in.
	assign out[63:N] = {(64-N){in[N-1]}};	

endmodule


// Testbench module to ensure value gets sign extended
module signExtend_testbench ();
	logic [4:0] in;
	logic [63:0] out;
	
	// Parameter is 5. If test works on 5 bits, it will work with N bits.
	// We are simply testing with 5 for example sake. 
	signExtend #(.N(5)) dut (.in(in), .out(out));
	
	initial begin
		for (int i = 0; i < 32; i++) begin
			{in} = i; #1000; // out[64:4] = in[4], out[3:0] = in[3:0];
		end
	end
endmodule