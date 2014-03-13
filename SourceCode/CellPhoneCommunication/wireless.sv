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
//|
//|     Wireless Communication Module
//|
//|     Authors: Devin Moore
//|
//|     This module is used to communicate with the application on the Android device.
//|     It takes in relevant data to display on the phone, and send out certain user defined
//|     values such as wheel size and max heart rate. It communicates through the UART module
//|	  	to the RN41 Bluetooth transmitter/receiver.
//|
//| =========================================================================================
//| Revision History
//|	1/2/14	BS	Made timescale.v permanent, it is custom for it always be included, the information
//|				does not effect synthesis. Fixed lots of spelling in comments :)
//|
//| =========================================================================================

//| Uncomment the `include "debug.sv" to enter debug mode on this module.
//`include "debug.sv"

//`include "timescale.sv"
module wireless(
  	input 					clk, 	// The master clock for this module
	input					UARTclk,
	input 			 		rx,		//Cell phone receiving
	output 	 				tx,		//Cell phone transmiting

	input 			[7:0]	heartRate,
	input			[9:0]	ResolvedAngle,
	input			[7:0]	speed,
	input			[11:0]	ADC,

	output 	logic	[7:0]	wheelSize,
	output  logic	[7:0]	heartCap = 200
);
	
	//|
	//| Parameters for the case statements.
	//| -----------------------------------------
	localparam SEND_HR = 10'd1;
	localparam SEND_ANGLE_SIGN = 10'd2;
	localparam SEND_ANGLE_VALUE = 10'd3;
	localparam SEND_SPEED = 10'd4;
	localparam SEND_ADCL = 10'd7;
	localparam SEND_ADCH = 10'd8;

	localparam INIT_HEART = 10'd5;
	localparam INIT_WHEEL = 10'd6;

	localparam SET_HEART = 10'b10xxxxxxxx;
	localparam SET_WHEEL = 10'b01xxxxxxxx;

	//|
	//| Local net declarations
	//|--------------------------------------------

	wire			received; 		// Indicated that a byte has been received.
	wire 	[7:0] 	rx_byte; 		// Byte received
	wire			is_receiving;	// Low when receive line is idle.
	wire			is_transmitting;// Low when transmit line is idle.
	wire			recv_error; 	// Indicates error in receiving packet.

	logic			initialize_heart = 1'b0;
	logic			initialize_wheel = 1'b0;

	logic 			transmit; 		// Signal to transmit
	logic 	[7:0] 	tx_byte; 		// Byte to transmit



	//|
	//| Sources and Probes used specifically for debugging the wireless protocol
	//|--------------------------------------------------------------------------
	CellPhoneProbe i0(rx_byte);
	CellPhoneProbe i1(tx_byte);
	CellPhoneProbe i2(wheelSize);
	CellPhoneProbe i3(heartCap);
	CellPhoneProbe i4(speed);
	
	always@(posedge clk)
		begin
			//| Once a byte has been received from the cell phone, the received bit will be high for one
			//| clock cycle. The Android application will be sending requests for specific data by
			//| sending a specific byte of data to the FPGA.
			if(received)
				begin
					//| This case statement controls what data will be sent to the cell phone depending
					//| on the byte most recently received from the cell phone.
					//if(!initialize_heart && !initialize_wheel)
					casex({initialize_heart,initialize_wheel,rx_byte})
						SEND_HR:						//Send heart rate to cell phone.
							begin
								tx_byte = heartRate;
							end
						SEND_ANGLE_SIGN:				//Send just the top two bits of the resolved angle so the cell
							begin						//phone can interpret the sign.
								tx_byte = 8'd0;
								tx_byte[1:0] = ResolvedAngle[9:8];
							end
						SEND_ANGLE_VALUE:				//Send the bottoms 8 bits of the resolved angle. The Android app is in
							begin						//charge of interpreting it correctly with the previous byte.
								tx_byte = ResolvedAngle[7:0];
							end
						SEND_SPEED:						//Send the speed data to the cell phone.
							begin
								tx_byte = speed;
							end
						INIT_HEART:
							begin
								initialize_heart = 1'b1;
								tx_byte = 8'd1;
							end
						INIT_WHEEL:
							begin
								initialize_wheel = 1'b1;
								tx_byte = 8'd1;
							end
						SET_HEART:
							begin
								heartCap = rx_byte;
								initialize_heart = 1'b0;
								tx_byte = 8'd1;
							end
						SET_WHEEL:
							begin
							  	wheelSize = rx_byte;
								initialize_wheel = 1'b0;
								tx_byte = 8'd1;
							end
						SEND_ADCL:
							begin
								tx_byte = ADC[7:0];
							end
						SEND_ADCH:
							begin
							  	tx_byte = {4'd0, ADC[11:8]};
							end
						default: 		//If there is an error in the bluetooth transmission, just send back a 0.
								tx_byte = 8'd0;
					endcase

					transmit = 1;		//This must be high for one clock cycle to send the data in the tx register
										//to the cell phone.
				 end
			else transmit = 0;			//This must remain low until a byte is loaded into tx register and is ready
		end								//to be sent.


	uart Bluetooth(
		//| Inputs
		.clk(clk),
		.rx(rx),
		.transmit(transmit), // Signal to transmit
		.tx_byte(tx_byte), // Byte to transmit
		//| Outputs
		.tx(tx),
		.received(received), // Indicated that a byte has been received.
		.rx_byte(rx_byte), // Byte received
		.is_receiving(is_receiving), // Low when receive line is idle.
		.is_transmitting(is_transmitting) // Low when transmit line is idle.
	);

endmodule






