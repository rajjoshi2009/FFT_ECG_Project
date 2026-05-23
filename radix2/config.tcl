set ::env(DESIGN_NAME) "fft16_r2"

# Explicitly maps your hardware files within the current directory structure
set ::env(VERILOG_FILES) [list \
    "$::env(DESIGN_DIR)/src/fft16_r2.v" \
    "$::env(DESIGN_DIR)/src/butterfly_r2.v" \
    "$::env(DESIGN_DIR)/src/twiddle_rom_r2.v" \
    "$::env(DESIGN_DIR)/src/bit_reversal_r2.v" \
    "$::env(DESIGN_DIR)/src/control_fsm_r2.v" \
    "$::env(DESIGN_DIR)/src/pipeline_regs_r2.v" \
]

# Primary clock domain definition
set ::env(CLOCK_PORT) "clk"
set ::env(CLOCK_PERIOD) "20.0"

# ABC Optimization Tuning Fixes
set ::env(SYNTH_STRATEGY) "DELAY 2"
set ::env(SYNTH_SIZING) 0

# --- Physical Design / Placement Density Fixes ---
# Drop core utilization from 40 to 30 to physically enlarge the die canvas area
set ::env(FP_CORE_UTIL) 30

# Enable congestion-aware placement to actively spread out dense cell clusters
set ::env(PL_TARGET_CONG_AWARE) 1

# Reduce the target placement density. This forces RePlAce to leave empty 
# gaps between cells so OpenDP can legalize them without row overlaps.
set ::env(PL_TARGET_DENSITY) 0.35

set ::env(FP_SIZING) "relative"
