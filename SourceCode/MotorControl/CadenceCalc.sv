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

module CadenceCalc(
	input 	 					clk50M,
	input 	 					blips,
	output 	logic 		CadenceOut
);

CellPhoneProbe i2(CadenceOut);
CellPhoneProbe i3(blips);
	//parameter clkspeed = 50_000_000; 								//parameter to set the incoming clock's frequency
	//parameter motor_pole_count = 16; 							//parameter to set the motor's pole count
	//parameter internal_gear_reduction_ratio = 5; 	//if motor is internally geared, set the appropriate x:1 ratio here, x being filled in

	logic			blips_d1, blips_d2;
	logic	[26:0]	BlipCoutner;
	logic	[26:0]	BlipTimer;
	logic			ResetBlipCounter;
	logic			PosedgeBlip;
	logic [26:0]	CadenceCount;

	//RPMProbe u1(rpm);
	//RPMProbe u2(BlipCoutner);

	assign PosedgeBlip = blips_d1 && !blips_d2;
	assign CadenceOut = (CadenceCount != 28'd0) ? 1'b1 : 1'b0; 
	//	clock counter, always counts at posedge of the clock,
	//	gets reset on posedge of blips
	always @(posedge clk50M) begin
		blips_d1 <= blips;
		blips_d2 <= blips_d1;

		if(BlipTimer < 100_000_000) begin
			BlipTimer++;
			ResetBlipCounter <= 0;
		end
		else begin
			CadenceCount <= BlipCoutner;
			ResetBlipCounter <= 1'b1;
			BlipTimer <= 0;
		end
	end

	always@(posedge PosedgeBlip, posedge ResetBlipCounter) begin
		if(ResetBlipCounter == 1) BlipCoutner = 0;
		else BlipCoutner++;
	end



endmodule