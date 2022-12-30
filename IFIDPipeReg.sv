/* IF-ID Pipeline Register: Holds values between Instruction Fetch (Stage 1) and Instruction Decode (Stage 2).
 * Inputs include clk, reset, instruction, noBrPC, and Rd_or_X30. Ouputs are decInstruction, decnoBrPC,
 * 		and decRd_or_X30.
 */ 

`timescale 10ps/1fs
module IFIDPipeReg (clk, reset, instruction, noBrPC, Rd_or_X30, decInstruction, decnoBrPC, decRd_or_X30);
	
	input logic clk, reset;
	
	// IF signals
	input logic [31:0] instruction;
	input logic [63:0] noBrPC;
	input logic [4:0] Rd_or_X30;
	
	// ID signals
	output logic [31:0] decInstruction;
	output logic [63:0] decnoBrPC;
	output logic [4:0] decRd_or_X30;

	// instruction
	genvar i;
	generate 
		for (i = 0; i < 32; i++) begin: instructionPipe
			D_FF holdInstruction(.q(decInstruction[i]), .d(instruction[i]), .reset, .clk);
		end
	endgenerate
	
	// noBrPC
	generate 
		for (i = 0; i < 64; i++) begin: noBrPCPipe
			D_FF holdnoBrPC(.q(decnoBrPC[i]), .d(noBrPC[i]), .reset, .clk);
		end
	endgenerate
	
	// Rd_or_X30
	generate 
		for (i = 0; i < 5; i++) begin: Rd_or_X30Pipe
			D_FF holdRd_or_X30 (.q(decRd_or_X30[i]), .d(Rd_or_X30[i]), .reset, .clk);
		end
	endgenerate

endmodule

// Testbench module
module IFIDPipeReg_testbench();

	logic clk, reset;
	logic [31:0] instruction;
	logic [63:0] noBrPC;
	logic [4:0] Rd_or_X30;
	
	logic [31:0] decInstruction;
	logic [63:0] decnoBrPC;
	logic [4:0] decRd_or_X30;
	
	IFIDPipeReg dut (.clk, .reset, .instruction, .noBrPC, .Rd_or_X30, .decInstruction, .decnoBrPC, .decRd_or_X30);
							  
	// Set up a simulated clock.
	parameter CLOCK_PERIOD=100;
	initial begin
		clk <= 0;
		forever #(CLOCK_PERIOD/2) clk <= ~clk; #100;
	end
	
	initial begin
		reset <= 1; reset <= 0; #10;
		// Test with values to ensure the data is updated next clock cycle. 
		instruction <= 32'd0; noBrPC <= 64'd0; Rd_or_X30 <= 5'd0; #10;
		for (int i = 0; i < 10; i++) begin
			instruction <= i*1; #10;
			noBrPC <= i*2; #10;
			Rd_or_X30 <= i*3; #10;
		end
		
		$stop;
		
	end

endmodule