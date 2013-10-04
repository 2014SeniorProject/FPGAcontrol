`timescale 10 ns / 1 ns

/********************************************************************
As of now this program can either read or write to a specified address
in the onboard EEPROM(24LC02B) using the I2C protocol. The number that SD_COUNTER
goes up to needs to be changed, and the assignments at the bottom of the file
need to switched when switching from reading and writing.
********************************************************************/


module I2C_MyNano(

	//This is the system clock that comes in at 50mhz
	CLOCK_50,


	//This is a register that is used to show the data that was read from the EEPROM in binary.
	LED,


	//This is an input from both of the buttons on board the De0-Nano
	KEY,


	//I2C Clock line, goes to the EEPROM right now
	I2C_SCL,


	//I2C Data Line, goes to the EEPROM rigth now
	I2C_SDA,


	//9 bit register that increments every time the 50mhz clock rises. This is used to step
	//down the speed for the I2C. Really rough right now, we can make it more efficient im sure.
	COUNT,

	G_Sensor_CS_N,

	AccelX,
	AccelY,
	AccelZ
);

AccelerometerDataRegisters	AccelXProbe (
	.probe (AccelX),
	.source ()
	);

AccelerometerDataRegisters	AccelYProbe (
	.probe ( AccelY ),
	.source ()
	);

AccelerometerDataRegisters	AccelZProbe (
	.probe ( AccelZ ),
	.source ()
	);

	//State Conditions for setting up the ADXL345
localparam ACCEL_ADDR = 7'h1D;					//This is the I2C address of the slave

localparam INTITIALIZE_A1 = 8'd0;
localparam INTITIALIZE_A2 = 8'd1;
localparam INTITIALIZE_A3 = 8'd2;
localparam INTITIALIZE_A4 = 8'd3;
localparam INTITIALIZE_A5 = 8'd4;
localparam ReadAcceletometerYaxisHB = 8'd5;
localparam ReadAcceletometerYaxisLB = 8'd6;
localparam ReadAcceletometerXaxisHB = 8'd7;
localparam ReadAcceletometerXaxisLB = 8'd8;
localparam ReadAcceletometerZaxisHB = 8'd9;
localparam ReadAcceletometerZaxisLB = 8'd10;

//Just outputs for testing
output 	[7:0]  	LED;
output 				G_Sensor_CS_N = 1;		//This is used to set the ADXL345 into I2C mode(PIN_G5)
//Normal 50mhz clock
input 				CLOCK_50;

//These two keys are used for starting and reseting the opperations
input 	[1:0] 	KEY;

//This is for the I2C connections
output   			I2C_SCL;
inout   			I2C_SDA;

//Keep track of clocks
//output	[5:0] 	SD_COUNTER;
output  	[9:0]		COUNT;

//Reg/Wire Declarations
wire		reset_n;									//This is assigned to key[0] and used to reset the SD counter for testing

reg		[1:0]		SW = 1;						//read or write flag, 1 for write, 0 for read...
reg 					SCL_CTRL = 0;				//This is used for the clock. ----TEST!!!!!!
reg		[7:0]		DATAIN = 0;					//This is where the data is stored when reading a byte
reg					GO = 0;						//This signals the operation to start
reg		[6:0]		SD_COUNTER = 0;			//This is used for the casses in the bitwise read and write states
reg					SDI = 0;						//place holder for I2C_SDA
reg					SCL = 0;						//Place holder for I2C_SCL during start/stop
reg		[9:0]		COUNT = 0;					//Used to slow down clock for I2C
reg 		[7:0] 		LEDOUT = 0;					//I think I stopped using this? again too lazy right now to check.
reg		[7:0]    		REGADDRESS = 0;			//Address of the register
reg		[6:0]		I2CADDRESS = 0;			//7 bit address of slave
reg					RW_DIR = 0;					//Read write direction. 0 - Write, 1- Read.
reg		[7:0]		DATAOUT = 0;				//Data to be sent to slave
reg		[7:0]		StateControl = 0;					//Flag register. Starts at 0, then thing happen...
reg					FIRSTPASS =0;
reg		[7:0]   		RWDELAY = 0;

reg 					ReadDone = 0;
reg 					WriteDone = 0;

output reg 	[15:0]		AccelY = 0 /* synthesis preserve */;
output reg 	[15:0]		AccelX = 0 /* synthesis preserve */;
output reg 	[15:0]		AccelZ = 0 /* synthesis preserve */;

//Structural Coding

assign 	reset_n = KEY[0];

assign I2C_SCL = (SCL_CTRL)? ~COUNT[9] : SCL;	//Assign the SCL normal 100khz clk, besides the start/stop conditions

assign I2C_SDA = (SCL_CTRL)?((SDI)? 1'bz : 0):SDI; 			//Yeah, just assign the placeholder SDI to the SDA line

//The Clock values will need to be changed as previously mentioned
always @ (posedge CLOCK_50) COUNT = COUNT +1;

//This just takes care of our "start operation" button
always @ (posedge COUNT[9] or negedge reset_n)
	begin
		if (!reset_n)
			GO = 0;
		else
			GO = 1;
	end


//The Clock values will need to be changed as previously mentioned
always @ (posedge AccelY)  LEDOUT = AccelY[15:8];

//This Allows for one opperation. We will probably need to change this to do continuously,
//or maybe just reset it everytime we need to read again?? something to think about.
always @ (posedge COUNT[9] or negedge reset_n)
	begin
		if(!reset_n)
			SD_COUNTER = 6'b0;
		else
			begin
				if(!GO)
					SD_COUNTER = 0;
				else
					if(SD_COUNTER < 50)
						SD_COUNTER = SD_COUNTER+1;
				else			//The rest of this stuff is here to bypass the go and reset buttons.
					begin
						if(RWDELAY <250)
							RWDELAY = RWDELAY +1;
						else
						begin
							RWDELAY =0;
							SD_COUNTER =0;
						end
					end
			end
	end




	//I2C Operation, Write
	always @ (posedge COUNT[9]/* or negedge reset_n*/)
	begin
		if(!reset_n)
		begin
			SCL = 1;
			SDI = 1;
		end
		else


		//Case statements for initializing the ADXL.
		begin
			case (StateControl)

			INTITIALIZE_A1:	//First state should write 8'h00 to register 8'h2D (DATA RATE/POWER)
								begin
								if(FIRSTPASS == 0)
									begin
									I2CADDRESS = ACCEL_ADDR;
									RW_DIR = 0;
									REGADDRESS = 8'h2D; //2d
									DATAOUT = 8'h08;
									FIRSTPASS = 1;
									end

								if(WriteDone)
									begin
									WriteDone = 0;
									StateControl = INTITIALIZE_A2;
									end
								end

			INTITIALIZE_A2:	//Second state should write 8'h16 to register 8'h2D (DATA RATE/POWER)
								begin
								if(FIRSTPASS == 0)
									begin
									I2CADDRESS = ACCEL_ADDR;
									RW_DIR = 0;
									REGADDRESS = 8'h2D; //2d
									DATAOUT = 8'h16;	//16
									FIRSTPASS = 1;
									end

								if(WriteDone)
									begin
									WriteDone = 0;
									StateControl = INTITIALIZE_A3;
									end
								end

			INTITIALIZE_A3:	//Third state should write 8'h08 to register 8'h2D	(DATA RATE/POWER)
								begin
								if(FIRSTPASS == 0)
									begin
									I2CADDRESS = ACCEL_ADDR;
									RW_DIR = 0;
									REGADDRESS = 8'h2D; //2d
									DATAOUT = 8'h08;
									FIRSTPASS = 1;
									end

								if(WriteDone)
									begin
									WriteDone = 0;
									StateControl = INTITIALIZE_A4;
									end
								end

			INTITIALIZE_A4:	//Fouth state should write 8'h04 to register 8'h31 (FORMAT)
								begin
								if(FIRSTPASS == 0)
								begin
									I2CADDRESS = ACCEL_ADDR;
									RW_DIR = 0;
									REGADDRESS = 8'h31; //31
									DATAOUT = 8'h04;
									FIRSTPASS = 1;
								end

								if(WriteDone)
									begin
									AccelY[7:0] = DATAIN;
									WriteDone = 0;
									StateControl = INTITIALIZE_A5;
									end
								end

			INTITIALIZE_A5:	//Fifth state should write 8'h0F to register 8'h2C
								begin
								if(FIRSTPASS == 0)
									begin
									I2CADDRESS = ACCEL_ADDR;
									RW_DIR = 0;
									REGADDRESS = 8'h2C;	//2c
									DATAOUT = 8'h0F;
									FIRSTPASS = 1;
									end

								if(WriteDone)
									begin
									WriteDone = 0;
									StateControl = ReadAcceletometerYaxisHB;
									end
								end

			ReadAcceletometerYaxisHB:	//Sixth state should read from the speficified register at REGADDRESS
								begin
								if(FIRSTPASS == 0)
									begin
									SW[0] = 0;
									I2CADDRESS = ACCEL_ADDR;
									RW_DIR = 0;
									REGADDRESS = 8'd52;
									FIRSTPASS = 1;
									end

								if(ReadDone)
									begin
									StateControl = ReadAcceletometerYaxisLB;
									AccelY[15:8] = DATAIN;
									ReadDone = 0;
									end
								end

			ReadAcceletometerYaxisLB:	//Sixth state should read from the speficified register at REGADDRESS
								begin
								if(FIRSTPASS == 0)
									begin
									SW[0] = 0;
									I2CADDRESS = ACCEL_ADDR;
									RW_DIR = 0;
									REGADDRESS = 8'd53;
									FIRSTPASS = 1;
									end
								if(ReadDone)
									begin
									StateControl = ReadAcceletometerXaxisHB;
									AccelY[7:0] = DATAIN;
									ReadDone = 0;
									LEDOUT = DATAIN;
									end
								end

			ReadAcceletometerXaxisHB:	//Sixth state should read from the speficified register at REGADDRESS
								begin
								if(FIRSTPASS == 0)
									begin
									SW[0] = 0;
									I2CADDRESS = ACCEL_ADDR;
									RW_DIR = 0;
									REGADDRESS = 8'd50;
									FIRSTPASS = 1;
									end

								if(ReadDone)
									begin
									StateControl = ReadAcceletometerXaxisLB;
									AccelX[15:8] = DATAIN;
									ReadDone = 0;
									end
								end

			ReadAcceletometerXaxisLB:	//Sixth state should read from the speficified register at REGADDRESS
								begin
								if(FIRSTPASS == 0)
									begin
									SW[0] = 0;
									I2CADDRESS = ACCEL_ADDR;
									RW_DIR = 0;
									REGADDRESS = 8'd51;
									FIRSTPASS = 1;
									end
								if(ReadDone)
									begin
									StateControl = ReadAcceletometerZaxisHB;
									AccelX[7:0] = DATAIN;
									ReadDone = 0;
									LEDOUT = DATAIN;
									end
								end

			ReadAcceletometerZaxisHB:	//Sixth state should read from the speficified register at REGADDRESS
								begin
								if(FIRSTPASS == 0)
									begin
									SW[0] = 0;
									I2CADDRESS = ACCEL_ADDR;
									RW_DIR = 0;
									REGADDRESS = 8'd54;
									FIRSTPASS = 1;
									end

								if(ReadDone)
									begin
									StateControl = ReadAcceletometerZaxisLB;
									AccelZ[15:8] = DATAIN;
									ReadDone = 0;
									end
								end

			ReadAcceletometerZaxisLB:	//Sixth state should read from the speficified register at REGADDRESS
								begin
								if(FIRSTPASS == 0)
									begin
									SW[0] = 0;
									I2CADDRESS = ACCEL_ADDR;
									RW_DIR = 0;
									REGADDRESS = 8'd55;
									FIRSTPASS = 1;
									end
								if(ReadDone)
									begin
									StateControl = ReadAcceletometerYaxisHB;
									AccelZ[7:0] = DATAIN;
									ReadDone = 0;
									end
								end
			endcase
		///------------------------------------------


			//This Section is for writing, If switch one is to the left
			//*********************************************************
			if (SW[0])		//This acts as a flag to determine if it needs to read or write
			begin

				case (SD_COUNTER)
					6'd0		: begin SDI =1; SCL = 1; SCL_CTRL =0; end

					////////START///////////
					6'd1		:	SDI = 0;
					6'd2		:	SCL = 0;

					////////I2C Adress. 8th bit is 0 for write, then 9th is tristate for ACK///////
					6'd3		:	begin SDI = I2CADDRESS[6]; I2CADDRESS = I2CADDRESS <<1; SCL_CTRL=1;  end
					6'd4		:	begin SDI = I2CADDRESS[6]; I2CADDRESS = I2CADDRESS <<1; end
					6'd5		:	begin SDI = I2CADDRESS[6]; I2CADDRESS = I2CADDRESS <<1; end
					6'd6		:	begin SDI = I2CADDRESS[6]; I2CADDRESS = I2CADDRESS <<1; end
					6'd7		:	begin SDI = I2CADDRESS[6]; I2CADDRESS = I2CADDRESS <<1; end
					6'd8		:	begin SDI = I2CADDRESS[6]; I2CADDRESS = I2CADDRESS <<1; end
					6'd9		:	begin SDI = I2CADDRESS[6]; I2CADDRESS = I2CADDRESS <<1; end
					6'd10		:	SDI = RW_DIR;
					6'd11		:	SDI = 1;

					/////////Memory Adress. Or reg adress for accel.///////////
					6'd12		:	begin SDI = REGADDRESS[7]; REGADDRESS = REGADDRESS << 1; end
					6'd13		:	begin SDI = REGADDRESS[7]; REGADDRESS = REGADDRESS << 1; end
					6'd14		:	begin SDI = REGADDRESS[7]; REGADDRESS = REGADDRESS << 1; end
					6'd15		:	begin SDI = REGADDRESS[7]; REGADDRESS = REGADDRESS << 1; end
					6'd16		:	begin SDI = REGADDRESS[7]; REGADDRESS = REGADDRESS << 1; end
					6'd17		:	begin SDI = REGADDRESS[7]; REGADDRESS = REGADDRESS << 1; end
					6'd18		:	begin SDI = REGADDRESS[7]; REGADDRESS = REGADDRESS << 1; end
					6'd19		:	begin SDI = REGADDRESS[7]; REGADDRESS = REGADDRESS << 1; end
					6'd20		:	SDI = 1;

					//////////Data to be writen to the adress////////////////
					6'd21		:	begin SDI = DATAOUT[7]; DATAOUT = DATAOUT << 1; end
					6'd22		:	begin SDI = DATAOUT[7]; DATAOUT = DATAOUT << 1; end
					6'd23		:	begin SDI = DATAOUT[7]; DATAOUT = DATAOUT << 1; end
					6'd24		:	begin SDI = DATAOUT[7]; DATAOUT = DATAOUT << 1; end
					6'd25		:	begin SDI = DATAOUT[7]; DATAOUT = DATAOUT << 1; end
					6'd26		:	begin SDI = DATAOUT[7]; DATAOUT = DATAOUT << 1; end
					6'd27		:	begin SDI = DATAOUT[7]; DATAOUT = DATAOUT << 1; end
					6'd28		:	begin SDI = DATAOUT[7]; DATAOUT = DATAOUT << 1; end
					6'd29		:	begin SDI = 1'bz;SCL_CTRL =0;end			//Switch to next state: SDI = 1'bz

					////////////Stop////////////////
					6'd30		:	begin SDI = 0; SCL = 1;	 end
					6'd31		:	SDI = 1; //bz
					6'd42		:	begin FIRSTPASS =0; WriteDone = 1; end
				endcase
			end
			///*********************************************************************
			//////This Section is supposed to Read... Hopefully. Edit: yup it now works  :) /////////////////////
			///**********************************************************************
			else
			begin
				case (SD_COUNTER)
						6'd0		: begin SDI =1; SCL = 1; SCL_CTRL =0;end

						////////START///////////
						6'd1		:	SDI = 0;
						6'd2		:	SCL = 0;

						////////I2C Adress. Still need to write first///////
						6'd3		:	begin SDI = I2CADDRESS[6]; I2CADDRESS = I2CADDRESS <<1; SCL_CTRL=1;  end
						6'd4		:	begin SDI = I2CADDRESS[6]; I2CADDRESS = I2CADDRESS <<1; end
						6'd5		:	begin SDI = I2CADDRESS[6]; I2CADDRESS = I2CADDRESS <<1; end
						6'd6		:	begin SDI = I2CADDRESS[6]; I2CADDRESS = I2CADDRESS <<1; end
						6'd7		:	begin SDI = I2CADDRESS[6]; I2CADDRESS = I2CADDRESS <<1; end
						6'd8		:	begin SDI = I2CADDRESS[6]; I2CADDRESS = I2CADDRESS <<1; end
						6'd9		:	begin SDI = I2CADDRESS[6]; I2CADDRESS = I2CADDRESS <<1; end
						6'd10		:	SDI = RW_DIR;
						6'd11		:	SDI = 1;

						/////////Memory Adress///////////
						6'd12		:	begin SDI = REGADDRESS[7]; REGADDRESS = REGADDRESS << 1; end
						6'd13		:	begin SDI = REGADDRESS[7]; REGADDRESS = REGADDRESS << 1; end
						6'd14		:	begin SDI = REGADDRESS[7]; REGADDRESS = REGADDRESS << 1; end
						6'd15		:	begin SDI = REGADDRESS[7]; REGADDRESS = REGADDRESS << 1; end
						6'd16		:	begin SDI = REGADDRESS[7]; REGADDRESS = REGADDRESS << 1; end
						6'd17		:	begin SDI = REGADDRESS[7]; REGADDRESS = REGADDRESS << 1; end
						6'd18		:	begin SDI = REGADDRESS[7]; REGADDRESS = REGADDRESS << 1; end
						6'd19		:	begin SDI = REGADDRESS[7]; REGADDRESS = REGADDRESS << 1; end
						6'd20		:	begin SDI = 1; SCL =1'bz;I2CADDRESS = ACCEL_ADDR; RW_DIR = 1;end

						//////////Data////////////////
						6'd21		:	begin SDI =1; SCL = 1; end
						6'd22		:	begin SDI = 0; SCL_CTRL=0; end
						6'd23		:	SCL = 0;

						//////I2C Adress with read bit/////////
						6'd24		:	begin SDI = I2CADDRESS[6]; I2CADDRESS = I2CADDRESS <<1; SCL_CTRL=1;  end
						6'd25		:	begin SDI = I2CADDRESS[6]; I2CADDRESS = I2CADDRESS <<1; end
						6'd26		:	begin SDI = I2CADDRESS[6]; I2CADDRESS = I2CADDRESS <<1; end
						6'd27		:	begin SDI = I2CADDRESS[6]; I2CADDRESS = I2CADDRESS <<1; end
						6'd28		:	begin SDI = I2CADDRESS[6]; I2CADDRESS = I2CADDRESS <<1; end
						6'd29		:	begin SDI = I2CADDRESS[6]; I2CADDRESS = I2CADDRESS <<1; end
						6'd30		:	begin SDI = I2CADDRESS[6]; I2CADDRESS = I2CADDRESS <<1; end
						6'd31		:	SDI = RW_DIR;
						6'd32		:	SDI = 1;
						6'd33		:		;

						/////First byte of data transfer from the slave.//////////
						6'd34		:	DATAIN[7] = I2C_SDA ;
						6'd35		:	DATAIN[6] = I2C_SDA ;
						6'd36		:	DATAIN[5] = I2C_SDA ;
						6'd37		:	DATAIN[4] = I2C_SDA ;
						6'd38		:	DATAIN[3] = I2C_SDA ;
						6'd39		:	DATAIN[2] = I2C_SDA ;
						6'd40		:	DATAIN[1] = I2C_SDA ;
						6'd41		:	begin DATAIN[0] = I2C_SDA ;SCL_CTRL =0;FIRSTPASS=0; end


						////////////Stop////////////////
						6'd42		:	begin SDI = 0; SCL = 1; end
						6'd43		:	begin SDI = 1; ReadDone = 1; end
					endcase
			end
		end
	end

endmodule






