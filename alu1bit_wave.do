onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /alu1bit_testbench/a
add wave -noupdate /alu1bit_testbench/b
add wave -noupdate /alu1bit_testbench/cin
add wave -noupdate /alu1bit_testbench/out
add wave -noupdate /alu1bit_testbench/cout
add wave -noupdate -radix unsigned -radixshowbase 0 /alu1bit_testbench/cntrl
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {367500 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {0 ps} {378 ns}
