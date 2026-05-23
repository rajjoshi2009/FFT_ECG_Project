# =============================================
# tempus_sta.tcl
# Tempus Static Timing Analysis Script
# Radix-4 FFT - 45nm GPDK045
# FFT ECG Project - B.Tech Final Year
# =============================================

# ---- Step 1: Setup library ----
set_db / .library {
    /path/to/gpdk045/lib/slow_vdd1v0_basicCells.lib
}

# ---- Step 2: Read netlist and constraints ----
read_netlist ../synthesis/reports_r4/fft16_r4_netlist.v
read_sdc     ../synthesis/reports_r4/fft16_r4_netlist.sdc

# ---- Step 3: Read parasitics from Innovus ----
read_spef ../pnr/outputs/fft16_r4.spef

# ---- Step 4: Initialize timing ----
init_design

# ---- Step 5: Setup timing check at 100 MHz ----
puts "=== Checking timing at 100 MHz ==="
report_timing \
    -path_type full \
    -max_paths 10 \
    > reports/setup_100mhz.rpt

# Check hold timing
report_timing \
    -path_type full \
    -late \
    -max_paths 10 \
    > reports/hold_100mhz.rpt

# Summary
report_timing_summary > reports/timing_summary.rpt

# ---- Step 6: WNS and TNS ----
puts "=== WNS and TNS ==="
report_timing -slack_lesser_than 0 > reports/violations.rpt

# ---- Step 7: Find Fmax ----
# Tighten clock period step by step
# Start at 10ns and reduce until timing fails

puts "=== Finding Fmax ==="

# Try 9ns (111 MHz)
create_clock -name clk -period 9 [get_ports clk]
report_timing > reports/timing_9ns.rpt
puts "9ns timing done - check reports/timing_9ns.rpt"

# Try 8ns (125 MHz)
create_clock -name clk -period 8 [get_ports clk]
report_timing > reports/timing_8ns.rpt
puts "8ns timing done - check reports/timing_8ns.rpt"

# Try 7ns (142 MHz)
create_clock -name clk -period 7 [get_ports clk]
report_timing > reports/timing_7ns.rpt
puts "7ns timing done - check reports/timing_7ns.rpt"

# Try 6ns (166 MHz)
create_clock -name clk -period 6 [get_ports clk]
report_timing > reports/timing_6ns.rpt
puts "6ns timing done - check reports/timing_6ns.rpt"

# Try 5ns (200 MHz)
create_clock -name clk -period 5 [get_ports clk]
report_timing > reports/timing_5ns.rpt
puts "5ns timing done - check reports/timing_5ns.rpt"

# ---- Step 8: PVT Corner Analysis ----
puts "=== PVT Corner Analysis ==="

# TT corner (typical)
read_lib /path/to/gpdk045/lib/typical_vdd1v0_basicCells.lib
report_timing > reports/timing_TT.rpt
puts "TT corner done"

# SS corner (worst case for setup)
read_lib /path/to/gpdk045/lib/slow_vdd1v0_basicCells.lib
report_timing > reports/timing_SS.rpt
puts "SS corner done - worst case"

# FF corner (best case)
read_lib /path/to/gpdk045/lib/fast_vdd1v0_basicCells.lib
report_timing > reports/timing_FF.rpt
puts "FF corner done"

# ---- Step 9: OCV Analysis ----
puts "=== OCV Derating ==="
set_timing_derate -early 0.95 -late 1.05
report_timing > reports/timing_OCV.rpt
puts "OCV analysis done"

# ---- Step 10: Slack histogram ----
report_timing \
    -max_paths 1000 \
    -slack_lesser_than 999 \
    > reports/slack_histogram.rpt

# ---- Step 11: Final summary ----
puts "==========================="
puts "STA Complete"
puts "Check reports folder:"
puts "  setup_100mhz.rpt  - Setup timing at 100 MHz"
puts "  hold_100mhz.rpt   - Hold timing"
puts "  timing_summary.rpt - Full summary"
puts "  timing_Xns.rpt    - Fmax analysis"
puts "  timing_SS.rpt     - Worst case corner"
puts "  timing_OCV.rpt    - OCV analysis"
puts "==========================="