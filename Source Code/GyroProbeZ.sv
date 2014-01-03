	// megafunction wizard: %In-System Sources and Probes%
// GENERATION: STANDARD
// VERSION: WM1.0
// MODULE: altsource_probe

// ============================================================
// File Name: AccelSettingtReadback_bb.v
// Megafunction Name(s):
// 			altsource_probe
//
// Simulation Library Files(s):
// 			altera_mf
// ============================================================
// ************************************************************
// THIS IS A WIZARD-GENERATED FILE. DO NOT EDIT THIS FILE!
//
// 13.0.1 Build 232 06/12/2013 SP 1 SJ Web Edition
// ************************************************************


//Copyright (C) 1991-2013 Altera Corporation
//Your use of Altera Corporation's design tools, logic functions
//and other software and tools, and its AMPP partner logic
//functions, and any output files from any of the foregoing
//(including device programming or simulation files), and any
//associated documentation or information are expressly subject
//to the terms and conditions of the Altera Program License
//Subscription Agreement, Altera MegaCore Function License
//Agreement, or other applicable license agreement, including,
//without limitation, that your use is for the sole purpose of
//programming logic devices manufactured by Altera and sold by
//Altera or its authorized distributors.  Please refer to the
//applicable agreement for further details.


// synopsys translate_off
`timescale 1 ps / 1 ps
// synopsys translate_on
module GyroProbeZ (
	probe,
	source);

	input	[9:0]  probe;
	output	[9:0]  source;

	wire [9:0] sub_wire0;
	wire [9:0] source = sub_wire0[9:0];

	altsource_probe	altsource_probe_component (
				.probe (probe),
				.source (sub_wire0)
				// synopsys translate_off
				,
				.clrn (),
				.ena (),
				.ir_in (),
				.ir_out (),
				.jtag_state_cdr (),
				.jtag_state_cir (),
				.jtag_state_e1dr (),
				.jtag_state_sdr (),
				.jtag_state_tlr (),
				.jtag_state_udr (),
				.jtag_state_uir (),
				.raw_tck (),
				.source_clk (),
				.source_ena (),
				.tdi (),
				.tdo (),
				.usr1 ()
				// synopsys translate_on
				);
	defparam
		altsource_probe_component.enable_metastability = "NO",
		altsource_probe_component.instance_id = "GYRZ",
		altsource_probe_component.probe_width = 10,
		altsource_probe_component.sld_auto_instance_index = "YES",
		altsource_probe_component.sld_instance_index = 0,
		altsource_probe_component.source_initial_value = " 0",
		altsource_probe_component.source_width = 10;


endmodule

// ============================================================
// CNX file retrieval info
// ============================================================
// Retrieval info: PRIVATE: INTENDED_DEVICE_FAMILY STRING "Cyclone IV E"
// Retrieval info: LIBRARY: altera_mf altera_mf.altera_mf_components.all
// Retrieval info: CONSTANT: ENABLE_METASTABILITY STRING "NO"
// Retrieval info: CONSTANT: INSTANCE_ID STRING "ACSE"
// Retrieval info: CONSTANT: PROBE_WIDTH NUMERIC "10"
// Retrieval info: CONSTANT: SLD_AUTO_INSTANCE_INDEX STRING "YES"
// Retrieval info: CONSTANT: SLD_INSTANCE_INDEX NUMERIC "0"
// Retrieval info: CONSTANT: SOURCE_INITIAL_VALUE STRING " 0"
// Retrieval info: CONSTANT: SOURCE_WIDTH NUMERIC "10"
// Retrieval info: USED_PORT: probe 0 0 10 0 INPUT NODEFVAL "probe[9..0]"
// Retrieval info: USED_PORT: source 0 0 10 0 OUTPUT NODEFVAL "source[9..0]"
// Retrieval info: CONNECT: @probe 0 0 10 0 probe 0 0 10 0
// Retrieval info: CONNECT: source 0 0 10 0 @source 0 0 10 0
// Retrieval info: GEN_FILE: TYPE_NORMAL AccelSettingtReadback_bb.v TRUE
// Retrieval info: GEN_FILE: TYPE_NORMAL AccelSettingtReadback_bb.inc FALSE
// Retrieval info: GEN_FILE: TYPE_NORMAL AccelSettingtReadback_bb.cmp FALSE
// Retrieval info: GEN_FILE: TYPE_NORMAL AccelSettingtReadback_bb.bsf FALSE
// Retrieval info: GEN_FILE: TYPE_NORMAL AccelSettingtReadback_bb_inst.v FALSE
// Retrieval info: GEN_FILE: TYPE_NORMAL AccelSettingtReadback_bb_bb.v TRUE
// Retrieval info: LIB_FILE: altera_mf