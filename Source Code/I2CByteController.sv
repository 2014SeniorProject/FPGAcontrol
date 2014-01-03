module I2CByteController(
  input                       c50m,           //Input clock

  inout                       I2C_SCL,
  inout                       I2C_SDA,


  output  wire    [17:0]      AccelX,
  output  wire    [17:0]      AccelY,
  output  wire    [17:0]      AccelZ,

  output  wire    [17:0]      GyroX,
  output  wire    [17:0]      GyroY,
  output  wire    [17:0]      GyroZ,

  output  reg                 DataValid
);

endmodule