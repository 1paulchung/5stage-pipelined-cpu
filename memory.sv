/* Stage 4: Memory. Reads and writes to and from data memory based on provided signals.
 *	Inputs include clk, MemWrite, MemRead, alu_result, Db, and xfer_size. Output is read_data.
 */

`timescale 10ps/1fs
module memory(clk, alu_result, MemWrite, MemRead, Db, xfer_size, read_data);

	input logic clk, MemWrite, MemRead; // Clk and control signals
	input logic [63:0] alu_result, Db; // Alu result is address, Db is data written at that address
	input logic [3:0] xfer_size;
	output logic [63:0] read_data; // Data from memory

	// Data memory 
	datamem dataMemory (.address(alu_result), .write_enable(MemWrite), .read_enable(MemRead), .write_data(Db), .clk, .xfer_size(xfer_size), .read_data);

endmodule

// Testbench Module
module memory_testbench();
	 logic clk, MemWrite, MemRead;
	 logic [63:0] alu_result, Db;
	 logic [3:0] xfer_size;
	 logic [63:0] read_data;
	 
	 memory dut (clk, alu_result, MemWrite, MemRead, Db, xfer_size, read_data);
	 
	 // Set up a simulated clock.
	parameter CLOCK_PERIOD=100;
	initial begin
		clk <= 0;
		forever #(CLOCK_PERIOD/2) clk <= ~clk; #1000;
	end
	
	initial begin
		// With differing values of MemWrite and MemRead, we want to test how the data memory will record data. 
		for (int i = 0; i < 32; i++) begin
			{MemWrite, MemRead} = i; alu_result = i; Db = i + 1; xfer_size = 4'bxxxx; @(posedge clk);
		end 
	end
endmodule