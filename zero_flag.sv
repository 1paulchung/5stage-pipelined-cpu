// To check if the value is 0, we use nor gates on every
// bit to see if they equal 0. To do this in hardware,
// instead of creating 64 nor gates, we create four 16x1 nor gates,
// so we only have to compare 4 values to determine if input (signal "result")
// is 0 or not. If checkZero = 1, then the input signal is a 0.

`timescale 10ps/1fs
module zero_flag(result, checkZero);
	input logic [63:0] result;
	output logic checkZero;
	
	logic [3:0] norOut;
	
	// NOR gate for four sets of 16 bits.
	// norOut = 1 if 16 bit value equals 0.
	// norOut = 0 if 16 bit value is not 0.
	nor_16 nor0 (.result(result[15:0]), .checkZero(norOut[0])); 
	nor_16 nor1 (.result(result[31:16]), .checkZero(norOut[1])); 
	nor_16 nor2 (.result(result[47:32]), .checkZero(norOut[2])); 
	nor_16 nor3 (.result(result[63:48]), .checkZero(norOut[3])); 
	
	// check if norOut values are 0 or not for all 64 bits.
	// checkZero = 0 if the values in norOut are not 0.
	// checkZero = 1 if the values in norOut are all 0.
	and #5 and0 (checkZero, norOut[0], norOut[1], norOut[2], norOut[3]);
	
endmodule

// Test all values from 0-63 and ensure that output signal
// checkZero is 1 only when the result input is 0, and checkZero
// is 0 otherwise.
module zero_flag_testbench();
	logic [63:0] result;
	logic checkZero;
	
	zero_flag dut (.result, .checkZero);
	
	// checkZero should only be true when result = 0. 
	initial begin		
		for (int i = 0; i < 64; i++) begin
			result = i; #1000;
		end
		$stop;
	end

endmodule