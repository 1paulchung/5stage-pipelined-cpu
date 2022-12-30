/*	The forwarding unit. Determines foward signals based on given values and conditions.
 *	Inputs include ex_memRd, id_exRn, id_exRm, mem_wbRd, decRd, exRd, if_idRn, mem_wbRegWrite, ex_memRegWrite, 
 *		eximmediate, cbzop, sturop, exRegWrite, loadop, memMemRead, wbMemRead, BR_op, and BL_op. Outputs include
 *		forwardA, forwardB, forward_br, forward_store, output logic forward_zero, forward_load, and forward_bl.
 */

`timescale 10ps/1fs
module forwardingUnit(ex_memRd, id_exRn, id_exRm, mem_wbRd, mem_wbRegWrite, ex_memRegWrite, forwardA, forwardB, 
							 eximmediate, decRd, exRd, forward_zero, cbzop, sturop, exRegWrite, forward_store, loadop, 
							 forward_load, memMemRead, if_idRn, wbMemRead, forward_br, BR_op, forward_bl, BL_op);

	/*	ex_memRd: Memory Rd
	 * id_exRn: Execute Rn 
	 * id_exRm: Execute Rm 
	 * mem_wbRd: Write Back Rd
	 * decRd: Decode Instruction Rd
	 * exRd: Execute Rd
	 * if_idRn: decode Instruction Rn
	 * mem_wbRegWrite: Write Back RegWrite
	 * ex_memRegWrite: Memory RegWrite
	 * eximmediate: Execute immediate
	 * cbzop: CBZ instruction
	 * sturop: STUR instruction
	 * exRegWrite: Execute RegWrite
	 * loadop: LDUR instruction
	 * memMemRead: Memory MemRead
	 * wbMemRead: Write Back MemRead
	 * BR_op: BR instruction
	 * BL_op: BL instruction
	 */
    input logic [4:0] ex_memRd, id_exRn, id_exRm, mem_wbRd, decRd, exRd, if_idRn; 
    input logic mem_wbRegWrite, ex_memRegWrite, eximmediate, cbzop, sturop, exRegWrite, loadop, memMemRead, 
					 wbMemRead, BR_op, BL_op;
    output logic [1:0] forwardA, forwardB, forward_br, forward_store;
	 output logic forward_zero, forward_load, forward_bl;

    // Execution hazard is when k, k + 1
    // Memory hazard is when k, k + 2
    always_comb begin
        // Forward A
        if ((ex_memRegWrite) && (ex_memRd != 5'b11111) && (ex_memRd == id_exRn)) begin
            forwardA = 2'b10; // EX Hazard
        // end else if ((ex_memRegWrite) && (ex_memRd != 5'b11111) && (ex_memRd != id_exRn) && (mem_wbRd == id_exRn)) begin
        end else if ((mem_wbRegWrite) && (mem_wbRd != 5'b11111) && (mem_wbRd != 5'b11111) && (mem_wbRd == id_exRn)) begin
            forwardA = 2'b01; // MEM Hazard
        end else begin
            forwardA = 2'b00; // no hazard
        end

        // Forward B 
        if ((ex_memRegWrite) && (ex_memRd != 5'b11111) && (ex_memRd == id_exRm) && (~eximmediate)) begin
            forwardB = 2'b10; // EX Hazard
        end else if ((mem_wbRegWrite) && (mem_wbRd != 5'b11111) && (mem_wbRd != 5'b11111) && (mem_wbRd == id_exRm) && (~eximmediate)) begin
            forwardB = 2'b01; // MEM Hazard
        end else begin
            forwardB = 2'b00; // no hazard
        end
		  
		  // Forwarding if CBZ instruction, cbz Rd = previous Rd, if the previous instruction is writing to the 
		  // register, and if that register is not X31.
		  if ((decRd == exRd) && (cbzop) && (exRegWrite == 1'b1) && (exRd != 5'b11111)) begin 
				forward_zero = 1'b1;
		   end else begin
				forward_zero = 1'b0;
			end
			
			// Forwarding if STUR instruction, stur Rd = previous Rd, and if previous instruction is writing to
			// the register.
			if ((decRd == exRd) && (sturop) && (exRegWrite == 1'b1)) begin
				forward_store = 2'b10;
			end else if ((decRd == ex_memRd) && (sturop) && (ex_memRegWrite == 1'b1)) begin
				forward_store = 2'b01;
			end else begin
				forward_store = 2'b00;
			end
			
			// Forwarding if there is a MEM hazard and if there is a LDUR instruction
			if ((forwardA == 2'b01) && (wbMemRead)) begin
				forward_load = 1'b1;
			end else begin
				forward_load = 1'b0;
			end
		
			// Forwarding if BR instruction, if BR Rd = previous Rd, and if previous instruction is writing to
			// the register.
			if ((decRd == exRd) && (BR_op) && (exRegWrite == 1'b1)) begin
				forward_br = 2'b10;
			end else if ((decRd == ex_memRd) && (BR_op) && (ex_memRegWrite == 1'b1)) begin
				forward_br = 2'b01;
			end else begin
				forward_br = 2'b00;
			end
			
			// Forwarding if BL instruction, if previous Rd (stage 3) = two instructions before Rd (stage 5),
			// and stage 5 Rd is writing to the register.
			if ((ex_memRd == id_exRn) && (exRegWrite == 1'b1) && (BL_op)) begin
				forward_bl = 1'b1;
			end else begin
				forward_bl = 1'b0;
			end

    end
endmodule

// Testbench module
module forwardingUnit_testbench();
	  logic [4:0] ex_memRd, id_exRn, id_exRm, mem_wbRd, decRd, exRd, if_idRn; 
     logic mem_wbRegWrite, ex_memRegWrite, eximmediate, cbzop, sturop, exRegWrite, loadop, memMemRead, wbMemRead, BR_op, BL_op;
     logic [1:0] forwardA, forwardB, forward_br, forward_store;
	  logic forward_zero, forward_load, forward_bl;
	
	forwardingUnit dut (.ex_memRd, .id_exRn, .id_exRm, .mem_wbRd, .mem_wbRegWrite, .ex_memRegWrite, .forwardA, .forwardB, 
							 .eximmediate, .decRd, .exRd, .forward_zero, .cbzop, .sturop, .exRegWrite, .forward_store, .loadop, 
							 .forward_load, .memMemRead, .if_idRn, .wbMemRead, .forward_br, .BR_op, .forward_bl, .BL_op);
	
	// For forwarding module, we want to ensure that various control signal values will output the expected forward results. 
	initial begin
		// Use different input combinations to ensure the forwarding logic is correct for input
		for (int i = 0; i < 32; i++) begin
			if (i < 16) begin
				ex_memRegWrite = 1; ex_memRd = i; id_exRn = i; mem_wbRegWrite = 1; mem_wbRd = i; id_exRm = i; eximmediate = 1; decRd = i; exRd = i; BR_op = 1; exRegWrite = 1; BL_op = 1; #1000;
			end else begin
				ex_memRegWrite = 0; ex_memRd = 5'b11111; id_exRn = 0; mem_wbRegWrite = 0; mem_wbRd = 0; id_exRm = 0; eximmediate = 0; decRd = 0; exRd = 0; BR_op = 0; exRegWrite = 0; BL_op = 0; #1000;
			end
		end
		
		// This time ensure that certain cases of fowarding conditions will not be true; thus, the forward values will be 0. 
		// There are also cases where forwarding conditions will cause forward values to be 1 or 2. 
		for (int i = 0; i < 32; i++) begin
			if (i < 16) begin
				ex_memRegWrite = 1; ex_memRd = i + 1; id_exRn = i; mem_wbRegWrite = 1; mem_wbRd = i; id_exRm = i + 1; eximmediate = 1; decRd = i; exRd = i + 1; BR_op = 1; exRegWrite = 1; BL_op = 1; #1000;
			end else begin
				ex_memRegWrite = 0; ex_memRd = 5'b11111; id_exRn = 0; mem_wbRegWrite = 0; mem_wbRd = 0; id_exRm = 0; eximmediate = 0; decRd = 0; exRd = 0; BR_op = 0; exRegWrite = 0; BL_op = 0; #1000;
			end
		end
	
	end
	
endmodule