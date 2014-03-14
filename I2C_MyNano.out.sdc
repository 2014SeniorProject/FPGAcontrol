## Generated SDC file "I2C_MyNano.out.sdc"

## Copyright (C) 1991-2014 Altera Corporation
## Your use of Altera Corporation's design tools, logic functions 
## and other software and tools, and its AMPP partner logic 
## functions, and any output files from any of the foregoing 
## (including device programming or simulation files), and any 
## associated documentation or information are expressly subject 
## to the terms and conditions of the Altera Program License 
## Subscription Agreement, Altera MegaCore Function License 
## Agreement, or other applicable license agreement, including, 
## without limitation, that your use is for the sole purpose of 
## programming logic devices manufactured by Altera and sold by 
## Altera or its authorized distributors.  Please refer to the 
## applicable agreement for further details.


## VENDOR  "Altera"
## PROGRAM "Quartus II"
## VERSION "Version 13.1.2 Build 173 01/15/2014 SJ Web Edition"

## DATE    "Fri Mar 14 15:59:35 2014"

##
## DEVICE  "EP4CE22F17C6"
##


#**************************************************************
# Time Information
#**************************************************************

set_time_format -unit ns -decimal_places 3



#**************************************************************
# Create Clock
#**************************************************************

create_clock -name {altera_reserved_tck} -period 100.000 -waveform { 0.000 50.000 } [get_ports {altera_reserved_tck}]
create_clock -name {CLOCK_50} -period 20.000 -waveform { 0.000 10.000 } [get_ports {CLOCK_50}]
create_clock -name {IMUCalculations:IMUCalc|IMUInterface:IMU|COUNT[6]} -period 1280.000 -waveform { 0.000 640.000 } [get_nets {IMUCalc|IMU|COUNT[6]}]
create_clock -name {IMUCalculations:IMUCalc|IMUInterface:IMU|DataValid} -period 50000.000 -waveform { 0.000 25000.000 } [get_nets {IMUCalc|IMU|DataValid}]
create_clock -name {RPM:rpmCalc|blips_d1} -period 20.000 -waveform { 0.000 10.000 } [get_nets {rpmCalc|blips_d1 rpmCalc|blips_d2}]


#**************************************************************
# Create Generated Clock
#**************************************************************

create_generated_clock -name {PLL:PLL_inst|altpll:altpll_component|PLL_altpll:auto_generated|wire_pll1_clk[0]} -source [get_pins {PLL_inst|altpll_component|auto_generated|pll1|inclk[0]}] -duty_cycle 50.000 -multiply_by 1 -master_clock {CLOCK_50} [get_pins {PLL_inst|altpll_component|auto_generated|pll1|clk[0]}] 
create_generated_clock -name {PLL:PLL_inst|altpll:altpll_component|PLL_altpll:auto_generated|wire_pll1_clk[1]} -source [get_pins {PLL_inst|altpll_component|auto_generated|pll1|inclk[0]}] -duty_cycle 50.000 -multiply_by 1 -phase -54.000 -master_clock {CLOCK_50} [get_pins {PLL_inst|altpll_component|auto_generated|pll1|clk[1]}] 
create_generated_clock -name {PLL:PLL_inst|altpll:altpll_component|PLL_altpll:auto_generated|wire_pll1_clk[2]} -source [get_pins {PLL_inst|altpll_component|auto_generated|pll1|inclk[0]}] -duty_cycle 50.000 -multiply_by 1 -divide_by 1000 -phase -0.054 -master_clock {CLOCK_50} [get_pins {PLL_inst|altpll_component|auto_generated|pll1|clk[2]}] 
create_generated_clock -name {PLL2:PLL_inst2|altpll:altpll_component|PLL2_altpll:auto_generated|wire_pll1_clk[1]} -source [get_pins {PLL_inst2|altpll_component|auto_generated|pll1|inclk[0]}] -duty_cycle 50.000 -multiply_by 1 -divide_by 2500 -master_clock {CLOCK_50} [get_pins {PLL_inst2|altpll_component|auto_generated|pll1|clk[1]}] 
create_generated_clock -name {LEDClock} -source [get_nets {CLOCK_50~input}] -divide_by 64 -master_clock {CLOCK_50} [get_nets {IMUCalc|AccelAngleLED|CLOCKslow[6] IMUCalc|AccelXLED|CLOCKslow[6] IMUCalc|AccelYLED|CLOCKslow[6] IMUCalc|AccelZLED|CLOCKslow[6] IMUCalc|GyroXLED|CLOCKslow[6] IMUCalc|GyroYLED|CLOCKslow[6] IMUCalc|GyroZLED|CLOCKslow[6]}] 
create_generated_clock -name {CurrentControl} -source [get_ports {CLOCK_50}] -duty_cycle 50.000 -multiply_by 1 -divide_by 16 -master_clock {CLOCK_50} [get_nets {MCA|CC|clkCount[4]}] 
create_generated_clock -name {BrakePWM} -source [get_ports {CLOCK_50}] -duty_cycle 50.000 -multiply_by 1 -divide_by 64 -master_clock {CLOCK_50} [get_nets {Safety|BrakeLightController|brakeOutPWM|CLOCKslow[6]}] 
create_generated_clock -name {HornClock} -source [get_ports {CLOCK_50}] -duty_cycle 50.000 -multiply_by 1 -divide_by 128 -master_clock {CLOCK_50} [get_nets {Safety|HornOut|clkbuffer[7]}] 


#**************************************************************
# Set Clock Latency
#**************************************************************



#**************************************************************
# Set Clock Uncertainty
#**************************************************************



#**************************************************************
# Set Input Delay
#**************************************************************



#**************************************************************
# Set Output Delay
#**************************************************************



#**************************************************************
# Set Clock Groups
#**************************************************************

set_clock_groups -asynchronous -group [get_clocks {altera_reserved_tck}] 


#**************************************************************
# Set False Path
#**************************************************************

set_false_path -from [get_registers {*|alt_jtag_atlantic:*|jupdate}] -to [get_registers {*|alt_jtag_atlantic:*|jupdate1*}]
set_false_path -from [get_registers {*|alt_jtag_atlantic:*|rdata[*]}] -to [get_registers {*|alt_jtag_atlantic*|td_shift[*]}]
set_false_path -from [get_registers {*|alt_jtag_atlantic:*|read}] -to [get_registers {*|alt_jtag_atlantic:*|read1*}]
set_false_path -from [get_registers {*|alt_jtag_atlantic:*|read_req}] 
set_false_path -from [get_registers {*|alt_jtag_atlantic:*|rvalid}] -to [get_registers {*|alt_jtag_atlantic*|td_shift[*]}]
set_false_path -from [get_registers {*|t_dav}] -to [get_registers {*|alt_jtag_atlantic:*|tck_t_dav}]
set_false_path -from [get_registers {*|alt_jtag_atlantic:*|user_saw_rvalid}] -to [get_registers {*|alt_jtag_atlantic:*|rvalid0*}]
set_false_path -from [get_registers {*|alt_jtag_atlantic:*|wdata[*]}] -to [get_registers *]
set_false_path -from [get_registers {*|alt_jtag_atlantic:*|write}] -to [get_registers {*|alt_jtag_atlantic:*|write1*}]
set_false_path -from [get_registers {*|alt_jtag_atlantic:*|write_stalled}] -to [get_registers {*|alt_jtag_atlantic:*|t_ena*}]
set_false_path -from [get_registers {*|alt_jtag_atlantic:*|write_stalled}] -to [get_registers {*|alt_jtag_atlantic:*|t_pause*}]
set_false_path -from [get_registers {*|alt_jtag_atlantic:*|write_valid}] 
set_false_path -to [get_keepers {*altera_std_synchronizer:*|din_s1}]
set_false_path -from [get_keepers {*CPU_nios2_qsys_0:*|CPU_nios2_qsys_0_nios2_oci:the_CPU_nios2_qsys_0_nios2_oci|CPU_nios2_qsys_0_nios2_oci_break:the_CPU_nios2_qsys_0_nios2_oci_break|break_readreg*}] -to [get_keepers {*CPU_nios2_qsys_0:*|CPU_nios2_qsys_0_nios2_oci:the_CPU_nios2_qsys_0_nios2_oci|CPU_nios2_qsys_0_jtag_debug_module_wrapper:the_CPU_nios2_qsys_0_jtag_debug_module_wrapper|CPU_nios2_qsys_0_jtag_debug_module_tck:the_CPU_nios2_qsys_0_jtag_debug_module_tck|*sr*}]
set_false_path -from [get_keepers {*CPU_nios2_qsys_0:*|CPU_nios2_qsys_0_nios2_oci:the_CPU_nios2_qsys_0_nios2_oci|CPU_nios2_qsys_0_nios2_oci_debug:the_CPU_nios2_qsys_0_nios2_oci_debug|*resetlatch}] -to [get_keepers {*CPU_nios2_qsys_0:*|CPU_nios2_qsys_0_nios2_oci:the_CPU_nios2_qsys_0_nios2_oci|CPU_nios2_qsys_0_jtag_debug_module_wrapper:the_CPU_nios2_qsys_0_jtag_debug_module_wrapper|CPU_nios2_qsys_0_jtag_debug_module_tck:the_CPU_nios2_qsys_0_jtag_debug_module_tck|*sr[33]}]
set_false_path -from [get_keepers {*CPU_nios2_qsys_0:*|CPU_nios2_qsys_0_nios2_oci:the_CPU_nios2_qsys_0_nios2_oci|CPU_nios2_qsys_0_nios2_oci_debug:the_CPU_nios2_qsys_0_nios2_oci_debug|monitor_ready}] -to [get_keepers {*CPU_nios2_qsys_0:*|CPU_nios2_qsys_0_nios2_oci:the_CPU_nios2_qsys_0_nios2_oci|CPU_nios2_qsys_0_jtag_debug_module_wrapper:the_CPU_nios2_qsys_0_jtag_debug_module_wrapper|CPU_nios2_qsys_0_jtag_debug_module_tck:the_CPU_nios2_qsys_0_jtag_debug_module_tck|*sr[0]}]
set_false_path -from [get_keepers {*CPU_nios2_qsys_0:*|CPU_nios2_qsys_0_nios2_oci:the_CPU_nios2_qsys_0_nios2_oci|CPU_nios2_qsys_0_nios2_oci_debug:the_CPU_nios2_qsys_0_nios2_oci_debug|monitor_error}] -to [get_keepers {*CPU_nios2_qsys_0:*|CPU_nios2_qsys_0_nios2_oci:the_CPU_nios2_qsys_0_nios2_oci|CPU_nios2_qsys_0_jtag_debug_module_wrapper:the_CPU_nios2_qsys_0_jtag_debug_module_wrapper|CPU_nios2_qsys_0_jtag_debug_module_tck:the_CPU_nios2_qsys_0_jtag_debug_module_tck|*sr[34]}]
set_false_path -from [get_keepers {*CPU_nios2_qsys_0:*|CPU_nios2_qsys_0_nios2_oci:the_CPU_nios2_qsys_0_nios2_oci|CPU_nios2_qsys_0_nios2_ocimem:the_CPU_nios2_qsys_0_nios2_ocimem|*MonDReg*}] -to [get_keepers {*CPU_nios2_qsys_0:*|CPU_nios2_qsys_0_nios2_oci:the_CPU_nios2_qsys_0_nios2_oci|CPU_nios2_qsys_0_jtag_debug_module_wrapper:the_CPU_nios2_qsys_0_jtag_debug_module_wrapper|CPU_nios2_qsys_0_jtag_debug_module_tck:the_CPU_nios2_qsys_0_jtag_debug_module_tck|*sr*}]
set_false_path -from [get_keepers {*CPU_nios2_qsys_0:*|CPU_nios2_qsys_0_nios2_oci:the_CPU_nios2_qsys_0_nios2_oci|CPU_nios2_qsys_0_jtag_debug_module_wrapper:the_CPU_nios2_qsys_0_jtag_debug_module_wrapper|CPU_nios2_qsys_0_jtag_debug_module_tck:the_CPU_nios2_qsys_0_jtag_debug_module_tck|*sr*}] -to [get_keepers {*CPU_nios2_qsys_0:*|CPU_nios2_qsys_0_nios2_oci:the_CPU_nios2_qsys_0_nios2_oci|CPU_nios2_qsys_0_jtag_debug_module_wrapper:the_CPU_nios2_qsys_0_jtag_debug_module_wrapper|CPU_nios2_qsys_0_jtag_debug_module_sysclk:the_CPU_nios2_qsys_0_jtag_debug_module_sysclk|*jdo*}]
set_false_path -from [get_keepers {sld_hub:*|irf_reg*}] -to [get_keepers {*CPU_nios2_qsys_0:*|CPU_nios2_qsys_0_nios2_oci:the_CPU_nios2_qsys_0_nios2_oci|CPU_nios2_qsys_0_jtag_debug_module_wrapper:the_CPU_nios2_qsys_0_jtag_debug_module_wrapper|CPU_nios2_qsys_0_jtag_debug_module_sysclk:the_CPU_nios2_qsys_0_jtag_debug_module_sysclk|ir*}]
set_false_path -from [get_keepers {sld_hub:*|sld_shadow_jsm:shadow_jsm|state[1]}] -to [get_keepers {*CPU_nios2_qsys_0:*|CPU_nios2_qsys_0_nios2_oci:the_CPU_nios2_qsys_0_nios2_oci|CPU_nios2_qsys_0_nios2_oci_debug:the_CPU_nios2_qsys_0_nios2_oci_debug|monitor_go}]
set_false_path -to [get_pins -nocase -compatibility_mode {*|alt_rst_sync_uq1|altera_reset_synchronizer_int_chain*|clrn}]


#**************************************************************
# Set Multicycle Path
#**************************************************************



#**************************************************************
# Set Maximum Delay
#**************************************************************



#**************************************************************
# Set Minimum Delay
#**************************************************************



#**************************************************************
# Set Input Transition
#**************************************************************

