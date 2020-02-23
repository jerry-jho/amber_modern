set project a25
set top cmod_a7_top
set part xc7a35tcpg236-1


create_project $project . -force -part $part
source flist_vivado.tcl
read_xdc ${project}.xdc
eval "synth_design -top $top -part $part $SYN_OPTIONS"
write_checkpoint -force ${project}.post_synth.dcp
write_edif -force ${project}.edf
report_timing_summary -file ${project}.post_synth.timing_summary.rpt
report_utilization -file ${project}.post_synth.util.rpt
write_verilog -mode funcsim -include_xilinx_libs -include_unisim -force ${project}.post_synth.sim.v

opt_design
place_design

report_clock_utilization -file ${project}.post_p.clk_util.rpt
write_checkpoint -force ${project}.post_p.dcp
report_timing_summary -file ${project}.post_p.timing_summary.rpt

route_design

write_checkpoint -force ${project}.post_r.dcp

report_route_status -file ${project}.post_r.status.rpt
report_timing_summary -file ${project}.post_r.timing_summary.rpt
report_drc -file ${project}.post_r.drc.rpt

write_verilog -mode timesim -sdf_anno true -include_xilinx_libs -include_unisim -force ${project}.post_pr.sim.v

write_bitstream -force ${project}.bit