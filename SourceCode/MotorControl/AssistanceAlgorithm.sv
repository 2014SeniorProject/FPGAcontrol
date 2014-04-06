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

`define debug

module AssistanceAlgorithm(
	input  	                	clk,

	//| IMU Inputs
	input 		signed 	[9:0] 	ResolvedRoll,			//Have we fallen over?
	input 		signed 	[9:0] 	ResolvedPitch,			//Have we flipped over backwards

	//| Biometric Inputs
	input  				[7:0]	HeartRate,				//current user's heart rate
	input  				[7:0]	HeartRateSetPoint,  	//User entered rate on cellphone

	//| Motor output
	output 	   		 	[12:0]  AssistanceRequirement,	//signal to current control module, kinda like torque

	input 						cadence,
	input						brake
);
	//| tuning parameters
	localparam HRMultiplier	=12'd40;
	
	//| Assistance calculation
	logic 		signed 	[12:0]	deltaHR;
	logic		signed  [12:0]	PitchAssist;
	logic 		signed	[12:0] 	AssistanceCalc;

	`ifdef DEBUG 
		AssistanceAlg i0 (.probe(deltaHR));
		AssistanceAlg i2 (.probe(AssistanceRequirement));
	`endif
	
	assign PitchAssist = (ResolvedPitch[9]!=1'b1)?ResolvedPitch:10'b0; //do not use pitch if it is negative
	assign AssistanceRequirement = (AssistanceCalc[12] != 1'b1)?AssistanceCalc:13'b0; //output zero if assistance calc is negative

	assign deltaHR = (signed'({1'b0,HeartRate}) - signed'({1'b0,HeartRateSetPoint}))*signed'({1'b0,HRMultiplier}); // maximum expected difference heart rate 50bpm, send full assistance

	assign AssistanceCalc = (deltaHR-10) + signed'({1'b0,PitchAssist << 2});

endmodule