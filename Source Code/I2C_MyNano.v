//|     Top Level module for CSUS Senior Design
//|
//|     Author: Ben Smith and Devin Moore
//|
//|     This is the top level module for Project Forward. It instantiates modules to
//|			control the motor, communicate with the cellphone application, and the various
//|			sensors required to perform it's tasks.
//|

//| Uncomment the `include "debug.sv" to enter debug mode on this module.
//| Uncomment the `include "timescale.sv" to run a simulation.
//`include "debug.sv"
//`include "timescale.sv"

module I2C_MyNano(
	input							CLOCK_50,		//This is the system clock that comes in at 50mhz

	output 		[7:0]		LED,				//This is a register that is used to show the data that was read from the EEPROM in binary.

	inout			wire 		IMU_SCL,		//IMU I2C Clock line
	inout			wire		IMU_SDA,		//IMU I2C Data Line

	output 		wire 		PWMout,
	output 		wire 		waveFormsPin,
	
	input 		[7:0]		heartRate,
	input			wire		blips,
	
	output 		wire 		tx,		//Cell phone transmiting 
	input 		wire	 	rx,			//Cell phone receiving 
	
	input			wire		leftBlinker,		//buttons in
	input			wire		rightBlinker,		//buttons in
	input			wire		headLight,			//buttons in
	input			wire		horn,						//buttons in
	
	input			wire		brakes,					
	
	output		wire		leftBlinkerOut,	
	output		wire		rightBlinkerOut,
	output		wire		headLightOut,
	output		wire		brakeLightOut,
	
	input			wire		cadence,
	
	output		[7:0]		DACout
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

	//| Filtered Accelerometer
	wire 		[9:0]		FAccelX;
	wire 		[9:0]		FAccelY;
	wire 		[9:0]		FAccelZ;

	//| Filtered Gyroscope
	wire 		[9:0]		FGyroX;
	wire 		[9:0]		FGyroY;
	wire 		[9:0]		FGyroZ;

	//| IMU data trigger
	wire						IMUDataReady;

	//| Motor output
	wire 		[9:0]		PWMinput;

	wire						LowPassDataReady;
	wire						HighPassDataReady;

	//| Cell phone communication
	wire 						transmit;
	wire 						received; 
	wire 						is_receiving;
	wire 						is_transmitting;
	wire 		[7:0] 	tx_byte;
	wire 		[7:0] 	rx_byte;
	
	wire 		[7:0]		RPMnumber;
	wire 		[7:0] 	speed;
	wire 		[7:0] 	PWMOutput;
	
	wire		[7:0]		heartRateCap;
	reg 		[7:0]		initialHeartCap =200;
	
	//| Debounced button inputs
	wire						DBleftBlinker;
	wire						DBrightBlinker;
	wire						DBheadLight;
	wire						DBhorn;
	
	
	assign waveFormsPin = PWMout;
	assign headLightOut = DBheadLight;
	
	
	always@(heartRateCap)
	initialHeartCap = heartRateCap;
	
	//|
	//| IMU-I2C controller module
	//|--------------------------------------------
	IMUInterface IMU(
		.CLOCK_50(CLOCK_50),
		.I2C_SCL(IMU_SCL),
		.I2C_SDA(IMU_SDA),
		.AccelX(AccelX),
		.AccelY(AccelY),
		.AccelZ(AccelZ),
		.GyroX(GyroX),
		.GyroY(GyroY),
		.GyroZ(GyroZ),
		.DataValid(IMUDataReady)
	);
	
	//|
	//| IMU Filtering modules
	//|--------------------------------------------
	LowPassFilter AccelerometerFilter(
		.ReadDone(IMUDataReady),		
		.AccelX(AccelX),
		.AccelY(AccelY),
		.AccelZ(AccelZ),	
		.AccelXOut(FAccelX),
		.AccelYOut(FAccelY),
		.AccelZOut(FAccelZ),		
		.DataReady(LowPassDataReady)
	);
	

	SensorFusion InclanationCalculator(
		.DataReady(IMUDataReady),
		.Accel1(FAccelX),
		.Accel2(FGyroY),
		.Gyro(GyroY),
		.resolvedAngle(PWMinput)
  );
  
  AssistanceAlgorithm Assist(
		.clk(CLOCK_50),	
		.resolvedAngle(PWMinput),
		.HeartRate(heartRate),			//Commented for testing
		.HeartRateCap(initialHeartCap),   
		.PWMOut(PWMOutput),
		.cadence(cadence),
		.brake(brakes)
  );
  
  motorPWMGenerator motorController(
		.CLOCK_50(CLOCK_50),
		.PWMinput(PWMOutput),
		.PWMout(PWMout)
	
	);
	
	RPM rpmCalc (
		.rpm(),
		.clk50M(CLOCK_50),
		.blips(blips),
		.rpmPhone(RPMnumber)
	);
	
	soundramp	HornOut (
		.c50M(CLOCK_50),
		.Button(horn),
		.OutputToDAC(DACout)
	);
	
	//|
	//| Debounce all of the incoming Buttons
	//|-------------------------------------------
	debounced_button RightBlinker(
		.c50M(CLOCK_50),
		.Button(rightBlinker),
		.ButtonOut(DBrightBlinker)		
	);
	
	debounced_button LeftBlinker(
		.c50M(CLOCK_50),
		.Button(leftBlinker),
		.ButtonOut(DBleftBlinker)		
	); 
	
	debounced_button HeadLight(
		.c50M(CLOCK_50),
		.Button(headLight),
		.ButtonOut(DBheadLight)		
	); 
	
	debounced_button Horn(
		.c50M(CLOCK_50),
		.Button(horn),
		.ButtonOut(DBhorn)		
	); 
	
	//| 
	//| Light controls
	//|--------------------------------------------
	
	blinker blinkerControls(
		.c50M(CLOCK_50),
		.leftBlink(DBleftBlinker),
		.rightBlink(DBrightBlinker),
		.rightBlinkerOut(rightBlinkerOut),
		.leftBlinkerOut(leftBlinkerOut)
	);
	
	
	BrakeLightController(
		.c50M(CLOCK_50),
		.brakeActive(brakes),
		.headLightActive(headLightOut),
		.brakePWM(brakeLightOut)
	);
	
	
	//|
	//| IMU LED visualization
	//|--------------------------------------------
	PWMGenerator #(
		.Offset(0),
		.pNegEnable(1)
	)AccelAngleLED(
		.CLOCK_50(CLOCK_50),
		.PWMinput(PWMinput),
		.PWMout(LED[7])
	);
		
	PWMGenerator #(
		.Offset(0),
		.pNegEnable(1)
	)AccelXLED(
		.CLOCK_50(CLOCK_50),
		.PWMinput(AccelX),
		.PWMout(LED[0])
	);

	PWMGenerator #(
		.Offset(0),
		.pNegEnable(1)
	)AccelYLED(
		.CLOCK_50(CLOCK_50),
		.PWMinput(AccelY),
		.PWMout(LED[1])
	);

	PWMGenerator #(
		.Offset(0),
		.pNegEnable(1)
	)AccelZLED(
		.CLOCK_50(CLOCK_50),
		.PWMinput(AccelZ),
		.PWMout(LED[2])
	);

	PWMGenerator #(
		.Offset(0),
		.pNegEnable(1)
	)GyroXLED(
		.CLOCK_50(CLOCK_50),
		.PWMinput(GyroX),
		.PWMout(LED[3])
	);

	PWMGenerator #(
		.Offset(0),
		.pNegEnable(1)
	)GyroYLED(
		.CLOCK_50(CLOCK_50),
		.PWMinput(GyroY),
		.PWMout(LED[4])
	);

	PWMGenerator #(
		.Offset(0),
		.pNegEnable(1)
	)GyroZLED(
		.CLOCK_50(CLOCK_50),
		.PWMinput(GyroZ),
		.PWMout(LED[5])
	);
		
	//|
	//| Cell phone communication 
	//|---------------------------------------------
	wireless CellPhoneProtocol(
		.clk(CLOCK_50),   
		.transmit(transmit), // Signal to transmit
		.tx_byte(tx_byte), // Byte to transmit
		.received(received), // Indicated that a byte has been received.
		.rx_byte(rx_byte), // Byte received
		.is_receiving(is_receiving), // Low when receive line is idle.
		.is_transmitting(is_transmitting), // Low when transmit line is idle.
		.heartRate(heartRate),
		.heartCap(heartRateCap),
		.resolvedAngle(PWMinput),
		.speed(RPMnumber)
	);

	uart	Bluetooth(
		.clk(CLOCK_50),
		.rx(rx),
		.tx(tx),
		.transmit(transmit), // Signal to transmit
		.tx_byte(tx_byte), // Byte to transmit
		.received(received), // Indicated that a byte has been received.
		.rx_byte(rx_byte), // Byte received
		.is_receiving(is_receiving), // Low when receive line is idle.
		.is_transmitting(is_transmitting) // Low when transmit line is idle.
	);
endmodule



