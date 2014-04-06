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
`define debug
//`include "timescale.sv"

module LowPassFilterAverage(
	input 				  			ReadDone,				//module runs off this as it's clock.

	//| IMU inputs
	input   		   	signed [9:0]    AccelX,
	input   		   	signed [9:0]    AccelY,
	input   		   	signed [9:0]    AccelZ,

  //| Filtered outputs
	output  logic    	signed [9:0]    AccelXOut,
	output  logic    	signed [9:0]    AccelYOut,
	output  logic    	signed [9:0]    AccelZOut,

	output	logic						DataReady
);

	//|
	//| Local register and wire declarations
	//|---------------------------------------------------------------
	logic	signed  [9:0]    	AccelX_D1;
	logic	signed  [9:0]    	AccelY_D1;
	logic	signed  [9:0]    	AccelZ_D1;

	//|
	//| Structual coding
	//|---------------------------------------------------------------
	always_ff @ (posedge ReadDone)
		begin
			//| calculate recursive moving average
			AccelXOut <= AccelXOut + AccelX/2 - AccelX_D1/2;
			AccelX_D1 <= AccelX;

			//| calculate recursive moving average
			AccelYOut <= AccelYOut + AccelY/2 - AccelY_D1/2;
			AccelY_D1 <= AccelY;

			//| calculate recursive moving average
			AccelZOut <= AccelZOut + AccelZ/2 - AccelZ_D1/2;
			AccelZ_D1 <= AccelZ;
		end
endmodule
