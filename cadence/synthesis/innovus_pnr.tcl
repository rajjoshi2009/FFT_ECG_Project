# =============================================
# innovus_pnr.tcl
# Innovus Place and Route Script
# Radix-4 FFT - 45nm GPDK045
# FFT ECG Project - B.Tech Final Year
# =============================================

# ---- Step 1: Setup library ----
set_db / .library {
    /path/to/gpdk045/lib/slow_vdd1v0_basicCells.lib
}

set_db / .lef_library {
    /path/to/gpdk045/lef/gpdk045.lef
}

# ---- Step 2: Read netlist from Genus ----
read_netlist ../synthesis/reports_r4/fft16_r4_netlist.v
read_sdc     ../synthesis/reports_r4/fft16_r4_netlist.sdc

# ---- Step 3: Initialize design ----
init_design

# ---- Step 4: Floorplan ----
# 65% utilization - sweet spot for routing
# 1:1 aspect ratio
floorplan -site CoreSite \
          -utilization 65 \
          -aspectRatio 1.0 \
          -coreMarginsBy die \
          -coreMargin 2

# Check floorplan
check_floorplan

# ---- Step 5: Power planning ----
# Add power ring around core
add_rings \
    -nets {VDD VSS} \
    -width 2.0 \
    -spacing 0.5 \
    -layer_top    metal4 \
    -layer_bottom metal4 \
    -layer_left   metal3 \
    -layer_right  metal3

# Add power stripes
add_stripes \
    -nets {VDD VSS} \
    -layer metal4 \
    -direction horizontal \
    -width 1.0 \
    -spacing 0.5 \
    -set_to_set_distance 20

# Connect power
sroute -connect corePin

# Check power
check_power

# ---- Step 6: Placement ----
place_design

# Check placement congestion
check_place

# Optimize placement
optDesign -preCTS

# ---- Step 7: Clock Tree Synthesis ----
# Target skew < 100ps (10% of 10ns period)
set_ccopt_property target_skew 0.1
set_ccopt_property target_max_transition 0.2

create_clock_tree_spec
ccopt_design

# Check CTS results
report_clock_timing -type skew    > reports/cts_skew.rpt
report_clock_timing -type latency > reports/cts_latency.rpt

# ---- Step 8: Post CTS optimization ----
optDesign -postCTS
optDesign -postCTS -hold

# ---- Step 9: Routing ----
routeDesign

# Post route optimization
optDesign -postRoute
optDesign -postRoute -hold

# ---- Step 10: Verification ----
# Check DRC
check_drc > reports/drc.rpt

# Check connectivity
check_connectivity > reports/connectivity.rpt

# ---- Step 11: Extract parasitics ----
extractRC
rcOut -spef outputs/fft16_r4.spef

# ---- Step 12: Reports ----
report_area    > reports/area_pnr.rpt
report_power   > reports/power_pnr.rpt
report_timing  > reports/timing_pnr.rpt

# ---- Step 13: Export GDSII ----
streamOut outputs/fft16_r4.gds \
    -mapFile /path/to/gpdk045/lef/streamOut.map \
    -libName fft16_r4 \
    -units 1000

puts "Place and Route Complete"
puts "Check reports folder for results"
puts "GDSII saved to outputs/fft16_r4.gds"