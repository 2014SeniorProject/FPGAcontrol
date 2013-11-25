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
  input 	wire        			DataReady,	//Signals that there is new accel and gyro data ready
  input 	wire signed [9:0] Accel1,			//The accelerometer axis that is used in resolving the angle
  input		wire signed [9:0] Accel2,			//Might need to be used later for more control(perhaps to 
																				//check if the bike has fallen over on its side)
  input 	wire signed [9:0] Gyro,				//Gyroscope data from its Y-axis used to resolve the angle
  output 	reg  signed	[9:0] resolvedAngle		//The resolved angle from the raw data.
);
	
	localparam 					SampleTime = 1;//multiplied by 100	
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
	reg  signed [32:0]  Angle = 0;
	assign resolvedAngle = Angle[9:0];

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