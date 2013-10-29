//|     Bluetooth Interface module for CSUS Senior Design
//|
//|     Authors: Devin Moore and Ben Smith
//|
//|     This module communicates through our UART module, to the RN41 bluetooth module
//|     to our Android cell phone to be able to display data and recive parameters for
//|     the rest of the verilog assistance algorithm.
//|

module wireless(
	 input clk, // The master clock for this module    
    output reg transmit, // Signal to transmit
    output reg [7:0] tx_byte, // Byte to transmit
    input received, // Indicated that a byte has been received.
    input wire [7:0] rx_byte, // Byte received
    input is_receiving, // Low when receive line is idle.
    input is_transmitting, // Low when transmit line is idle.
    input recv_error, // Indicates error in receiving packet.
	 input [7:0] xAxis,
	 input wire [1:0] key
);

reg 	[7:0] 	fakeAccelX;		//These two fake variables will be speed, inclination,
reg 	[7:0]		fakeAccelY;		//and another will ba added for heartrate
reg	[1:0]		KEY;				//I dont think this is used any more. Just for testing
reg				firstPass =0;	//Used to make sure the transmit line is only high for one clk cycle
reg 	[7:0]		byteIn;			//Byte to receive from cellphone
reg 	[7:0]		byteOut;			//Byte to transmit to cellphone


//Sources and probes for testing
/*  AccelSettingtReadback  keycheck (
    .probe (byteIn),
    .source ()
    );
	
	 AccelSettingtReadback  rxcheck (
    .probe (rx_byte),
    .source ()
    );
	 	 AccelSettingtReadback  txcheck (
    .probe (tx_byte),
    .source ()
    );
*/	

 //Used for testing
always@(posedge clk) KEY[0]=!key[0];
/*
always@(posedge received)
	begin
		byteIn = rx_byte;

	end
	
	*/

//|
//| Main block that waits for input from the cellphone to send the relevent
//| data back to it through the UART module.	
always@(posedge clk)
	begin	
		if(received)		
			begin
				firstPass=0;				
				byteIn = rx_byte;	
				
			//| This case statment begins once a byte has been recieved from the cellphone,
			//| and depending on the data received, will send a specific set of data back to 
			//| the cellphone to be displayed.
			//|----------------------------------------------------------------------------
			case(rx_byte)
					
					8'd1:
						begin
							tx_byte = fakeAccelX;
							if (fakeAccelX <200)
								fakeAccelX = fakeAccelX +1;
							else fakeAccelX =0;
						end
					8'd2:
						begin
							tx_byte = fakeAccelY;
							if (fakeAccelY <200)
								fakeAccelY = fakeAccelY +3;
							else fakeAccelY =0;
						end
					
				endcase
					
				//|Once the correct data has been loaded into the outgoing register, the transmit
				//| line will be held high for one clock cycle so the bluetooth module will begin transmitting
				begin					
					if (firstPass == 0)
						begin
							transmit = 1;
							firstPass = 1;
						end								
				end
		   end else transmit = 0;
	
	end
	
endmodule






