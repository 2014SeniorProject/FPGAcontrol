#!/bin/sh
#
# This file was automatically generated.
#
# It can be overwritten by nios2-flash-programmer-generate or nios2-flash-programmer-gui.
#

#
# Converting SOF File: C:\FPGAcontrol\output_files\I2C_MyNano.sof to: "..\flash/I2C_MyNano_epcs_flash_controller_0.flash"
#
sof2flash --input="C:/FPGAcontrol/output_files/I2C_MyNano.sof" --output="../flash/I2C_MyNano_epcs_flash_controller_0.flash" --epcs --verbose 

#
# Programming File: "..\flash/I2C_MyNano_epcs_flash_controller_0.flash" To Device: epcs_flash_controller_0
#
nios2-flash-programmer "../flash/I2C_MyNano_epcs_flash_controller_0.flash" --base=0x4011000 --epcs --accept-bad-sysid --device=1 --instance=0 '--cable=USB-Blaster on localhost [USB-0]' --program --verbose 

