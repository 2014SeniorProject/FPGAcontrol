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
//|     What are we doing here:
//|     kill motor when bike is over 45 degrees right away.
//|		PI heart rate(Hill increases PI constants?)
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
	input 	wire	signed 	[9:0] 	resolvedRoll,		//Have we fallen over?
	input 	wire	signed 	[9:0] 	resolvedPitch,		//Have we flipped over backwards

	//| Biometric Inputs
	input  	wire			[7:0]	HeartRate,			//current user's heart rate
	input  	wire			[7:0]	HeartRateSetPoint,  //User entered rate on cellphone

	//| Motor output
	output 	wire   	signed 	[9:0]   PWMOut,				//PWM to drive motor

	input 	wire					cadence,
	input	wire					brake
);

	//|
	//| Local reg/wire declarations
	//|----------------------------------------------------------------------------------------
	parameter PorportionConstant = 1;
	parameter IntegralConstant = 1;

	//|
	//| Heart Rate PID ()
	//|----------------------------------------------------------------------------------------
	logic 	[7:0]	PIDOutput;

	//| need external module to control motor output behavior(LPF and such)

	//| core calculation logic, rate is constant and set by heart rate from ANT+ module
	always @ (posedge HeartRate)
		begin
			PIDOutput = IntegralCalc(HeartRate) + porportionCalc(HeartRateSetPoint);
			//there should be something here to handle extended dropouts I think
		end

	//| "I" calculate the integral value for current time stamp and store a history of 10 values
	function int IntegralCalc(input reg [7:0] HeartRate);
		int 			HeartRateIntegral;
		logic 	[7:0] 	HeartRateChain[10];

		for(int i = 2; i < 10; i++)
			begin
				HeartRateChain[0] = HeartRate;  // Set lowest bit to new heart rate
				HeartRateChain[i] = HeartRateChain[i-1];	// shift data down delay chain
			end

		for(int i = 1; i < 10; i++)
			begin
				HeartRateIntegral += HeartRateChain[i] - HeartRateChain[i-1];  //calcualte the discrete integral
			end

		return HeartRateIntegral*IntegralConstant;
	endfunction

	//| "P" Calculate the porportional value
	function int porportionCalc(reg HeartRateSetPoint);
		int PorportionOutput;
		int MeasuredError;

		MeasuredError = HeartRateSetPoint-HeartRate;

		return PorportionOutput*PorportionConstant;
	endfunction
endmodule