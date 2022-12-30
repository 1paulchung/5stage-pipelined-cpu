// Checks 16 bits (signal "result" in this module) and determines whether they're 
// equal to 0 or not. checkZero will be true if the value equals 0, and will be 
// false if the value is not 0.

`timescale 10ps/1fs
module nor_16(result, checkZero);
	input logic [15:0] result;
	output logic checkZero;
	logic [3:0] out;
	
	// OR gate for 4 bits.
	// out = 0 if all values are 0.
	// out = 1 if one+ values are 1.
	or #5 or0 (out[0], result[0], result[1], result[2], result[3]);
	or #5 or1 (out[1], result[4], result[5], result[6], result[7]);
	or #5 or2 (out[2], result[8], result[9], result[10], result[11]);
	or #5 or3 (out[3], result[12], result[13], result[14], result[15]);
	
	// nor the result.
	// checkZero = 0 if one+ values in signal out are 1.
	// checkZero = 1 if all values in signal out are 0.
	nor #5 nor1 (checkZero, out[0], out[1], out[2], out[3]);

endmodule

// Test all values from 0-15 and ensure that output signal
// checkZero is 1 only when the result input is 0, and checkZero
// is 0 otherwise.
module nor_16_testbench();
	logic [15:0] result;
	logic checkZero;
	
	nor_16 dut (.result, .checkZero);
	
	// checkZero should only be true when result = 0. 
	initial begin		
		for (int i = 0; i < 16; i++) begin
			result = i; #1000;
		end
		$stop;
	end

endmodule