`timescale 10 ns / 1 ns

module I2C_MyNano(

	input	CLOCK_50,		//This is the system clock that comes in at 50mhz

	output 	LED,			//This is a register that is used to show the data that was read from the EEPROM in binary.

	input 	KEY,			//This is an input from both of the buttons on board the De0-Nano

	inout	I2C_SCL,		//I2C Clock line, goes to the EEPROM right now
	inout	I2C_SDA,		//I2C Data Line, goes to the EEPROM rigth now

	output	G_Sensor_CS_N	//CS line for accelerometer held high for I2C mode
);

//|
//| Local reg/wire declarations
//|--------------------------------------------
wire 		[9:0]		AccelX;
wire 		[9:0]		AccelY;
wire 		[9:0]		AccelZ;

wire					IMUDataReady;


//|
//| IMU-I2C controller module
//|--------------------------------------------
IMUInterface(
	.CLOCK_50(CLOCK_50),
	.LED(LED),
	.KEY(KEY),
	.I2C_SCL(I2C_SCL),
	.I2C_SDA(I2C_SDA),
	.G_Sensor_CS_N(G_Sensor_CS_N),
	.AccelX(AccelX),
	.AccelY(AccelY),
	.AccelZ(AccelZ),
	.DataValid(IMUDataReady)
	);

endmodule






