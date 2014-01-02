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

parameter width = 10;           //number of filter samples - works out to be 1s at our current data rate

//| Matlab generated FIR filter coefficients
localparam signed GCoEf0 = 16'hfda5;
localparam signed GCoEf1 = 16'h0e32;
localparam signed GCoEf2 = 16'hd54b;
localparam signed GCoEf3 = 16'h52ed;
localparam signed GCoEf4 = 16'h8e58;
localparam signed GCoEf5 = 16'h71a8;
localparam signed GCoEf6 = 16'had13;
localparam signed GCoEf7 = 16'h2ab5;
localparam signed GCoEf8 = 16'hf1ce;
localparam signed GCoEf9 = 16'h025b;

module HighPassFilter(
  input                    ReadDone,        //module runs off this as it's clock.

  //| IMU inputs
  input   wire 		signed   [9:0]    GyroX,
  input   wire   	signed   [9:0]    GyroY,
  input   wire   	signed	 [9:0]    GyroZ,

  //| Filtered outputs
  output  reg     signed   [9:0]    GyroXOut,
  output  reg     signed   [9:0]    GyroYOut,
  output  reg     signed   [9:0]    GyroZOut,

	output	reg				DataReady
  );
// AccelSettingtReadback  gyaxis (
//    .probe (GyroX),
//    .source ()
//    );
//  AccelSettingtReadback  gxaxis (
//    .probe (GyroX),
//    .source ()
//    );
//	  AccelSettingtReadback  gzaxis (
//    .probe (GyroZ),
//    .source ()
//    );
//	 	  AccelSettingtReadback  fgzaxis (
//    .probe (GyroXOut),
//    .source ()
//    );


  //|
  //| Local register and wire instansiations
  //|--------------------------------------------

  reg    signed 	[9:0]      GyroXreg[width-1:0];
  reg    signed	[9:0]      GyroYreg[width-1:0];
  reg    signed	[9:0]      GyroZreg[width-1:0];

  reg    signed 	[32:0]     GyroXSum; //need to prove this register size is always valid
  reg    signed	[32:0]     GyroYSum;
  reg    signed 	[32:0]     GyroZSum = 0;

  reg    [7:0]      z = 0;

  //|
  //| Filter construction
  //|--------------------------------------------
  always@ (posedge ReadDone)
    begin
			DataReady = 0;
      GyroXreg[0] = GyroX;
      GyroYreg[0] = GyroY;
      GyroZreg[0] = GyroZ;

      //| Create output data
      GyroXOut = (GCoEf0*GyroXreg[0])+(GCoEf1*GyroXreg[1])+(GCoEf2*GyroXreg[2])+(GCoEf3*GyroXreg[3])+(GCoEf4*GyroXreg[4])+(GCoEf5*GyroXreg[5])+(GCoEf6*GyroXreg[6])+(GCoEf7*GyroXreg[7])+(GCoEf8*GyroXreg[8])+(GCoEf9*GyroXreg[9]);
      GyroYOut = (GCoEf0*GyroYreg[0])+(GCoEf1*GyroYreg[1])+(GCoEf2*GyroYreg[2])+(GCoEf3*GyroYreg[3])+(GCoEf4*GyroYreg[4])+(GCoEf5*GyroYreg[5])+(GCoEf6*GyroYreg[6])+(GCoEf7*GyroYreg[7])+(GCoEf8*GyroYreg[8])+(GCoEf9*GyroYreg[9]);
      GyroZOut = (GCoEf0*GyroZreg[0])+(GCoEf1*GyroZreg[1])+(GCoEf2*GyroZreg[2])+(GCoEf3*GyroZreg[3])+(GCoEf4*GyroZreg[4])+(GCoEf5*GyroZreg[5])+(GCoEf6*GyroZreg[6])+(GCoEf7*GyroZreg[7])+(GCoEf8*GyroZreg[8])+(GCoEf9*GyroZreg[9]);

			DataReady = 1;
    end
  //| variable length shift register for sensor data
  //|---------------------------------------------------------------
  genvar i;

  generate
    for(i = 1; i < width; i = i+1)
      begin: AccelerometerShiftRegister
        always @ (negedge ReadDone)
          begin
            GyroXreg[i] <= GyroXreg[i-1];
            GyroYreg[i] <= GyroYreg[i-1];
            GyroZreg[i] <= GyroZreg[i-1];
          end
      end
    endgenerate


	/*
	 always@(posedge ReadDone)
		 begin
			GyroXSum = GyroXSum + GyroX/10;
		 end*/
endmodule