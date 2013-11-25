//|     Wireless Communication Module
//|
//|     Authors: Devin Moore
//|
//|     This module is used to communicate with the application on the Android device.
//|     It takes in relevent data to display on the phone, and send out certain user defined
//|     values such as wheel size and max heart rate. It communicates through the UART module
//|	  to the RN41 Bluetooth trasmiter/receiver.   	
//|

//| Uncomment the `include "debug.sv" to enter debug mode on this module.
//| Uncomment the `include "timescale.sv" to run a simulation.
`include "debug.sv"
//`include "timescale.sv"
	
module wireless(
  input 								clk, // The master clock for this module    
	output 	reg 					transmit, // Signal to transmit
	output 	reg 	[7:0] 	tx_byte, // Byte to transmit
	input 								received, // Indicated that a byte has been received.
	input 	wire 	[7:0] 	rx_byte, // Byte received
	input 								is_receiving, // Low when receive line is idle.
	input 								is_transmitting, // Low when transmit line is idle.
	input 								recv_error, // Indicates error in receiving packet.
	input 				[7:0]		heartRate,
	input					[9:0]		resolvedAngle,
	input					[7:0]		speed,
	output 	reg		[7:0]		wheelSize,
	output  reg		[7:0]		heartCap = 200
);

	//| Parameters for the case statements.
	localparam SEND_HR = 10'd1;
	localparam SEND_ANGLE_SIGN = 10'd2;
	localparam SEND_ANGLE_VALUE = 10'd3;
	localparam SEND_SPEED = 10'd4;
	localparam INIT_HEART = 10'd5;
	localparam INIT_WHEEL = 10'd6;
	localparam SET_HEART = 10'b10xxxxxxxx;
	localparam SET_WHEEL = 10'b01xxxxxxxx;
	
	
	reg				 initialize_heart = 1'b0;
	reg				 initialize_wheel = 1'b0;

	//|
	//| Sources and Probes used specifically for debugging the wireless protol
	//|--------------------------------------------------------------------------
	`ifdef debug
//		AccelSettingtReadback  keycheck (
//		.probe (resolvedAngle),
//		.source ()
//		);
//
//		AccelSettingtReadback  rxcheck (
//		.probe (heartCap),
//		.source ()
//		);
//		AccelSettingtReadback  txcheck (
//		.probe (wheelSize),
//		.source ()
//		);
	`endif

	always@(posedge clk)
		begin	
			//| Once a byte has been recieved from the cell phone, the received bit will be high for one
			//| clock cycle. The Android application will be sending requests for specific data by
			//| sending a specific byte of data to the FPGA.
			if(received)		
				begin									
					//| This case statement controlls what data will be sent to the cell phone depending
					//| on the byte most recently received from the cell phone.
					//if(!initialize_heart && !initialize_wheel)
					casex({initialize_heart,initialize_wheel,rx_byte})						
						SEND_HR:						//Send heart rate to cell phone.
							begin
								tx_byte = heartRate;								
							end
						SEND_ANGLE_SIGN:		//Send just the top two bits of the resolved angle so the cell
							begin							//phone can interperate the sign.
								tx_byte = 8'd0;
								tx_byte[1:0] = resolvedAngle[9:8];
							end
						SEND_ANGLE_VALUE:		//Send the bottoms 8 bits of the resolved angle. The Android app is in
							begin							//charge of interperating it correctly with the previous byte.
								tx_byte = resolvedAngle[7:0];
							end
						SEND_SPEED:					//Send the speed data to the cell phone.
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
						default: 						//If there is an error in the bluetooth transmission, just send back a 0.
								tx_byte = 8'd0;							
					endcase						
								
					transmit = 1;					//This must be high for one clock cycle to send the data in the tx register										
																//to the cell phone.
				 end 
			else transmit = 0;				//This must remain low until a byte is loaded into tx register and is ready
		end													//to be sent.
		
endmodule






