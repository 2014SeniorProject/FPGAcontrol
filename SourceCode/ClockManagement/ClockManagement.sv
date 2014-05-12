module ClockManagement(
	input 	CLOCK_50,
	
	output 	c50m,
	output 	DRAM_CLK,
	output 	ADC_CLK,
	output 	PWMClock,
	output 	CurrentControlClock,
	output 	PWMLightClock,
	output  IMUI2CClock,
	output  HornClock
);

	PLL	PLL_inst (
		.areset ( ),
		.inclk0 (CLOCK_50),
		.c0 (c50m),
		.c1 (DRAM_CLK),
		.c2 (ADC_CLK),
	);

	PLL2 PLL_inst2 (
		.areset ( ),
		.inclk0 (CLOCK_50),
		.c0 (PWMClock),
		.c1 (CurrentControlClock),
		.c2 (PWMLightClock),
		.c3 ()
	);
	
	PLL3 PLL_inst3 (
		.areset ( ),
		.inclk0 (CLOCK_50),
		.c0 (IMUI2CClock),
		.c1 (HornClock),
		.c2 (),
		.c3 ()
	);
	
endmodule