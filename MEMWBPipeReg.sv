/* MEM-WB Pipeline Register: Holds values between Memory (Stage 4) and Write Back (Stage 5).
 * Inputs include clk, reset, MemtoReg, MemWrite, BL_op, memRegWrite, memMemRead, alu_result, read_data, 
 *			noBrPC, WriteData_or_noBrPC, and memRd_or_X30. Outputs include wbRd_or_X30, wbMemtoReg, wbMemWrite, 
 *			wbBL_op, wbRegWrite, wbMemRead, wbalu_result, wbread_data, wbnoBrPC, and wbWriteData_or_noBrPC.
 */

`timescale 10ps/1fs
module MEMWBPipeReg(clk, reset, alu_result, read_data, MemtoReg, MemWrite, noBrPC, BL_op, WriteData_or_noBrPC,
						  wbMemtoReg, wbMemWrite, wbBL_op, wbalu_result, wbread_data, wbnoBrPC, wbWriteData_or_noBrPC, 
						  memRd_or_X30, wbRd_or_X30, memRegWrite, wbRegWrite, memMemRead, wbMemRead);

	input logic clk, reset;
	
	// MEM signals
	input logic MemtoReg, MemWrite, BL_op, memRegWrite, memMemRead;
	input logic [63:0] alu_result, read_data, noBrPC, WriteData_or_noBrPC;
	input logic [4:0] memRd_or_X30;
	
	// WB signals
	output logic [4:0] wbRd_or_X30;
	output logic wbMemtoReg, wbMemWrite, wbBL_op, wbRegWrite, wbMemRead;
	output logic [63:0] wbalu_result, wbread_data, wbnoBrPC, wbWriteData_or_noBrPC;
	
	// alu_result
	genvar i;
	generate 
		for (i = 0; i < 64; i++) begin: alu_resultPipe
			D_FF holdalu_result(.q(wbalu_result[i]), .d(alu_result[i]), .reset, .clk);
		end
	endgenerate
	
	// read_data
	generate 
		for (i = 0; i < 64; i++) begin: read_dataPipe
			D_FF holdread_data(.q(wbread_data[i]), .d(read_data[i]), .reset, .clk);
		end
	endgenerate
	
	// noBrPC
	generate 
		for (i = 0; i < 64; i++) begin: noBrPCPipe
			D_FF holdnoBrPC(.q(wbnoBrPC[i]), .d(noBrPC[i]), .reset, .clk);
		end
	endgenerate
	
	// Rd_or_X30
	generate 
		for (i = 0; i < 5; i++) begin: Rd_or_X30
			D_FF holdRd_or_X30 (.q(wbRd_or_X30[i]), .d(memRd_or_X30[i]), .reset, .clk);
		end
	endgenerate
	
	// WriteData_or_noBrPC
	generate 
		for (i = 0; i < 64; i++) begin: WriteData_or_noBrPCPipe
			D_FF holdWriteData_or_noBrPC(.q(wbWriteData_or_noBrPC[i]), .d(WriteData_or_noBrPC[i]), .reset, .clk);
		end
	endgenerate
	
	// MemtoReg
	D_FF holdMemtoReg(.q(wbMemtoReg), .d(MemtoReg), .reset, .clk);
	
	// MemWrite
	D_FF holdMemWrite(.q(wbMemWrite), .d(MemWrite), .reset, .clk);
	
	// BL_op
	D_FF holdBL_op(.q(wbBL_op), .d(BL_op), .reset, .clk);
	
	// RegWrite
	D_FF holdRegWrite (.q(wbRegWrite), .d(memRegWrite), .reset, .clk);
	
	// MemRead
	D_FF holdMemRead (.q(wbMemRead), .d(memMemRead), .reset, .clk);

endmodule

// Testbench module
module MEMWBPipeReg_testbench();

	 logic clk, reset, MemtoReg, MemWrite, BL_op, memRegWrite, memMemRead;
	 logic [63:0] alu_result, read_data, noBrPC, WriteData_or_noBrPC;
	 logic [4:0] memRd_or_X30;
	
	 logic [4:0] wbRd_or_X30;
	 logic wbMemtoReg, wbMemWrite, wbBL_op, wbRegWrite, wbMemRead;
	 logic [63:0] wbalu_result, wbread_data, wbnoBrPC, wbWriteData_or_noBrPC;
	
	MEMWBPipeReg dut (.clk, .reset, .alu_result, .read_data, .MemtoReg, .MemWrite, .noBrPC, .BL_op, .WriteData_or_noBrPC,
						  .wbMemtoReg, .wbMemWrite, .wbBL_op, .wbalu_result, .wbread_data, .wbnoBrPC, .wbWriteData_or_noBrPC, 
						  .memRd_or_X30, .wbRd_or_X30, .memRegWrite, .wbRegWrite, .memMemRead, .wbMemRead);
							  
	// Set up a simulated clock.
	parameter CLOCK_PERIOD=100;
	initial begin
		clk <= 0;
		forever #(CLOCK_PERIOD/2) clk <= ~clk; #100;
	end
	
	initial begin
	// Test with values to ensure the data is updated next clock cycle.
		reset <= 1; @(posedge clk);
		reset <= 0; @(posedge clk);
		MemtoReg <= 0; MemWrite <= 0; BL_op <= 0; @(posedge clk);
		for (int i = 0; i < 10; i++) begin
			MemtoReg <= ~MemtoReg; @(posedge clk);
			MemWrite <= ~MemWrite; @(posedge clk);
			BL_op <= ~BL_op; @(posedge clk);
		end
		
		// Test with values to ensure the data is updated next clock cycle.
		alu_result <= 64'd0; read_data <= 64'd100; noBrPC <= 64'd200; WriteData_or_noBrPC <= 64'd300; @(posedge clk);
		for (int i = 0; i < 10; i++) begin
			alu_result <= i*25; @(posedge clk);
			read_data <= i*25; @(posedge clk);
			noBrPC <= i*25; @(posedge clk);
			WriteData_or_noBrPC <= i*25; @(posedge clk);
		end
	end

endmodule
