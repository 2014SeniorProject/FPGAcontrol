//|     IMU Data filtering module for CSUS Senior Design
//|
//|     Author: Ben Smith
//|
//|     This module communicates averages the number of samples specified in the width parameter
//|     performs as a basic discrete low pass filter. It helps remove transients in the sensor
//|     data that could produce output that would otherwise harm the motor
//|
//|     The filter is implemented by a shift register that is created using the genvar construct.
//|     All of the values in the register are averaged and loaded into the output registers every
//|     clock cycle.

//| Matlab generated FIR filter coefficients
localparam CoEf0 = 16'h55a9;
localparam CoEf1 = 16'h4995;
localparam CoEf2 = 16'h5eb7;
localparam CoEf3 = 16'h6efd;
localparam CoEf4 = 16'h77ca;
localparam CoEf5 = 16'h77ca;
localparam CoEf6 = 16'h6efd;
localparam CoEf7 = 16'h5eb7;
localparam CoEf8 = 16'h4995;
localparam CoEf9 = 16'h55a9;

parameter LowPassFilterLength = 10;      //number of filter samples - works out to be 1s at our current data rate

module LowPassFilter(
  input                    ReadDone,        //module runs off this as it's clock.

  //| IMU inputs
  input   wire    [9:0]    AccelX,
  input   wire    [9:0]    AccelY,
  input   wire    [9:0]    AccelZ,

  //| Filtered outputs
  output  reg     [9:0]    AccelXOut,
  output  reg     [9:0]    AccelYOut,
  output  reg     [9:0]    AccelZOut,
	
	output	reg							 DataReady
);

  //|
  //| Local register and wire declarations
  //|---------------------------------------------------------------
  reg    [9:0]      AccelXreg[LowPassFilterLength-1:0];
  reg    [9:0]      AccelYreg[LowPassFilterLength-1:0];
  reg    [9:0]      AccelZreg[LowPassFilterLength-1:0];

  //|
  //| Filter construction
  //|--------------------------------------------
  always@ (posedge ReadDone)
    begin
			DataReady = 0;
      AccelXreg[0] = AccelX;
      AccelYreg[0] = AccelY;
      AccelZreg[0] = AccelZ;

      //| Create output data
      AccelXOut = (CoEf0*AccelXreg[0])+(CoEf1*AccelXreg[1])+(CoEf2*AccelXreg[2])+(CoEf3*AccelXreg[3])+(CoEf4*AccelXreg[4])+(CoEf5*AccelXreg[5])+(CoEf6*AccelXreg[6])+(CoEf7*AccelXreg[7])+(CoEf8*AccelXreg[8])+(CoEf9*AccelXreg[9]);
      AccelYOut = (CoEf0*AccelYreg[0])+(CoEf1*AccelYreg[1])+(CoEf2*AccelYreg[2])+(CoEf3*AccelYreg[3])+(CoEf4*AccelYreg[4])+(CoEf5*AccelYreg[5])+(CoEf6*AccelYreg[6])+(CoEf7*AccelYreg[7])+(CoEf8*AccelYreg[8])+(CoEf9*AccelYreg[9]);
      AccelZOut = (CoEf0*AccelZreg[0])+(CoEf1*AccelZreg[1])+(CoEf2*AccelZreg[2])+(CoEf3*AccelZreg[3])+(CoEf4*AccelZreg[4])+(CoEf5*AccelZreg[5])+(CoEf6*AccelZreg[6])+(CoEf7*AccelZreg[7])+(CoEf8*AccelZreg[8])+(CoEf9*AccelZreg[9]);
			
			//| Generate data valid signal
			DataReady = 1;
    end

  //| variable length shift register for sensor data
  //|---------------------------------------------------------------
  genvar i;

  generate
    for(i = 1; i < LowPassFilterLength; i = i+1)
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
