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

parameter width = 67;			//number of filter samples - works out to be 1s at our current data rate

module Filter(
	input 				  				 ReadDone,

	input   wire    [9:0]    AccelX,
  input   wire    [9:0]    AccelY,
  input   wire    [9:0]    AccelZ,

  input   wire    [9:0]    GyroX,
  input   wire    [9:0]    GyroY,
  input   wire    [9:0]    GyroZ,

	output  reg     [9:0]    AccelXOut,
  output  reg     [9:0]    AccelYOut,
  output  reg     [9:0]    AccelZOut,

  output  reg     [9:0]    GyroXOut,
  output  reg     [9:0]    GyroYOut,
  output  reg     [9:0]    GyroZOut
);

	//| Local register and wire declarations
	//|---------------------------------------------------------------
	reg    [9:0]      AccelXreg[width-1:0];
  reg	   [9:0]      AccelYreg[width-1:0];
  reg	   [9:0]      AccelZreg[width-1:0];

  reg	   [9:0]      GyroXreg[width-1:0];
  reg	   [9:0]      GyroYreg[width-1:0];
  reg	   [9:0]      GyroZreg[width-1:0];

  reg 	 [32:0] 		AccelXSum; //need to prove this register size is always valid
	reg 	 [32:0] 		AccelYSum;
	reg 	 [32:0] 		AccelZSum;
	reg 	 [32:0] 		GyroXSum;
	reg 	 [32:0] 		GyroYSum;
	reg 	 [32:0] 		GyroZSum;

	reg		 [7:0]			z = 0;

	//|
	//| Structual coding
	//|---------------------------------------------------------------
	always@ (posedge ReadDone)
		begin
		AccelXSum = 0;
		AccelYSum = 0;
		AccelZSum = 0;
		GyroXSum = 0;
		GyroYSum = 0;
		GyroZSum = 0;

		AccelXreg[0] = AccelX;
		AccelYreg[0] = AccelY;
		AccelZreg[0] = AccelZ;
		GyroXreg[0] = GyroX;
		GyroYreg[0] = GyroY;
		GyroZreg[0] = GyroZ;

		for(z = 0; z < width-1; z = z+1)
				begin
					AccelXSum += AccelXreg[z];
					AccelYSum += AccelYreg[z];
					AccelZSum += AccelZreg[z];
					GyroXSum += GyroXreg[z];
					GyroYSum += GyroYreg[z];
					GyroZSum += GyroZreg[z];
				end

			AccelXSum /= width;
			AccelYSum /= width;
			AccelZSum /= width;
			GyroXSum  /= width;
			GyroYSum  /= width;
			GyroZSum  /= width;

			AccelXOut = AccelXSum;
			AccelYOut = AccelYSum;
			AccelZOut = AccelZSum;
			GyroXOut = GyroXSum;
			GyroYOut = GyroYSum;
			GyroZOut = GyroZSum;
		end

	//| variable length shift register for sensor data
	//|---------------------------------------------------------------
	genvar i;

	generate
		for(i = 1; i < width; i = i+1)
			begin: AccelerometerShiftRegister
				always @ (negedge ReadDone)
					begin
						AccelXreg[i] <= AccelXreg[i-1];
						AccelYreg[i] <= AccelYreg[i-1];
						AccelZreg[i] <= AccelZreg[i-1];

						GyroXreg[i] <= GyroXreg[i-1];
						GyroYreg[i] <= GyroYreg[i-1];
						GyroZreg[i] <= GyroZreg[i-1];
					end
			end
		endgenerate
endmodule
