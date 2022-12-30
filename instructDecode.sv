/* Stage 2: Instruction Decode Module. Reads and writes to the register file.
 * Inputs include clk, Reg2Loc, RegWrite, BL_op, cbz_op, sturop, forward_zero, wbBL_op, forward_store, Rd, Rm, 
 *			Rn, writeToRd, DAddr9, WriteData, noBrPC, exalu_result, exDa, wbnoBrPC, Rd_or_X30, and memalu_result. 
 *			Outputs include ex_DAddr9, WriteData_or_noBrPC, Da, Db		
 */

`timescale 10ps/1fs
module instructDecode(clk, writeToRd, Rd, Rm, Rn, Reg2Loc, Da, Db, WriteData_or_noBrPC, Rd_or_X30, RegWrite, DAddr9, 
							 ex_DAddr9, WriteData, BL_op, noBrPC, cbz_op, exalu_result, forward_zero, forward_store, sturop, 
							 exDa, wbnoBrPC, wbBL_op, memalu_result);

	input logic clk, Reg2Loc, RegWrite, BL_op, cbz_op, sturop, forward_zero, wbBL_op; // Clk, control signals, forward signals
	input logic [1:0] forward_store; // Forward for STUR 
	input logic [4:0] Rd, Rm, Rn, writeToRd; // Rd, Rm, Rn, Write Back Rd
	input logic [8:0] DAddr9;	// DT Address
	input logic [63:0] WriteData, noBrPC, exalu_result, exDa, wbnoBrPC, memalu_result; // Data & forwarding data for reg file
	input logic [4:0] Rd_or_X30; // Rd or X30 
	output logic [63:0] ex_DAddr9, WriteData_or_noBrPC, Da, Db; // Extended DT Address, data into reg file
	
	logic [4:0] Rm_or_Rd, writeToRd_or_X30, Rn_or_Rd; // Register destinations into reg file
	logic [63:0] Dareg, Dbreg; // Read data from reg file
	logic cbzOrstur, cbzOrsturFinal; //
	
//	or #5 (cbzOrstur, cbz_op, sturop);
	//or #5 (cbzOrsturFinal, forward_zero, forward_store[1]);

	// Select Rm or Rd where selector is Reg2Loc. Output is Rm_or_Rd.
	mux_10 aMux (.input0(Rd), .input1(Rm), .select(Reg2Loc), .out(Rm_or_Rd));
	
	// Select Rd or X30 where selector is BL_op. Output is RD_or_X30. This is the Write Register address.
	// Select WriteData or noBrPC where selector is BL_op. Output is WriteData_or_noBrPC. This is the Write Register data.
	mux_10 mux0 (.input0(writeToRd), .input1(5'b11110), .select(wbBL_op), .out(writeToRd_or_X30));
	mux_128 mux1 (.input0(WriteData), .input1(wbnoBrPC), .select(wbBL_op), .out(WriteData_or_noBrPC)); 
	mux_10 mux3 (.input0(Rn), .input1(Rd), .select(cbz_op), .out(Rn_or_Rd)); // Rd if need to read for Cbz
	
	// Register file that performs operations specified from Lab 1
	regfile registerFile (.ReadData1(Dareg), .ReadData2(Dbreg), .WriteData(WriteData_or_noBrPC), .ReadRegister1(Rn_or_Rd), .ReadRegister2(Rm_or_Rd), .WriteRegister(writeToRd_or_X30), .RegWrite(RegWrite), .clk);
	
	// If Rd = previous Rd & cbz_op, then forward alu_result as Da
	mux_128 cbzedge (.input0(Dareg), .input1(exalu_result), .select(forward_zero), .out(Da));
	
	// STUR forwarding
	// If data hazard, forward either memory alu result or execute alu result based on forward_store.
	// If no forwarding, Db comes from reg file.
	genvar i;
	generate
		for (i = 0; i < 64; i++) begin: forwardingStore
			mux_4 forwardingStur (.in({1'b0, exalu_result[i], memalu_result[i], Dbreg[i]}), .sel(forward_store), .out(Db[i]));
		end
	endgenerate
	
	// Sign extend DAddr9
	signExtend #(.N(9)) extendDAddr9 (.in(DAddr9), .out(ex_DAddr9));

endmodule

// Testbench module
module instructDecode_testbench();

	 logic clk, Reg2Loc, RegWrite, BL_op, cbz_op, sturop, forward_zero, wbBL_op;
	 logic [1:0] forward_store;
	 logic [4:0] Rd, Rm, Rn, writeToRd;
	 logic [8:0] DAddr9;	
	 logic [63:0] WriteData, noBrPC, exalu_result, exDa, wbnoBrPC, memalu_result;
	 logic [4:0] Rd_or_X30;
	 logic [63:0] ex_DAddr9, WriteData_or_noBrPC, Da, Db;
	
	instructDecode dut (.clk, .writeToRd, .Rd, .Rm, .Rn, .Reg2Loc, .Da, .Db, .WriteData_or_noBrPC, .Rd_or_X30, .RegWrite, .DAddr9, .ex_DAddr9, .WriteData, .BL_op, .noBrPC, .cbz_op, .exalu_result, .forward_zero, .forward_store, .sturop, .exDa, .wbnoBrPC, .wbBL_op, .memalu_result);
							
	// Set up a simulated clock.
	parameter CLOCK_PERIOD=100;
	initial begin
		clk <= 0;
		forever #(CLOCK_PERIOD/2) clk <= ~clk; #100;
	end
	
	initial begin
		// Create test input data
		Reg2Loc <= 0; RegWrite <= 0; DAddr9 <= 0; @(posedge clk);
		BL_op <= 1; cbz_op <= 1; sturop <= 1; forward_zero <= 1; wbBL_op <= 1; forward_store <= 2'b01; Rd <= 5'd2; Rm <= 5'd7; Rn <= 5'd11; writeToRd <= 5'd18; @(posedge clk);
		WriteData <= 64'd39; noBrPC <= 64'd24; exalu_result <= 64'd89; exDa <= 64'd30; wbnoBrPC <= 64'd43; memalu_result <= 64'd89; Rd_or_X30 <= 5'd3; @(posedge clk);
		
		// Initialize Rn, Rm, and Rd
		Rn <= 5'd1; Rm <= 5'd2; Rd <= 5'd3; @(posedge clk); // Rm_or_Rd = Rd
		Reg2Loc <= 1; @(posedge clk); // Rm_or_Rd = Rm;
		
		// Loop through with various values of DAddr to see how the instruction decode stage will perform 
		for (int i = 0; i < 10; i++) begin
			DAddr9 <= i*2; @(posedge clk);
		end
		
		// Create new set of test input data
		Reg2Loc <= 1; RegWrite <= 1; DAddr9 <= 0; @(posedge clk);
		BL_op <= 0; cbz_op <= 0; sturop <= 1; forward_zero <= 1; wbBL_op <= 0; forward_store <= 2'b00; Rd <= 5'd23; Rm <= 5'd17; Rn <= 5'd1; writeToRd <= 5'd8; @(posedge clk);
		WriteData <= 64'd9; noBrPC <= 64'd2; exalu_result <= 64'd9; exDa <= 64'd3; wbnoBrPC <= 64'd3; memalu_result <= 64'd9; Rd_or_X30 <= 5'd30; @(posedge clk);
		
		// Initialize Rn, Rm, and Rd
		Rn <= 5'd1; Rm <= 5'd2; Rd <= 5'd3; @(posedge clk); // Rm_or_Rd = Rd
		Reg2Loc <= 1; @(posedge clk); // Rm_or_Rd = Rm;
		
		// Loop through with various values of DAddr to see how the instruction decode stage will perform 
		for (int i = 0; i < 10; i++) begin
			DAddr9 <= i*2; @(posedge clk);
		end
	end
endmodule