# Create work library
vlib work

# Compile Verilog
#     All Verilog files that are part of this design should have
#     their own "vlog" line below.
vlog "./mux_2.sv"
vlog "./mux_4.sv"
vlog "./alu.sv"
vlog "./alustim.sv"
vlog "./alu1bit.sv"
vlog "./zero_flag.sv"
vlog "./nor_16.sv"
vlog "./fullAdder.sv"
vlog "./instructmem.sv"
vlog "./datamem.sv"
vlog "./cpu.sv"
vlog "./fetchInstruct.sv"
vlog "./signExtend.sv"
vlog "./alucontrol.sv"
vlog "./control.sv"
vlog "./fullAdder64.sv"
vlog "./programCounter.sv"
vlog "./regfile.sv"
vlog "./mux_10.sv"
vlog "./mux_128.sv"
vlog "./D_FF.sv"
vlog "./DFF_enable.sv"
vlog "./cpustim.sv"
vlog "./forwardingUnit.sv"
vlog "./hazardDetectionUnit.sv"
vlog "./instructDecode.sv"
vlog "./execute.sv"
vlog "./memory.sv"
vlog "./writeBack.sv"
vlog "./IFIDPipeReg.sv"
vlog "./IDEXPipeReg.sv"
vlog "./EXMEMPipeReg.sv"
vlog "./MEMWBPipeReg.sv"
vlog "./mux_64.sv"
vlog "./D_FF_neg.sv"
vlog "./decoder_32.sv"
vlog "./decoder_8.sv"
vlog "./decoder_4.sv"
vlog "./decoder_2.sv"
vlog "./mux_32.sv"
vlog "./mux_16.sv"


# Call vsim to invoke simulator
#     Make sure the last item on the line is the name of the
#     testbench module you want to execute.
vsim -voptargs="+acc" -t 1ps -lib work cpustim

# Source the wave do file
#     This should be the file that sets up the signal window for
#     the module you are testing.
do cpustim_wave.do

# Set the window types
view wave
view structure
view signals

# Run the simulation
run -all

# End
