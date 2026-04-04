# =============================================
# genus_r4.tcl
# Genus Synthesis Script - Radix-4 FFT
# GPDK045 - 45nm Process Node
# FFT ECG Project - B.Tech Final Year
# =============================================

# ---- Step 1: Setup ----
set_db / .library {
    /path/to/gpdk045/lib/slow_vdd1v0_basicCells.lib
}

# Set top module name
set TOP fft16_r4

# ---- Step 2: Read RTL ----
read_hdl -sv ../../rtl/radix4/butterfly_r4.v
read_hdl -sv ../../rtl/radix4/twiddle_rom_r4.v
read_hdl -sv ../../rtl/radix4/bit_reversal_r4.v
read_hdl -sv ../../rtl/radix4/stage_regs.v
read_hdl -sv ../../rtl/radix4/control_fsm_r4.v
read_hdl -sv ../../rtl/radix4/fft16_r4.v

# ---- Step 3: Elaborate ----
elaborate $TOP

# ---- Step 4: Read constraints ----
read_sdc constraints.sdc

# ---- Step 5: Synthesize ----
syn_generic
syn_map
syn_opt

# ---- Step 6: Power optimization ----
# Clock gating for ultra low power wearable
set_db / .lp_insert_clock_gating true
set_db / .lp_clock_gating_style  integrated

# High effort optimization
syn_opt -effort high

# ---- Step 7: Reports ----
# Area report
report_area > reports_r4/area.rpt

# Timing report
report_timing > reports_r4/timing.rpt

# Power report
# read_saif ../../saif/activity_r4.saif
report_power > reports_r4/power.rpt

# Power breakdown per module
report_power -hier > reports_r4/power_hier.rpt

# Cell count
report_gates > reports_r4/gates.rpt

# QoR summary
report_qor > reports_r4/qor.rpt

# ---- Step 8: Export netlist ----
write_hdl > reports_r4/fft16_r4_netlist.v
write_sdc > reports_r4/fft16_r4_netlist.sdc

puts "Radix-4 Synthesis Complete"
puts "Check reports_r4 folder for results"