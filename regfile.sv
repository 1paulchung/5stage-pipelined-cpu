// The file that creates the 32:64 bit registers. 
//
// Inputs include: 
// - ReadRegister1 ReadRegister2, which addresses to all registers.
// - WriteRegister, which selects which register to write to.
// - WriteData, the data to be written in the selected register.
// - RegWrite, which is the enabler for writing.
// - The clock.
// 
// Outputs include: 
// - ReadData1 and ReadData2, which is the data stored at 
// 	ReadRegister1 and ReadRegister 2.
// - regData, which is the information stored in each register
`timescale 10ps/1fs
module regfile (ReadData1, ReadData2, WriteData,
									ReadRegister1, ReadRegister2, WriteRegister,
									RegWrite, clk);
	input logic [4:0] ReadRegister1, ReadRegister2, WriteRegister;
	input logic [63:0] WriteData; 
	input logic RegWrite, clk;
	output logic [63:0] ReadData1, ReadData2; 
	//     rows   col
	logic [63:0][31:0] ffOut; // Stores 64 bit outputs from 32 registers.
	logic [31:0] decoderOut;
	logic [31:0][63:0] regData; // Stores 32 rows where each row is 64 bits 
	
	
	// Setting up input Decoder from the decoder_32 submodule.
	// Whenever RegWrite is 1, the information on WriteData bus is written into that register.
	// WriteRegister is between 0 and 31, and decoderOut outputs a 32 length signal that has a single 1 bit.
	decoder_32 Decoder (.in(WriteRegister[4:0]), .out(decoderOut[31:0]), .en(RegWrite));
	
	// Setting up registers made up of 64 D_FFs.
	genvar i, j;
	
	generate
	// Create registers 0-30 needed for the system.
		for(i=0; i<31; i++) begin : register 
			// Create a single register consisting of 64 flip flops.
			// Store a single bit from WriteData into a flip flop.
			// decoderOut enables respective DFF.
			for(j=0; j<64; j++) begin : single_dff 
				DFF_enable theReg (.q(ffOut[j][i]), .d(WriteData[j]), .en(decoderOut[i]), .clk);
		   end
		end
	endgenerate 

	// Sets register 31 to always read zero.
	integer k;
	
	always_comb begin
		for(k=0; k<64; k++) 
			ffOut[k][31] = 0;
	end
	
	genvar x;
	generate 
	// Creating two 64:32:1 multiplexers.
		for (x = 0; x < 64; x++) begin : eachMux
		// ReadRegister# selects one from a 32x5 mux.
			mux_32 largeMux1 (.in(ffOut[x][31:0]), .sel(ReadRegister1[4:0]), .out(ReadData1[x]));
			mux_32 largeMux2 (.in(ffOut[x][31:0]), .sel(ReadRegister2[4:0]), .out(ReadData2[x]));
		end
	endgenerate 
	
	// The resulting register data from ffOut is input into regData
	always_comb begin
		for (int a = 0; a < 32; a++) begin
			for (int b = 0; b < 64; b++) begin
				{regData[a][b]} = {ffOut[b][a]};
			end
		end
	end
	
									
endmodule