/* Stage 5: Write Back. Determines write destination register and write data. 
 * Inputs include alu_result, read_data, noBrPC, MemtoReg, and BL_op. Output is WriteData_or_noBrPC.
 */

`timescale 10ps/1fs
module writeBack(alu_result, read_data, MemtoReg, noBrPC, BL_op, WriteData_or_noBrPC);

	input logic [63:0] alu_result, read_data, noBrPC; // Data
	input logic MemtoReg, BL_op; // Control signals
	output logic [63:0] WriteData_or_noBrPC; // Data sent back to reg file 
	
	logic [63:0] WriteData; // alu_result or read_data based on MemtoReg

	// Select alu_result or read_Data where selector is MemtoReg. Output is WriteData.
	mux_128 largeMux1 (.input0(alu_result), .input1(read_data), .select(MemtoReg), .out(WriteData));
	
	// Select WriteData or noBrPC where selector is BL_op. Output is WriteData_or_noBrPC. 
	// This is the Write Register data.
	mux_128 mux1 (.input0(WriteData), .input1(noBrPC), .select(BL_op), .out(WriteData_or_noBrPC));

endmodule

// Testbench module
module writeBack_testbench();
	logic [63:0] alu_result, read_data, noBrPC;
	logic MemtoReg, BL_op;
	
	 logic [63:0] WriteData_or_noBrPC;
	 
	 writeBack dut (.alu_result, .read_data, .MemtoReg, .noBrPC, .BL_op, .WriteData_or_noBrPC);
	
	initial begin
		// Test write back stage with varying control signals MemReg and BL_op and with varying test data.
		for (int i = 0; i < 32; i++) begin
			{MemtoReg, BL_op} = i; alu_result = i; read_data = i + 1; noBrPC = i + 3; #100;
		end 
	end


endmodule