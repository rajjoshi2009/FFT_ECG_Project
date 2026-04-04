# =============================================
# genus_r2.tcl
# Genus Synthesis Script - Radix-2 FFT
# GPDK045 - 45nm Process Node
# FFT ECG Project - B.Tech Final Year
# =============================================

# ---- Step 1: Setup ----
set_db / .library {
    /path/to/gpdk045/lib/slow_vdd1v0_basicCells.lib
}

# Set top module name
set TOP fft16_r2

# ---- Step 2: Read RTL ----
read_hdl -sv ../../rtl/radix2/butterfly_r2.v
read_hdl -sv ../../rtl/radix2/twiddle_rom_r2.v
read_hdl -sv ../../rtl/radix2/bit_reversal_r2.v
read_hdl -sv ../../rtl/radix2/pipeline_regs_r2.v
read_hdl -sv ../../rtl/radix2/control_fsm_r2.v
read_hdl -sv ../../rtl/radix2/fft16_r2.v

# ---- Step 3: Elaborate ----
elaborate $TOP

# ---- Step 4: Read constraints ----
read_sdc constraints.sdc

# ---- Step 5: Synthesize ----
syn_generic
syn_map
syn_opt

# ---- Step 6: Optimize for power ----
# Enable clock gating insertion
set_db / .lp_insert_clock_gating true
set_db / .lp_clock_gating_style  integrated

# Run compile ultra for better optimization
syn_opt -effort high

# ---- Step 7: Reports ----
# Area report
report_area > reports_r2/area.rpt

# Timing report
report_timing > reports_r2/timing.rpt

# Power report with SAIF
# read_saif ../../saif/activity_r2.saif
report_power > reports_r2/power.rpt

# Power breakdown per module
report_power -hier > reports_r2/power_hier.rpt

# Cell count
report_gates > reports_r2/gates.rpt

# QoR summary
report_qor > reports_r2/qor.rpt

# ---- Step 8: Export netlist ----
write_hdl > reports_r2/fft16_r2_netlist.v
write_sdc > reports_r2/fft16_r2_netlist.sdc

puts "Radix-2 Synthesis Complete"
puts "Check reports_r2 folder for results"