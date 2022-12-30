// Stage 1: Fetch Instruction. Updates program counter based on branch addresses and signals. 
// 	Inputs are the clock, reset, Db, and control signals BR_op, UncondBr, brTaken.
//		Ouputs are instruction and noBrPC.

`timescale 10ps/1fs
module fetchInstruct(clk, reset, instruction, noBrPC, BR_op, BL_op, Db, Rd_or_X30, UncondBr, BrTaken, 
							decInstruction, alu_result, forward_br, read_data);

	input logic clk, reset, BR_op, BL_op, UncondBr, BrTaken; // clk, reset, control signals
	input logic [1:0] forward_br; // forwarding for BR operation
	input logic [31:0] decInstruction; // instruction from decode stage
	input logic [63:0] Db, alu_result, read_data; // Db, alu result, read data for forwarding branch addresses
	output logic [31:0] instruction; // instruction
	output logic [63:0] noBrPC; // PC if no branching occurs
	output logic [4:0] Rd_or_X30; // Write Register Address
	
	/* condAddr: conditional branch address
	 * uncondAddr: branch address
	 * brAddr: selected branch address based on control signal UncondBr
	 * brPCAddr: PC + shifted brAddr
	 * currentPC: current PC
	 * updatedPC: updated PC
	 * updatedPC_or_Db: selected next PC based on control signal BR_op
	 */	
	logic [63:0] condAddr, uncondAddr, brAddr, brPCAddr, currentPC, updatedPC, updatedPC_or_Db;
	
	// Get instruction from memory
	instructmem getInstruct(.address(currentPC), .instruction, .clk);
	
	// Sign extend unconditional branch address and branch address
	signExtend #(.N(19)) extendCondBranch (.in(decInstruction[23:5]), .out(condAddr));
	signExtend #(.N(26)) extendBrBranch (.in(decInstruction[25:0]), .out(uncondAddr));
	
	// Select branch address based on conditional branching or not. 
	// If UncondBr is 1, brAddr = condAddr, if UncondBr is 0, brAddr = uncondAddr.
	mux_128 whatBranch (.input0(condAddr), .input1(uncondAddr), .select(UncondBr), .out(brAddr));
	
	// Shift branch address by 2
	logic [63:0] shiftBrAddr;
	assign shiftBrAddr = (brAddr << 2);
	 
	// PC = PC + 4
	 fullAdder64 pcPlus4 (.a(currentPC), .b({{60{1'b0}}, 4'b0100}), .cin(1'b0), .sum(noBrPC), .cout());
	
	// PC = PC + shifted brAddr;
	 fullAdder64 brAddrPlusPC (.a(currentPC), .b(shiftBrAddr - 4), .cin(1'b0), .sum(brPCAddr), .cout());
	
	// If conditional branch, check condition
	// If true, PC increases by branch address
	// If false, PC increases by 4
	generate
		genvar j;
		for (j = 0; j < 64; j++) begin : nextPC
			mux_2 checkBranch (.in({brPCAddr[j], noBrPC[j]}), .sel(BrTaken), .out(updatedPC[j])); 
		end
	endgenerate 
	
	// Forward if this is a BR instruction. Forwards either alu result or data memory depending on forward_br.
	// Db is selected if no forwarding occurs.
	logic [63:0] Db_or_alu;
	genvar i;
	generate
		for (i = 0; i < 64; i++) begin: forwardingBR
			mux_4 forwardBR (.in({1'b0, alu_result[i], read_data[i], Db[i]}), .sel(forward_br), .out(Db_or_alu[i]));
		end
	endgenerate
	
	// Create mux to decide whether to go to updatedPC or to go to BR operation (PC = Reg[Rd])
	mux_128 largeMux (.input0(updatedPC), .input1(Db_or_alu), .select(BR_op), .out(updatedPC_or_Db));
	
	// Program counter
	programCounter PCmodule (.clk, .reset, .in(updatedPC_or_Db), .out(currentPC));
	
	// Select Rd or X30 where selector is BL_op. Output is RD_or_X30. This is the Write Register address.
	mux_10 mux0 (.input0(instruction[4:0]), .input1(5'b11110), .select(BL_op), .out(Rd_or_X30));

endmodule

// Testbench module to ensure instructions are properly fetched
module fetchInstruct_testbench();

	 logic clk, reset, BR_op, BL_op;
	 logic [1:0] forward_br;
	 logic UncondBr, BrTaken;
	 logic [63:0] Db; 
	 logic [31:0] instruction; // instruction
	 logic [63:0] noBrPC; // PC if no branching occurs
	 logic [4:0] Rd_or_X30;
	 logic [31:0] decInstruction;
	 logic [63:0] alu_result, read_data;
	
	fetchInstruct dut (.clk, .reset, .instruction, .noBrPC, .BR_op, .BL_op, .Db, .Rd_or_X30, .UncondBr, .BrTaken, 
							.decInstruction, .alu_result, .forward_br, .read_data);
	
	// Set up a simulated clock.
	parameter CLOCK_PERIOD=100;
	initial begin
		clk <= 0;
		forever #(CLOCK_PERIOD/2) clk <= ~clk; #1000;
	end
	
	initial begin
		// Initialize inputs for the module
		alu_result = 64'd32; read_data = 64'd20; @(posedge clk);
		decInstruction = 32'b10010100000000000000000000001000; @(posedge clk);
	
		// Conditional branching occurs but branch not taken. PC = PC + 4
		reset = 0; UncondBr = 0; BrTaken = 0; BR_op = 0; BL_op = 0; @(posedge clk);
		for (int i = 0; i < 2^64; i++) begin
			{Db} = i; forward_br = i[1:0]; @(posedge clk);
		end
		
		// Branching occurs but branch not taken. PC = PC + 4
		UncondBr = 1;
		for (int i = 0; i < 2^64; i++) begin
			{Db} = i; forward_br = i[1:0]; @(posedge clk);
		end
		
		// Conditional branching occurs and branch is taken. PC = PC + brAddr
		UncondBr = 0; BrTaken = 1; #1000;
		for (int i = 0; i < 2^64; i++) begin
			{Db} = i; forward_br = i[1:0]; @(posedge clk);
		end
		
		// Branching occurs and branch is taken. PC = PC + brAddr
		UncondBr = 1; BrTaken = 1; #1000;
		for (int i = 0; i < 2^64; i++) begin
			{Db} = i; forward_br = i[1:0]; @(posedge clk);
		end
		
		// BR_op is true, so PC = Reg[Rd]. UncondBr & brTaken is insignificant. 
		BR_op = 1; BL_op = 1; #1000;
		for (int i = 0; i < 2^64; i++) begin
			{Db} = i; forward_br = i[1:0]; @(posedge clk);
		end
		
	end

endmodule