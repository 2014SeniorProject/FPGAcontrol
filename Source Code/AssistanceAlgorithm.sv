//| Distributed under the MIT licence.
//|
//| Permission is hereby granted, free of charge, to any person obtaining a copy
//| of this software and associated documentation files (the "Software"), to deal
//| in the Software without restriction, including without limitation the rights
//| to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//| copies of the Software, and to permit persons to whom the Software is
//| furnished to do so, subject to the following conditions:
//|
//| The above copyright notice and this permission notice shall be included in
//| all copies or substantial portions of the Software.
//|
//| THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//| IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//| FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//| AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//| LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//| OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//| THE SOFTWARE.
//| =========================================================================================
//|     Motor assistance calculator
//|
//|     Authors: Ben Smith, Devin Moore
//|
//|     This module will take in the cadence, heart rate, wheel speed, and IMU data to calculate the required
//|     motor thrust to assist the rider.
//|
//|
//| =========================================================================================
//| Revision History
//| 1/2/14  BS  added MIT License.
//|
//| =========================================================================================

//| Uncomment the `include "debug.sv" to enter debug mode on this module.
//| Uncomment the `include "timescale.sv" to run a simulation.
//`include "debug.sv"
//`include "timescale.sv"

module AssistanceAlgorithm(
	input  	wire                	clk,
	//| IMU Inputs
	input 	wire	signed 	[9:0] 	resolvedAngle,
	//| Biometric Inputs
	input  	wire			[7:0]	HeartRate,
	input  	wire			[7:0]	HeartRateCap,
	//| Motor output
	output 	reg   	signed 	[9:0]   PWMOut,

	input 	wire					cadence,
	input	wire					brake
);


AccelSettingtReadback  pwmoutput (
	.probe (PWMOut),
 );

AccelSettingtReadback  BRAKE (
	.probe (brake),
 );
 AccelSettingtReadback  CADENCE (
	.probe (cadence),
 );

  AccelSettingtReadback  HEARTRATE (
	.probe (HeartRate),
 );
	//For testing only

	//reg				[7:0]		HeartRate;
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
			if(~brake && cadence)
				begin
					if(offset > 0)	PWMOut = Angle + offset; 	//If the heart rate is higher than the set cap,
					else PWMOut = Angle;						//then add some power to it scaled with the difference.
					if (PWMOut < 0) PWMOut = 0; 				//If the PWMOut is going to be negative, then just send a 0
				end
			else PWMOut = 0;
		end														//to turn off the signa to the motor
endmodule