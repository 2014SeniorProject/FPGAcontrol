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
//|     Sensor Fusion Module
//|
//|     Authors: Devin Moore and Ben Smith
//|
//|     This module is used to obtain a filtered angle of the system. It requires
//|     10 bit signed accelerometer axis data, and the corresponding gyroscope axis
//|     data. It then outputs a resolved "angle" from -255 to 255.
//|

//| Uncomment the `include "debug.sv" to enter debug mode on this module.
//| Uncomment the `include "timescale.sv" to run a simulation.
//`include "debug.sv"
//`include "timescale.sv"

module SensorFusion(
  input 	 	       				DataReady,	//Signals that there is new accel and gyro data ready
  input 	 		signed 	[9:0] 	Accel1,			//The accelerometer axis that is used in resolving the angle
  input		 		signed 	[9:0] 	Accel2,			//Might need to be used later for more control(perhaps to
																					//check if the bike has fallen over on its side)
  input 	 		signed 	[9:0] 	Gyro,				//Gyroscope data from its Y-axis used to resolve the angle
  output 	logic  	signed	[9:0] 	ResolvedAngle		//The resolved angle from the raw data.
);

	localparam 			SampleTime = 1;//multiplied by 100
	localparam signed 	GyroOffset = -7;	//This is the offset of GyroY
	localparam signed 	AccelOffset = 8;	//This is the offest of AccelX
	//|
	//| Sources and Probes used specifically for debugging the angle resolving process
	//|--------------------------------------------------------------------------
	`ifdef debug
//		AccelSettingtReadback  angle1 (.probe (Accel1));
//		AccelSettingtReadback  gyro (.probe (Gyro));
//		AccelSettingtReadback	IMUFusionReadback (.probe(Angle));
//		reg  signed [9:0]		gyroCoef;
	`endif


	//|
	//| Local registers and wires
	//|--------------------------------------------
	logic  signed [32:0]  Angle = 0;
	assign ResolvedAngle = Angle[9:0];

	//|
	//| Main logic
	//|--------------------------------------------
	always@ (posedge DataReady)
		begin: AngleCalculation
			//| Complimentary filter used to adjust gyro drift and smooth data.
			//| angle = (0.98)*(angle + gyro * dt) + (0.02)*(x_acc);
			Angle = (94*((Angle*99 - (Gyro+GyroOffset)/3)/100)+(Accel1+AccelOffset)*(100-94))/100;

		end

endmodule