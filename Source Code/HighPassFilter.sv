
parameter width = 10;           //number of filter samples - works out to be 1s at our current data rate

//| Matlab generated FIR filter coefficients
localparam GCoEf0 = 16'hfda5;
localparam GCoEf1 = 16'h0e32;
localparam GCoEf2 = 16'hd54b;
localparam GCoEf3 = 16'h52ed;
localparam GCoEf4 = 16'h8e58;
localparam GCoEf5 = 16'h71a8;
localparam GCoEf6 = 16'had13;
localparam GCoEf7 = 16'h2ab5;
localparam GCoEf8 = 16'hf1ce;
localparam GCoEf9 = 16'h025b;

module HighPassFilter(
  input                    ReadDone,        //module runs off this as it's clock.

  //| IMU inputs
  input   wire    [9:0]    GyroX,
  input   wire    [9:0]    GyroY,
  input   wire    [9:0]    GyroZ,

  //| Filtered outputs
  output  reg     [9:0]    GyroXOut,
  output  reg     [9:0]    GyroYOut,
  output  reg     [9:0]    GyroZOut
  );

  //|
  //| Local register and wire instansiations
  //|--------------------------------------------

  reg    [9:0]      GyroXreg[width-1:0];
  reg    [9:0]      GyroYreg[width-1:0];
  reg    [9:0]      GyroZreg[width-1:0];

  reg    [32:0]     GyroXSum; //need to prove this register size is always valid
  reg    [32:0]     GyroYSum;
  reg    [32:0]     GyroZSum;

  reg    [7:0]      z = 0;

  //|
  //| Filter construction
  //|--------------------------------------------
  always@ (posedge ReadDone)
    begin
      GyroXreg[0] = GyroX;
      GyroYreg[0] = GyroY;
      GyroZreg[0] = GyroZ;

      //| Create output data
      GyroXOut = (GCoEf0*GyroXreg[0])+(GCoEf1*GyroXreg[1])+(GCoEf2*GyroXreg[2])+(GCoEf3*GyroXreg[3])+(GCoEf4*GyroXreg[4])+(GCoEf5*GyroXreg[5])+(GCoEf6*GyroXreg[6])+(GCoEf7*GyroXreg[7])+(GCoEf8*GyroXreg[8])+(GCoEf9*GyroXreg[9]);
      GyroYOut = (GCoEf0*GyroYreg[0])+(GCoEf1*GyroYreg[1])+(GCoEf2*GyroYreg[2])+(GCoEf3*GyroYreg[3])+(GCoEf4*GyroYreg[4])+(GCoEf5*GyroYreg[5])+(GCoEf6*GyroYreg[6])+(GCoEf7*GyroYreg[7])+(GCoEf8*GyroYreg[8])+(GCoEf9*GyroYreg[9]);
      GyroZOut = (GCoEf0*GyroZreg[0])+(GCoEf1*GyroZreg[1])+(GCoEf2*GyroZreg[2])+(GCoEf3*GyroZreg[3])+(GCoEf4*GyroZreg[4])+(GCoEf5*GyroZreg[5])+(GCoEf6*GyroZreg[6])+(GCoEf7*GyroZreg[7])+(GCoEf8*GyroZreg[8])+(GCoEf9*GyroZreg[9]);
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
endmodule