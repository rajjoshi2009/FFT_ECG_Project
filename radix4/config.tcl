set ::env(DESIGN_NAME) "fft16_r4"

# Source files
set ::env(VERILOG_FILES) [list \
    "$::env(DESIGN_DIR)/src/fft16_r4.v" \
    "$::env(DESIGN_DIR)/src/butterfly_r4.v" \
    "$::env(DESIGN_DIR)/src/twiddle_rom_r4.v" \
    "$::env(DESIGN_DIR)/src/control_fsm_r4.v" \
    "$::env(DESIGN_DIR)/src/bit_reversal_r4.v" \
    "$::env(DESIGN_DIR)/src/stage_regs.v" \
]

# Clock
set ::env(CLOCK_PORT)   "clk"
set ::env(CLOCK_PERIOD) "25.0"

# Synthesis
set ::env(SYNTH_STRATEGY)           "DELAY 2"
set ::env(SYNTH_SIZING)             0
set ::env(SYNTH_READ_SYSTEMVERILOG) 1

# Floorplan
set ::env(FP_CORE_UTIL) 30
set ::env(FP_SIZING)    "relative"

# Placement
set ::env(PL_TARGET_DENSITY)               0.35
set ::env(PL_TARGET_CONG_AWARE)            1
set ::env(PL_RESIZER_TIMING_OPTIMIZATIONS) 1
set ::env(GLB_RESIZER_TIMING_OPTIMIZATIONS) 1
set ::env(PL_RESIZER_MAX_SLEW_MARGIN)      20
set ::env(PL_RESIZER_MAX_CAP_MARGIN)       20

# CTS
set ::env(CTS_TARGET_SKEW)     200
set ::env(CTS_TOLERANCE)       100
set ::env(CTS_CLK_BUFFER_LIST) "sky130_fd_sc_hd__clkbuf_4 sky130_fd_sc_hd__clkbuf_8"
set ::env(CTS_MAX_CAP)         0.5

# Routing
set ::env(ROUTING_CORES)     4
set ::env(GLB_RT_ADJUSTMENT) 0.1

# Antenna fix
set ::env(DIODE_INSERTION_STRATEGY)    4
set ::env(GLB_RT_ANT_ITERS)           15
set ::env(GLB_RT_MAX_DIODE_INS_ITERS) 10

# LVS - skip due to known SKY130 PDK noconnect net issue
set ::env(RUN_LVS) 0

