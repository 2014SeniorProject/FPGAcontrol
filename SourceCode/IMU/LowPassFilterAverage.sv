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
//|     IMU Data filtering module for CSUS Senior Design
//|
//|     Author: Ben Smith
//|
//|     This module communicates averages the number of samples specified in the width parameter
//|			performs as a basic discrete low pass filter. It helps remove transients in the sensor
//|			data that could produce output that would otherwise harm the motor
//|
//| 		The filter is implemented by a shift register that is created using the genvar construct.
//|			All of the values in the register are averaged and loaded into the output registers every
//|			clock cycle.
//| =========================================================================================
//| Revision History
//| 1/2/14  BS  added MIT License.
//|
//| =========================================================================================

//| Uncomment the `include "debug.sv" to enter debug mode on this module.
//| Uncomment the `include "timescale.sv" to run a simulation.
//`include "debug.sv"
//`include "timescale.sv"

module LowPassFilterAverage(
	input 				  			ReadDone,				//module runs off this as it's clock.

	//| IMU inputs
	input   wire   signed [9:0]    AccelX,
	input   wire   signed [9:0]    AccelY,
	input   wire   signed [9:0]    AccelZ,

  //| Filtered outputs
	output  reg    signed [9:0]    AccelXOut,
	output  reg    signed [9:0]    AccelYOut,
	output  reg    signed [9:0]    AccelZOut,

	output	reg										 DataReady
);

	
	parameter FilterLength = 200;			//number of filter samples - works out to be 1s at our current data rate

	`ifdef debug
//		AccelSettingtReadback  xaxis (.probe (AccelX));
//		AccelSettingtReadback  fxaxis (.probe (AccelXOut));
	`endif

	//|
	//| Local register and wire declarations
	//|---------------------------------------------------------------
	reg   signed 	[9:0]    	AccelXreg[FilterLength-1:0];
	reg		signed 	[9:0]   	AccelYreg[FilterLength-1:0];
	reg		signed 	[9:0]    	AccelZreg[FilterLength-1:0];

	reg 	signed 	[32:0]  	AccelXSum; //need to prove this register size is always valid
	reg 	signed 	[32:0]  	AccelYSum;
	reg 	signed 	[32:0]  	AccelZSum;

	reg		 	  		[9:0]			z = 0;



	//|
	//| Structual coding
	//|---------------------------------------------------------------
	always@ (posedge ReadDone)
		begin
			DataReady = 0;
			AccelXSum = 0;
			AccelYSum = 0;
			AccelZSum = 0;

			AccelXreg[0] = AccelX;
			AccelYreg[0] = AccelY;
			AccelZreg[0] = AccelZ;

			//| Sum all of the stored values for all sensors and axis
			for(z = 0; z < FilterLength-1; z = z + 10'd1)
				begin
					AccelXSum += AccelXreg[z];
					AccelYSum += AccelYreg[z];
					AccelZSum += AccelZreg[z];
				end

			//| Average the summed values
			AccelXSum /= FilterLength;
			AccelYSum /= FilterLength;
			AccelZSum /= FilterLength;

			//| Set outputs once the operations are complete
			AccelXOut = AccelXSum[9:0];
			AccelYOut = AccelYSum[9:0];
			AccelZOut = AccelZSum[9:0];
			DataReady <= 1;
		end

	//| variable length shift register for sensor data
	//|---------------------------------------------------------------
	genvar i;

	generate
	for(i = 1; i < FilterLength; i = i+1)
		begin: AccelerometerShiftRegister
			always @ (negedge ReadDone)
				begin
					AccelXreg[i] <= AccelXreg[i-1];
					AccelYreg[i] <= AccelYreg[i-1];
					AccelZreg[i] <= AccelZreg[i-1];
				end
		end
	endgenerate

endmodule
