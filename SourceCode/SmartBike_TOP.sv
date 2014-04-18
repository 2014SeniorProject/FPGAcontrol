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
	inout		 				IMU_SCL,		//IMU I2C Clock line
	inout						IMU_SDA,		//IMU I2C Data Line

	//Motor controller outputs
	output 		 				PWMout,
	output 		 				waveFormsPin,

	//RPM Calculation
	input 						blips,

	//Cellphone Communication
	output 		 				tx,		//Cell phone transmiting
	input 				 		rx,		//Cell phone receiving

	//Safety Systems
	input						leftBlinker,		//buttons in
	input						rightBlinker,		//buttons in
	input						headLight,			//buttons in
	input						horn,				//buttons in

	input						brakes,

	output						leftBlinkerOut,
	output						rightBlinkerOut,
	output						headLightOut,
	output						brakeLightOut,

	//User's pedal cadence input
	input						cadence,

	//DAC output
	output			[0:7]		DACout,
	output						EnableAmplifier,

	//SDRAM
	output		    [12:0]		DRAM_ADDR,
	output		    [1:0]		DRAM_BA,
	output		          		DRAM_CAS_N,
	output		          		DRAM_CKE,
	output		          		DRAM_CLK,
	output		          		DRAM_CS_N,
	inout 		    [15:0]		DRAM_DQ,
	output		    [1:0]		DRAM_DQM,
	output		          		DRAM_RAS_N,
	output		          		DRAM_WE_N,

	//ANT UART
	output 		 				ANT_tx,		//Cell phone transmiting
	input 				 		ANT_rx,		//Cell phone receiving

	//ANT Configuration
	output			[2:0]		ANT_BaudRate,
	output						ANT_nTest,
	output						ANT_nReset,
	output						ANT_nSuspend,
	output						ANT_Sleep,
	output						ANT_PortSelect,
	output						ANT_RequestToSend,
	output						ANT_Reserved1,
	output						ANT_Reserved2,

	//| ADC I/O
	output						ADC_CS_N,
	output  					ADC_SADDR,
	output  					ADC_SCLK,
	input   					ADC_SDAT,

	//| EPCS configuration pins
	output 						epcs_dclk,
	output 						epcs_sce,
	output 						epcs_sdo,
    input 						epcs_data0
);

	//|
	//| Local net declarations
	//|--------------------------------------------

	//| Motor output
	wire 		[9:0]			PWMinput;
	wire		[7:0]			HeartRateTemp; 

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
	logic		[7:0]			heartRateCap = 200;

	//| ADC data
	logic   	[11:0]    		adc_data[6:0];

	//| IMU data
	wire 		[9:0]			ResolvedPitch;
	wire 		[9:0]			ResolvedRoll;
	
	wire						PWMClock;
	wire						ADC_CLK;
	wire						CurrentControlClock;
	wire						PWMLightClock;
	wire						c50m;
	wire						IMUI2CClock;
	wire						UARTclk;
	
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
	
	//|
	//|	Instanciates PLLs and produces system clocks
	//|---------------------------------------------
	ClockManagement PLLs(
		.CLOCK_50(CLOCK_50),
		
		.c50m(c50m),
		.DRAM_CLK(DRAM_CLK),
		.ADC_CLK(ADC_CLK),
		.PWMClock(PWMClock),
		.CurrentControlClock(CurrentControlClock),
		.PWMLightClock(PWMLightClock),
		.IMUI2CClock(IMUI2CClock)
	);
	
	//|
	//|	Obtain accelerometer data and output resolved angles
	//|---------------------------------------------
	IMUCalculations IMUCalc(
		//| Inputs
		.PWMLightClock(PWMLightClock),
		.IMUI2CClock(IMUI2CClock),
		
    	.I2C_SCL(IMU_SCL),            //I2C Clock Signal
    	.I2C_SDA(IMU_SDA),            //I2C Data Signal

    	.ResolvedPitch(ResolvedPitch),      //Inclination data
    	.ResolvedRoll(ResolvedRoll),        //Side to side angle
		.LED(LED)
    );

	//|
	//| Control the lighting systems and sound system for safety
	//|---------------------------------------------
	SafetyControls Safety(
		//| Inputs
		.CLOCK_50(c50m),
		.PWMLightClock(PWMLightClock),
		.leftBlinker(leftBlinker),
		.rightBlinker(rightBlinker),
		.headLight(headLight),
		.horn(horn),
		.brakes(brakes),
		
		//| Outputs
		.leftBlinkerOut(leftBlinkerOut),
		.rightBlinkerOut(rightBlinkerOut),
		.headLightOut(headLightOut),
		.brakeLightOut(brakeLightOut),
		.DACout(DACout)
	);
	
	assign EnableAmplifier = horn;

	//|
	//| Assistance calculation
	//|--------------------------------------------
	MotorControl MCA(
		//| Inputs
		.c50m(c50m),
		.CurrentControlClock(CurrentControlClock),
		.ResolvedRoll(ResolvedRoll),
		.ResolvedPitch(ResolvedPitch),
		.HeartRate(HeartRate),
		.HeartRateSetPoint(heartRateCap),
		.ThrottleTest(adc_data[1]),
		.PWMClock(PWMClock),
		.PhaseWireVoltage(adc_data[0]),
		.MotorModeSelect(MotorModeSelectSwitch),
		.BrakeApplied(!brakes),
		.cadence(cadence),
		//| Outputs
		.MotorControlPWM(PWMout)
		);

	//|
	//| Motor RPM calculation
	//|--------------------------------------------
	RPM rpmCalc (
		.rpm(RPMnumber),
		.clk50M(c50m),
		.blips(blips)
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
		.tx(tx),
		.rx(rx),
		.heartRate(HeartRate),
		.UARTclk(UARTclk),
		.heartCap(heartRateCap),
		.ResolvedAngle(ResolvedPitch),
		.speed(RPMnumber),
		.ADC(adc_data[0])
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

		//| UART communication to ANT module
		.antuart_rxd  (ANT_rx),  	 // antuart.rxd
        .antuart_txd  (ANT_tx),   	 //        .txds
	
		//| Heart rate data from ANT device
		.heartrateoutput_export (HeartRate),
		
		//| Connections to EPCS for nonvolitile storage
		.epcsio_dclk  (epcs_dclk),            //          epcsio.dclk
        .epcsio_sce   (epcs_sce),             //                .sce
        .epcsio_sdo   (epcs_sdo),             //                .sdoB
        .epcsio_data0 (epcs_data0),
		
		//|SD Card for data logging
		//.sdcard_b_SD_cmd        (SD_CMD),        //          sdcard.b_SD_cmd 	GPIO20
        //.sdcard_b_SD_dat        (SD_DAT),        //                .b_SD_dat 	GPOP21
        //.sdcard_b_SD_dat3       (SD_DAT3),       //                .b_SD_dat3	GPIO22
        //.sdcard_o_SD_clock      (SD_clock)       //                .o_SD_clock	GPIO23
    );	
endmodule



