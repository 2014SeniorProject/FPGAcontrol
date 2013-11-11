//|     Motor assistance calculator
//|
//|     Authors: Ben Smith, Devin Moore
//|
//|     This module will take in the cadence, heart rate, wheel speed, and IMU data to calculate the required
//|     motor thrust to assist the rider.
//|
//|

//| Uncomment the `include "debug.sv" to enter debug mode on this module.
//| Uncomment the `include "timescale.sv" to run a simulation.
//`include "debug.sv"
//`include "timescale.sv"

module AssistanceAlgorithm(
	input  	wire                	clk,
	//| IMU Inputs 	
	input 	wire	signed 	[9:0] 	resolvedAngle, 
	//| Biometric Inputs
	//input  	wire				[7:0]		HeartRate= 0,
	input  	wire					[7:0]		HeartRateCap, 
	//| Motor output
	output 	reg   signed 	[9:0]   PWMOut
);
	
AccelSettingtReadback  pwmout (
	.probe (PWMOut),
	.source(HeartRate)
 );
	//For testing only
	
	reg				[7:0]		HeartRate;
	//|
	//| Local reg/wire declarations
	//|--------------------------------------------
	reg signed 	[9:0]	Angle;
	reg signed	[9:0]	offset;

	assign Angle = resolvedAngle;
	assign offset = (HeartRate - HeartRateCap);		//Calculate the heart rate difference 
																								//between real and cap

	//| State machine control
	//|--------------------------------------------


	//|
	//| Structual Coding
	//|--------------------------------------------
	 
	always @ (posedge clk)
		begin
			if(offset > 0)	PWMOut = Angle + offset; 	//If the heart rate is higher than the set cap, 
			else PWMOut = Angle;											//then add some power to it scaled with the difference.
			if (PWMOut < 0) PWMOut = 0; 	//If the PWMOut is going to be negative, then just send a 0 
	end																//to turn off the signa to the motor
endmodule