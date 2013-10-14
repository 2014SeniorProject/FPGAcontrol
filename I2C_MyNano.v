`timescale 10 ns / 1 ns

module I2C_MyNano(

	input			CLOCK_50,		//This is the system clock that comes in at 50mhz

	output 	[7:0]	LED,			//This is a register that is used to show the data that was read from the EEPROM in binary.

	input 			KEY,			//This is an input from both of the buttons on board the De0-Nano

	inout			I2C_SCL,		//I2C Clock line, goes to the EEPROM right now
	inout			I2C_SDA,		//I2C Data Line, goes to the EEPROM rigth now

	inout	wire 	GPIO_10,		//IMU I2C Clock line
	inout	wire	GPIO_11,		//IMU I2C Data Line

	output			G_Sensor_CS_N,	//CS line for accelerometer held high for I2C mode
	output 	wire 	PWMout,
	output 	wire 	waveFormsPin

);

//|
//| Local reg/wire declarations
//|--------------------------------------------
wire 		[9:0]		AccelX;
wire 		[9:0]		AccelY;
wire 		[9:0]		AccelZ;

wire						IMUDataReady;
wire 		[9:0]		PWMinput;

assign LED[0] = PWMout;
assign waveFormsPin = PWMout;

//|
//| IMU-I2C controller module
//|--------------------------------------------
IMUInterface(
	.CLOCK_50(CLOCK_50),
	.I2C_SCL(GPIO_10),
	.I2C_SDA(GPIO_11),
	.G_Sensor_CS_N(G_Sensor_CS_N),
	.AccelX(AccelX),
	.AccelY(AccelY),
	.AccelZ(AccelZ),
	.DataValid(IMUDataReady)
	);

	Filter(
	.AccelX(AccelX),
	.ReadDone(IMUDataReady),
	.PWMinput(PWMinput)
	);

	PWM(
	.CLOCK_50(CLOCK_50),
	.PWMinput(PWMinput),
	.PWMout(PWMout)
	);

endmodule





