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

parameter FilterLength = 67;			//number of filter samples - works out to be 1s at our current data rate

module LowPassFilter(
	input 				  				 ReadDone,				//module runs off this as it's clock.

	//| IMU inputs
	input   wire    [9:0]    AccelX,
  input   wire    [9:0]    AccelY,
  input   wire    [9:0]    AccelZ,

  //| Filtered outputs
	output  reg     [9:0]    AccelXOut,
  output  reg     [9:0]    AccelYOut,
  output  reg     [9:0]    AccelZOut
);
	//|
	//| Local register and wire declarations
	//|---------------------------------------------------------------
	reg    [9:0]      AccelXreg[FilterLength-1:0];
  reg	   [9:0]      AccelYreg[FilterLength-1:0];
  reg	   [9:0]      AccelZreg[FilterLength-1:0];

  reg 	 [32:0] 		AccelXSum; //need to prove this register size is always valid
	reg 	 [32:0] 		AccelYSum;
	reg 	 [32:0] 		AccelZSum;

	reg		 [7:0]			z = 0;

	//|
	//| Structual coding
	//|---------------------------------------------------------------
	always@ (posedge ReadDone)
		begin
		AccelXSum = 0;
		AccelYSum = 0;
		AccelZSum = 0;

		AccelXreg[0] = AccelX;
		AccelYreg[0] = AccelY;
		AccelZreg[0] = AccelZ;

		//| Sum all of the stored values for all sensors and axis
		for(z = 0; z < FilterLength-1; z = z+1)
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
			AccelXOut = AccelXSum;
			AccelYOut = AccelYSum;
			AccelZOut = AccelZSum;
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
