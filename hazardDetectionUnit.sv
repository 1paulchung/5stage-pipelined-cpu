// if (ID/EX.MemRead and
//		((ID/EX.RegisterRd = IF/ID.RegisterRn1) or
//		(ID/EX.RegisterRd = IF/ID.RegisterRm2)))
//		stall the pipeline

module hazardDetectionUnit(exMemRead, exRd, decRn, decRm, stall);

	input logic exMemRead;
	input logic [4:0] exRd, decRn, decRm;
	
	output logic stall;
	
	always_comb begin
		if ((exMemRead) && ((exRd == decRn) || (exRd == decRm))) begin
			stall = 1;
		end else begin
			stall = 0;
		end
	end

endmodule



// This module was not used for Lab 4. 