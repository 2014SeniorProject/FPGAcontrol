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
//|     RPM Calculator
//|
//|     Authors: Michael Frith
//|
//|     This module calculates the RPM of the electric motor.
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

module RPM(
	input 	 					clk50M,
	input 	 					blips,
	output 	logic 	[15:0] 		rpm
);

	//parameter clkspeed = 50_000_000; 								//parameter to set the incoming clock's frequency
	//parameter motor_pole_count = 16; 							//parameter to set the motor's pole count
	//parameter internal_gear_reduction_ratio = 5; 	//if motor is internally geared, set the appropriate x:1 ratio here, x being filled in
	
	logic			blips_d1, blips_d2;
	logic	[8:0]	BlipCoutner;
	logic	[25:0]	BlipTimer;
	logic			ResetBlipCounter;
	logic			PosedgeBlip;
	
	RPMProbe u1(rpm);
	RPMProbe u2(BlipCoutner);
	
	assign PosedgeBlip = blips_d1 && !blips_d2;
	
	//	clock counter, always counts at posedge of the clock,
	//	gets reset on posedge of blips
	always @(posedge clk50M) begin
		blips_d1 <= blips;
		blips_d2 <= blips_d1;
		
		if(BlipTimer < 50_000_000) begin
			BlipTimer++;
			ResetBlipCounter <= 0;
		end
		else begin
			rpm <= (BlipCoutner*3)/8;
			ResetBlipCounter <= 1'b1;
			BlipTimer <= 0;
		end
	end
	
	always@(posedge PosedgeBlip, posedge ResetBlipCounter) begin
		if(ResetBlipCounter == 1) BlipCoutner = 0;
		else BlipCoutner++;
	end
	
		
			/*clkcount = clkcount +1;

			//	stores and resets count when motor controller sends in blips,
			//	a square wave with period equal to pole changes/seconds,
			//	does math on stored value, spits out RPM value
			if(blips && !firstPass)
				begin
					clkstore = clkcount;
					clkcount = 32'd0;
					denominator = clkstore*motor_pole_count*internal_gear_reduction_ratio;
					numerator = clkspeed*60;
					rpm = 0;

					// dimensional analysis equation
					//  1 blip  |     1 clock      | 60 seconds |  1 pole | 1 internal rotation | 1 external revolution
					// _________________________________________________________________________________________________________  = RPM
					//  x clocks| clock speed^-1(s)| 1 minute   | 1 blip  | number of poles     | internal gear  reduction ratio
					rpm = numerator/denominator;
					firstPass = 1;
				end

				if (!blips) firstPass = 0;
				//speed = rpm*3*26*60/63360;
				rpmPhone = rpm/4;  */
		

endmodule
