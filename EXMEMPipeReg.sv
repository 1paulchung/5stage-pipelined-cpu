/* EX-MEM Pipeline Register: Holds values between Execute (Stage 3) and Memory (Stage 4).
 * Inputs include clk, reset, MemWrite, MemRead, BL_op, MemtoReg, exRegWrite, exloadop, is_neg, is_overflow,
 *			alu_result, Db, noBrPC, WriteData_or_noBrPC, ex_DAddr9, exDa, ex_stur_Db, exRd_or_X30, and xfer_size.
 *			Ouputs include memMemWrite, memMemRead, memBL_op, memMemtoReg, memRegWrite, memloadop, memis_neg, 
 *			memis_overflow, memalu_result, memDb, memnoBrPC, memWriteData_or_noBrPC, memex_DAddr9, memDa, mem_stur_Db,
 *			memxfer_size, and memRd_or_X30.
 */

`timescale 10ps/1fs
module EXMEMPipeReg(clk, reset, alu_result, Db, MemWrite, MemRead, xfer_size, noBrPC, BL_op, 
						  WriteData_or_noBrPC, ex_DAddr9, MemtoReg, memMemWrite, memMemRead, memBL_op,
						  memMemtoReg, memalu_result, memDb, memnoBrPC, memWriteData_or_noBrPC, memex_DAddr9,
						  memxfer_size, exRd_or_X30, memRd_or_X30, exRegWrite, memRegWrite, exDa, memDa, ex_stur_Db, mem_stur_Db,
						  exloadop, memloadop, is_neg, memis_neg, is_overflow, memis_overflow);

	input logic clk, reset;
	
	// EX signals
	input logic MemWrite, MemRead, BL_op, MemtoReg, exRegWrite, exloadop, is_neg, is_overflow;
	input logic [63:0] alu_result, Db, noBrPC, WriteData_or_noBrPC, ex_DAddr9, exDa, ex_stur_Db;
	input logic [4:0] exRd_or_X30;
	input logic [3:0] xfer_size;
	
	// MEM signals
	output logic memMemWrite, memMemRead, memBL_op, memMemtoReg, memRegWrite, memloadop, memis_neg, memis_overflow;
	output logic [63:0] memalu_result, memDb, memnoBrPC, memWriteData_or_noBrPC, memex_DAddr9, memDa, mem_stur_Db;
	output logic [3:0] memxfer_size;
	output logic [4:0] memRd_or_X30;
	
	// alu_result
	genvar i;
	generate 
		for (i = 0; i < 64; i++) begin: alu_resultPipe
			D_FF holdalu_result(.q(memalu_result[i]), .d(alu_result[i]), .reset, .clk);
		end
	endgenerate
	
	// memRd_or_X30
	generate 
		for (i = 0; i < 5; i++) begin: exRd_or_X30Pipe
			D_FF holdalu_result(.q(memRd_or_X30[i]), .d(exRd_or_X30[i]), .reset, .clk);
		end
	endgenerate
	
	// Db
	generate 
		for (i = 0; i < 64; i++) begin: DbPipe
			D_FF holdDb(.q(memDb[i]), .d(Db[i]), .reset, .clk);
		end
	endgenerate
	
	// Db (for STUR operation)
	generate 
		for (i = 0; i < 64; i++) begin: DbsturPipe
			D_FF holdDb(.q(mem_stur_Db[i]), .d(ex_stur_Db[i]), .reset, .clk);
		end
	endgenerate
	
	// Da
	generate 
		for (i = 0; i < 64; i++) begin: DaPipe
			D_FF holdDa (.q(memDa[i]), .d(exDa[i]), .reset, .clk);
		end
	endgenerate
	
	// noBrPC
	generate 
		for (i = 0; i < 64; i++) begin: noBrPCPipe
			D_FF holdnoBrPC(.q(memnoBrPC[i]), .d(noBrPC[i]), .reset, .clk);
		end
	endgenerate
	
	// WriteData_or_noBrPC
	generate 
		for (i = 0; i < 64; i++) begin: WriteData_or_noBrPCPipe
			D_FF holdWriteData_or_noBrPC(.q(memWriteData_or_noBrPC[i]), .d(WriteData_or_noBrPC[i]), .reset, .clk);
		end
	endgenerate
	
	// ex_DAddr9
	generate 
		for (i = 0; i < 64; i++) begin: ex_DAddr9Pipe
			D_FF holdex_DAddr9(.q(memex_DAddr9[i]), .d(ex_DAddr9[i]), .reset, .clk);
		end
	endgenerate
	
	// xfer_size
	generate 
		for (i = 0; i < 4; i++) begin: xfer_sizePipe
			D_FF holdxfer_size(.q(memxfer_size[i]), .d(xfer_size[i]), .reset, .clk);
		end
	endgenerate
	
	// MemWrite
	D_FF holdMemWrite(.q(memMemWrite), .d(MemWrite), .reset, .clk);
	
	// MemRead
	D_FF holdMemRead(.q(memMemRead), .d(MemRead), .reset, .clk);
	
	// BL_op
	D_FF holdBL_op(.q(memBL_op), .d(BL_op), .reset, .clk);
	
	// MemtoReg
	D_FF holdMemtoReg(.q(memMemtoReg), .d(MemtoReg), .reset, .clk);
	
	// RegWrite
	D_FF holdRegWrite (.q(memRegWrite), .d(exRegWrite), .reset, .clk);
	
	// loadop
	D_FF holdloadop (.q(memloadop), .d(exloadop), .reset, .clk);
	
	// is_neg
	D_FF holdis_neg (.q(memis_neg), .d(is_neg), .reset, .clk);
	
	// is_overflow
	D_FF holdis_overflow (.q(memis_overflow), .d(is_overflow), .reset, .clk);

endmodule

// Testbench module
module EXMEMPipeReg_testbench();

	logic clk, reset, MemWrite, MemRead, BL_op, MemtoReg;
	logic [63:0] alu_result, Db, noBrPC, WriteData_or_noBrPC, ex_DAddr9;
	logic [3:0] xfer_size;
	
	logic memMemWrite, memMemRead, memBL_op, memMemtoReg;
	logic [63:0] memalu_result, memDb, memnoBrPC, memWriteData_or_noBrPC, memex_DAddr9;
	logic [3:0] memxfer_size;
	
	EXMEMPipeReg dut (.clk, .reset, .alu_result, .Db, .MemWrite, .MemRead, .xfer_size, .noBrPC, .BL_op, .WriteData_or_noBrPC, 
				  .ex_DAddr9, .MemtoReg, .memMemWrite, .memMemRead, .memBL_op, .memMemtoReg, .memalu_result, .memDb, 
				  .memnoBrPC, .memWriteData_or_noBrPC, .memex_DAddr9, .memxfer_size);
							  
	// Set up a simulated clock.
	parameter CLOCK_PERIOD=100;
	initial begin
		clk <= 0;
		forever #(CLOCK_PERIOD/2) clk <= ~clk; #100;
	end
	
	initial begin
	// Test with values to ensure the data is updated next clock cycle.
		reset <= 1; reset <= 0; #10;
		MemtoReg <= 0; MemWrite <= 0; BL_op <= 0; MemRead <=0; #10;
		for (int i = 0; i < 10; i++) begin
			MemtoReg <= ~MemtoReg; #10;
			MemWrite <= ~MemWrite; #10;
			BL_op <= ~BL_op; #10;
			MemtoReg <= ~MemRead; #10;
		end
		
		// Test with values to ensure the data is updated next clock cycle.
		alu_result <= 64'd0; Db <= 64'b 0; noBrPC <= 64'd0; WriteData_or_noBrPC <= 64'd0; ex_DAddr9 <= 64'd0; xfer_size <= 4'd0; #10;
		for (int i = 0; i < 10; i++) begin
			alu_result <= i*1; #10;
			noBrPC <= i*2; #10;
			WriteData_or_noBrPC <= i*3; #10;
			Db <= i*4; #10;
			ex_DAddr9 <= i*5; #10;
			xfer_size <= i; #10;
		end
	end

endmodule
