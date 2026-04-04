# =============================================
# constraints.sdc
# Timing Constraints for FFT ECG Project
# Target: 100 MHz clock at 45nm GPDK045
# FFT ECG Project - B.Tech Final Year
# =============================================

# Create 100 MHz clock (period = 10ns)
create_clock -name clk -period 10 [get_ports clk]

# Clock uncertainty (jitter + skew margin)
set_clock_uncertainty 0.5 [get_clocks clk]

# Clock transition time
set_clock_transition 0.2 [get_clocks clk]

# Input delay (2ns after clock edge)
set_input_delay 2.0 -clock clk [all_inputs]

# Output delay (2ns before clock edge)
set_output_delay 2.0 -clock clk [all_outputs]

# Dont touch clock port
set_dont_touch_network [get_clocks clk]

# Drive strength on inputs
set_driving_cell -lib_cell INVX1 [all_inputs]

# Load on outputs
set_load 0.1 [all_outputs]