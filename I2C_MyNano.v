//|     Top Level module for CSUS Senior Design
//|
//|     Author: Ben Smith and Devin Moore
//|
//|     This is the top level module for Project Forward. It instantiates modules to
//|			control the motor, communicate with the cellphone application, and the various
//|			sensors required to perform it's tasks.
//|
`timescale 10 ns / 1 ns

module I2C_MyNano(

	input							CLOCK_50,		//This is the system clock that comes in at 50mhz

	output 		[7:0]		LED,				//This is a register that is used to show the data that was read from the EEPROM in binary.

	input 						KEY,				//This is an input from both of the buttons on board the De0-Nano

	inout							I2C_SCL,		//I2C Clock line, goes to the EEPROM right now
	inout							I2C_SDA,		//I2C Data Line, goes to the EEPROM rigth now

	inout			wire 		GPIO_10,		//IMU I2C Clock line
	inout			wire		GPIO_11,		//IMU I2C Data Line

	output						G_Sensor_CS_N,	//CS line for accelerometer held high for I2C mode
	output 		wire 		PWMout,
	output 		wire 		waveFormsPin

);

	//|
	//| Local reg/wire declarations
	//|--------------------------------------------

	//| Accelerometer
	wire 		[9:0]		AccelX;
	wire 		[9:0]		AccelY;
	wire 		[9:0]		AccelZ;

	//| Gyroscope
	wire 		[9:0]		GyroX;
	wire 		[9:0]		GyroY;
	wire 		[9:0]		GyroZ;

	//| IMU data trigger
	wire						IMUDataReady;

	//| Motor output
	wire 		[9:0]		PWMinput;

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
	.GyroX(GyroX),
	.GyroY(GyroY),
	.GyroZ(GyroZ),
	.DataValid(IMUDataReady)
	);

	Filter(
	.ReadDone(IMUDataReady),
	.AccelX(AccelX),
	.AccelY(AccelY),
	.AccelZ(AccelZ),
	.GyroX(GyroX),
	.GyroY(GyroY),
	.GyroZ(GyroZ)
	);

	//|
	//| IMU LED visualization
	//|--------------------------------------------
	PWMGenerator #(
		.Offset(0)
	)AccelXLED(
		.CLOCK_50(CLOCK_50),
		.PWMinput(AccelX),
		.PWMout(LED[0])
		);

		PWMGenerator #(
		.Offset(0)
	)AccelYLED(
		.CLOCK_50(CLOCK_50),
		.PWMinput(AccelY),
		.PWMout(LED[1])
		);

		PWMGenerator #(
		.Offset(0)
	)AccelZLED(
		.CLOCK_50(CLOCK_50),
		.PWMinput(AccelZ),
		.PWMout(LED[2])
		);

		PWMGenerator #(
		.Offset(0)
	)GyroXLED(
		.CLOCK_50(CLOCK_50),
		.PWMinput(GyroX),
		.PWMout(LED[3])
		);

		PWMGenerator #(
		.Offset(0)
	)GyroYLED(
		.CLOCK_50(CLOCK_50),
		.PWMinput(GyroY),
		.PWMout(LED[4])
		);

		PWMGenerator #(
		.Offset(0)
	)GyroZLED(
		.CLOCK_50(CLOCK_50),
		.PWMinput(GyroZ),
		.PWMout(LED[5])
		);
endmodule





