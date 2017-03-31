## Generated SDC file "de1_top.out.sdc"

## Copyright (C) 1991-2016 Altera Corporation. All rights reserved.
## Your use of Altera Corporation's design tools, logic functions 
## and other software and tools, and its AMPP partner logic 
## functions, and any output files from any of the foregoing 
## (including device programming or simulation files), and any 
## associated documentation or information are expressly subject 
## to the terms and conditions of the Altera Program License 
## Subscription Agreement, the Altera Quartus Prime License Agreement,
## the Altera MegaCore Function License Agreement, or other 
## applicable license agreement, including, without limitation, 
## that your use is for the sole purpose of programming logic 
## devices manufactured by Altera and sold by Altera or its 
## authorized distributors.  Please refer to the applicable 
## agreement for further details.


## VENDOR  "Altera"
## PROGRAM "Quartus Prime"
## VERSION "Version 16.0.1 Build 218 06/01/2016 SJ Standard Edition"

## DATE    "Fri Mar 31 09:24:19 2017"

##
## DEVICE  "5CSEMA5F31C6"
##


#**************************************************************
# Time Information
#**************************************************************

set_time_format -unit ns -decimal_places 3



#**************************************************************
# Create Clock
#**************************************************************

create_clock -name {clk_i} -period 20.000 -waveform { 0.000 10.000 } [get_ports { clk_i }]


#**************************************************************
# Create Generated Clock
#**************************************************************



#**************************************************************
# Set Clock Latency
#**************************************************************



#**************************************************************
# Set Clock Uncertainty
#**************************************************************

set_clock_uncertainty -rise_from [get_clocks {clk_i}] -rise_to [get_clocks {clk_i}] -setup 0.170  
set_clock_uncertainty -rise_from [get_clocks {clk_i}] -rise_to [get_clocks {clk_i}] -hold 0.060  
set_clock_uncertainty -rise_from [get_clocks {clk_i}] -fall_to [get_clocks {clk_i}] -setup 0.170  
set_clock_uncertainty -rise_from [get_clocks {clk_i}] -fall_to [get_clocks {clk_i}] -hold 0.060  
set_clock_uncertainty -fall_from [get_clocks {clk_i}] -rise_to [get_clocks {clk_i}] -setup 0.170  
set_clock_uncertainty -fall_from [get_clocks {clk_i}] -rise_to [get_clocks {clk_i}] -hold 0.060  
set_clock_uncertainty -fall_from [get_clocks {clk_i}] -fall_to [get_clocks {clk_i}] -setup 0.170  
set_clock_uncertainty -fall_from [get_clocks {clk_i}] -fall_to [get_clocks {clk_i}] -hold 0.060  


#**************************************************************
# Set Input Delay
#**************************************************************



#**************************************************************
# Set Output Delay
#**************************************************************



#**************************************************************
# Set Clock Groups
#**************************************************************



#**************************************************************
# Set False Path
#**************************************************************



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

