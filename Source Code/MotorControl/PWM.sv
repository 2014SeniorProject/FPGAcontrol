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
//|     PWM generator module for CSUS Senior Design
//|
//|     Author: David Larribas
//|
//|     This module generates a variable duty cycle PWM signal at about 370khz to
//|			control the bicycle's motor. It it parametized to include a variable offset
//|			that can adjust the floor of the modules response.
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

module PWMGenerator(
	input 								CLOCK_50, 	//| Clock of 50mhz from the De0-Nano Board
	input 	wire 	[9:0] 	PWMinput,		//| 10 Bit input from the filter module. Depends on the accelerometer data.
	output 	reg 					PWMout			//| The PWM output the the Motor Controller.
);

	//| This is an offset for the PWM output. The motor requires around 60% duty cycle to
	//| start running smoothly. This will depend on the cycle time of the PWM.
	parameter 		Offset = 250;
	parameter			pNegEnable = 0; //allows the module to be used as LED indicators

	//| These deal with the timing of the PWM output. CLOCKslow slows down
	reg 		[7:0]		CLOCKslow =0;
	reg 		[15:0] 		COUNT = 0;
	reg			[9:0]		Setting = 0;

	//| Clock divider for output signal
	always @ (posedge CLOCK_50)
		begin
				CLOCKslow= CLOCKslow + 8'd1;
				if (CLOCKslow > 256) CLOCKslow = 0;
		end

	//| Output signal generator
	always @(posedge CLOCKslow[6])
		begin
			//increment output generator
			COUNT = COUNT + 16'd1;

			//|If negatives are enabled, invert two's complement input
			casex({pNegEnable, PWMinput[9]})
				2'b10:  Setting = PWMinput;
				2'b11:	Setting = ~PWMinput + 10'd1;
				default:  Setting = PWMinput;
			endcase

			//| Generate output signal
			if(Setting > 12) //disable output if setting is low enough
				begin
					if(COUNT < Setting + Offset)PWMout=1;
					else PWMout=0;
				end
			else PWMout = 0;

			//| Reset counter at overflow
			if(COUNT>=530)COUNT=0;
		end
endmodule