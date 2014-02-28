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
//|     Top Level module for CSUS Senior Design
//|
//|     Author: Ben Smith and Devin Moore
//|
//|     This is the top level module for Project Forward. It instantiates modules to
//|			control the motor, communicate with the cellphone application, and the various
//|			sensors required to perform it's tasks.
//|
//| =========================================================================================
//| Revision History
//| 1/2/14  BS  added MIT License.
//|
//| =========================================================================================

//| Uncomment the `include "debug.sv" to enter debug mode on this module.
//| Uncomment the `include "timescale.sv" to run a simulation.
//`include "debug.sv"
//`include "timescale.sv"

module SmartBike_TOP(
	input						CLOCK_50,

	output 			[7:0]		LED,

	//IMU I2C
	inout	wire 				IMU_SCL,		//IMU I2C Clock line
	inout	wire				IMU_SDA,		//IMU I2C Data Line

	//Motor controller outputs
	output 	wire 				PWMout,
	output 	wire 				waveFormsPin,

	//RPM Calculation
	input 	wire				blips,

	//Cellphone Communication
	output 	wire 				tx,		//Cell phone transmiting
	input 	wire		 		rx,		//Cell phone receiving

	//Safety Systems
	input	wire				leftBlinker,		//buttons in
	input	wire				rightBlinker,		//buttons in
	input	wire				headLight,			//buttons in
	input	wire				horn,						//buttons in

	input	wire				brakes,

	output	wire				leftBlinkerOut,
	output	wire				rightBlinkerOut,
	output	wire				headLightOut,
	output	wire				brakeLightOut,

	//User's pedal cadence input
	input	wire				cadence,

	//DAC output
	output			[7:0]		DACout,

	//SDRAM
	output		    [12:0]		DRAM_ADDR,
	output		     [1:0]		DRAM_BA,
	output		          		DRAM_CAS_N,
	output		          		DRAM_CKE,
	output		          		DRAM_CLK,
	output		          		DRAM_CS_N,
	inout 		    [15:0]		DRAM_DQ,
	output		     [1:0]		DRAM_DQM,
	output		          		DRAM_RAS_N,
	output		          		DRAM_WE_N,

	//ANT UART
	output 	wire 				ANT_tx,		//Cell phone transmiting
	input 	wire		 		ANT_rx,		//Cell phone receiving

	//ANT Configuration
	output	wire	[2:0]		ANT_BaudRate,
	output	wire				ANT_nTest,
	output	wire				ANT_nReset,
	output	wire				ANT_nSuspend,
	output	wire				ANT_Sleep,
	output	wire				ANT_PortSelect,
	output	wire				ANT_RequestToSend,
	output	wire				ANT_Reserved1,
	output	wire				ANT_Reserved2,

	//| ADC I/O
	output	wire				ADC_CS_N,
	output  wire				ADC_SADDR,
	output  wire				ADC_SCLK,
	input   wire				ADC_SDAT,
	
	input 	wire				epcs_dclk,
	input 	wire				epcs_sce, 
	input 	wire				epcs_sdo, 
    output 	wire				epcs_data0
);

	//|
	//| Local reg/wire declarations
	//|--------------------------------------------

	//| Accelerometer
	wire 		[9:0]			AccelX;
	wire 		[9:0]			AccelY;
	wire 		[9:0]			AccelZ;

	//| Gyroscope
	wire 		[9:0]			GyroX;
	wire 		[9:0]			GyroY;
	wire 		[9:0]			GyroZ;

	//| Filtered Accelerometer
	wire 		[9:0]			FAccelX;
	wire 		[9:0]			FAccelY;
	wire 		[9:0]			FAccelZ;

	//| Filtered Gyroscope
	wire 		[9:0]			FGyroX;
	wire 		[9:0]			FGyroY;
	wire 		[9:0]			FGyroZ;

	//| IMU data trigger
	wire						IMUDataReady;

	//| Motor output
	wire 		[9:0]			PWMinput;

	//| Dataready signals from filters
	wire						LowPassDataReady;
	wire						HighPassDataReady;

	//| Cell phone communication
	wire 						transmit;
	wire 						received;
	wire 						is_receiving;
	wire 						is_transmitting;
	wire 		[7:0] 			tx_byte;
	wire 		[7:0] 			rx_byte;

	wire 		[7:0]			RPMnumber;
	wire 		[7:0] 			speed;
	wire 		[7:0] 			PWMOutput;

	wire		[7:0]			HeartRate;
	wire		[7:0]			heartRateCap;
	reg 		[7:0]			initialHeartCap =200;

	//| Debounced button inputs
	wire						DBleftBlinker;
	wire						DBrightBlinker;
	wire						DBheadLight;
	wire						DBhorn;

	//| ADC data
	logic   	[11:0]    		adc_data[6:0];

	//|
    //| ANT device assignments
	//|--------------------------------------------
    assign ANT_BaudRate 	= 3'b0;
    assign ANT_nTest 		= 1'b0;
    assign ANT_nReset 		= 1'b1;
    assign ANT_nSuspend 	= 1'b1;
    assign ANT_Sleep 	  	= 1'b0;
    assign ANT_PortSelect 	= 1'b0;
    assign ANT_Reserved1	= 1'b0;
    assign ANT_Reserved2 	= 1'b0;

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
	//| IMU processing modules
	//|--------------------------------------------
	LowPassFilterAverage #(
		.FilterLength(50)
	)AccelerometerFilter(
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

	//|
	//| Assistance calculation
	//|--------------------------------------------
	MotorControl MCA(
			.c50m(CLOCK_50),
			.c20k(c20k),

			.Roll(),
			.Pitch(),
			.HeartRate(HeartRate),
			.HeartRateSetPoint(heartRateCap),

			.ThrottleTest(adc_data[1]),
			.PWMClock(PWMClock),
			.PhaseWireVoltage(adc_data[0]),

			.MotorControlPWM(PWMout)
		);

	//|
	//| Motor RPM calculation
	//|--------------------------------------------
	RPM rpmCalc (
		.rpm(),
		.clk50M(c1m),
		.blips(blips),
		.rpmPhone(RPMnumber)
	);

	//|
	//| Horn Controller
	//|--------------------------------------------
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


	BrakeLightController BrakeLightController(
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

	ADC_CTRL ADC(
		.c1m(ADC_CLK),

		.SPI_IN(ADC_SDAT),
		.CS_n(ADC_CS_N),
		.SCLK_OUT(ADC_SCLK),
		.Data_OUT(ADC_SADDR),

		.adc_data(adc_data)
	);


	//|
	//| Cell phone communication
	//|---------------------------------------------
	wireless CellPhoneProtocol(
		.clk(c50m),
		.transmit(transmit), // Signal to transmit
		.tx_byte(tx_byte), // Byte to transmit
		.received(received), // Indicated that a byte has been received.
		.rx_byte(rx_byte), // Byte received
		.is_receiving(is_receiving), // Low when receive line is idle.
		.is_transmitting(is_transmitting), // Low when transmit line is idle.
		.heartRate(HeartRate),
		.heartCap(heartRateCap),
		.resolvedAngle(PWMinput),
		.speed(RPMnumber),
		.ADC(adc_data[0])
	);

	uart	Bluetooth(
		.clk(c50m),
		.rx(rx),
		.tx(tx),
		.transmit(transmit), // Signal to transmit
		.tx_byte(tx_byte), // Byte to transmit
		.received(received), // Indicated that a byte has been received.
		.rx_byte(rx_byte), // Byte received
		.is_receiving(is_receiving), // Low when receive line is idle.
		.is_transmitting(is_transmitting) // Low when transmit line is idle.
	);

	//NIOS II CPU
	CPU u0 (
        .clk_clk      (c50m),      	//   clk.clk

		//SDRAM connections
		.sdram_addr   (DRAM_ADDR),   // sdram.addr
        .sdram_ba     (DRAM_BA),     //      .ba
        .sdram_cas_n  (DRAM_CAS_N),  //      .cas_n
        .sdram_cke    (DRAM_CKE),    //      .cke
		.sdram_cs_n   (DRAM_CS_N),   //      .cs_n
        .sdram_dq     (DRAM_DQ),     //      .dq
        .sdram_dqm    (DRAM_DQM),    //      .dqm
        .sdram_ras_n  (DRAM_RAS_N),  //      .ras_n
        .sdram_we_n   (DRAM_WE_N),   //      .we_n

		.antuart_rxd  (ANT_rx),  	 // antuart.rxd
        .antuart_txd  (ANT_tx),   	 //        .txds

		.heartrateoutput_export (HeartRate),
		
		.epcsio_dclk            (epcs_dclk),            //          epcsio.dclk
        .epcsio_sce             (epcs_sce),             //                .sce
        .epcsio_sdo             (epcs_sdo),             //                .sdo
        .epcsio_data0           (epcs_data0) 
    );

	PLL	PLL_inst (
		.areset ( ),
		.inclk0 (CLOCK_50),
		.c0 (c50m),
		.c1 (DRAM_CLK),
		.c2 (ADC_CLK),
		.c3 (c100k),
		.locked ()
	);

	PLL2 PLL_inst2 (
		.areset ( ),
		.inclk0 (CLOCK_50),
		.c0 (PWMClock),
		.c1 (c20k),
		.c2 (),
		.c3 (),
		.locked ()
	);
endmodule



