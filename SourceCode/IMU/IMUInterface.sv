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
//|     IMU Interface module for CSUS Senior Design
//|
//|     Authors: Devin Moore and Ben Smith
//|
//|     This module communicates on an I2C bus at 400 khz to an Analog devices ADXL345 accelerometer
//|     and Invensense HTG-3200 gyroscope. Both sensors require initialization that is handled
//|     by this module the XYZ axis are read back for both modules
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

module IMUInterface(
	input                       IMUI2CClock,           //Input clock

	inout                       I2C_SCL,            //
	inout                       I2C_SDA,


	output  	    [17:0]      AccelX,
	output  	    [17:0]      AccelY,
	output  	    [17:0]      AccelZ,

	output  	    [17:0]      GyroX,
	output  	    [17:0]      GyroY,
	output  	    [17:0]      GyroZ,

	output  logic               DataValid
);

	//| Altera in system probes for debugging
	`ifdef debug
		//These are test points for the In-System Sources and Probes Editor in Quartus
//		AccelProbeY  IMUGyroXProbe (GyroX);
//		AccelProbeY  IMUGyroYProbe (GyroY);
//		AccelProbeY  IMUGyroZProbe (GyroZ);
//
//		AccelProbeY  IMUAccelXProbe (AccelX);
//		AccelProbeY  IMUAccelYProbe (AccelY);
//		AccelProbeY  IMUAccelZProbe (AccelZ);
//
//		//| Debug readback data registers
		logic        [7:0]       RW_RATE = 0;
		logic        [7:0]       POWER_CTL = 0;
		logic        [7:0]       DataFormat = 0;
	`endif

	//| Sensor module I2C bus addresses
	//|-------------------------------------------------------------------------------------------------
	localparam ACCEL_ADDR = 7'h53;                  //This is the I2C address of the slave
	localparam Gyro_ADDR = 7'h68;

	//| State machine state names
	//|-------------------------------------------------------------------------------------------------
	localparam Idle = 8'd1;

	//| Accelerometer initialization states
	localparam INTITIALIZE_A1 = 8'd2;
	localparam INTITIALIZE_A2 = 8'd3;
	localparam INTITIALIZE_A3 = 8'd4;
	localparam INTITIALIZE_A4 = 8'd5;
	localparam INTITIALIZE_A5 = 8'd6;
	localparam INTITIALIZE_A6 = 8'd26;

	//| Accelerometer initialization states
	localparam INTITIALIZE_G1 = 8'd22;
	localparam INTITIALIZE_G2 = 8'd23;
	localparam INTITIALIZE_G3 = 8'd24;
	localparam INTITIALIZE_G4 = 8'd25;

	//| Accelerometer setting register debug states
	localparam ReadbackRW_RATE = 8'd7 ;
	localparam ReadbackPOWER_CTL = 8'd8;
	localparam ReadbackDataFormat = 8'd9;

	//| Accelerometer data register read states
	localparam ReadAcceletometerZaxisHB = 8'd10;
	localparam ReadAcceletometerYaxisLB = 8'd11;
	localparam ReadAcceletometerYaxisHB = 8'd12;
	localparam ReadAcceletometerXaxisLB = 8'd13;
	localparam ReadAcceletometerXaxisHB = 8'd14;
	localparam ReadAcceletometerZaxisLB = 8'd15;

	//| Gyroscope data register read states
	localparam ReadGyroscopeZaxisHB = 8'd16;
	localparam ReadGyroscopeYaxisLB = 8'd17;
	localparam ReadGyroscopeYaxisHB = 8'd18;
	localparam ReadGyroscopeXaxisLB = 8'd19;
	localparam ReadGyroscopeXaxisHB = 8'd20;
	localparam ReadGyroscopeZaxisLB = 8'd21;


	//|
	//| Local register declarations
	//|-------------------------------------------------------------------------------------------------
	logic       [7:0]       StateControl = 1;           //Flag register. Starts at 0, then thing happen...

	logic       [1:0]       SW = 1;                     //read or write flag, 1 for write, 0 for read...

	logic       [7:0]       DATAIN = 0;                 //This is where the data is stored when reading a byte
	logic                   GO = 0;                     //This signals the operation to start
	logic       [6:0]       SD_COUNTER = 0;             //This is used for the casses in the bitwise read and write states

	//| Bus control resiters
	logic                   SDI = 0;                    //place holder for I2C_SDA
	logic                   SCL = 0;                    //Place holder for I2C_SCL during start/stop

	//| I2C control registers
	logic       [7:0]       REGADDRESS = 0;             //Address of the register
	logic       [6:0]       I2CADDRESS = 0;             //7 bit address of slave
	logic                   RW_DIR = 0;                 //Read write direction. 0 - Write, 1- Read.
	logic       [7:0]       DATAOUT = 0;                //Data to be sent to slave
	logic                   FIRSTPASS =0;				//This ensures that out states are initialized once each
	logic       [7:0]       IdleCount = 0;				//Keeps track of the time of the Idle state
	logic                   intialWait = 1;
	logic                   ReadDone = 0;				//Flag to tell when a read cycle has finished
	logic                   WriteDone = 0;				//Flag to tell when a write cycle has finished
	logic			        SCL_CTRL = 0;



	//| Sensor data registers
	logic       [7:0]       AccelYHB;
	logic       [7:0]       AccelXHB;
	logic       [7:0]       AccelZHB;

	logic       [7:0]       AccelYLB;
	logic       [7:0]       AccelXLB;
	logic       [7:0]       AccelZLB;

	logic       [7:0]       GyroYHB;
	logic       [7:0]       GyroXHB;
	logic       [7:0]       GyroZHB;

	logic       [7:0]       GyroYLB;
	logic       [7:0]       GyroXLB;
	logic       [7:0]       GyroZLB;


	//|
	//| Assignments
	//|-------------------------------------------------------------------------------------------------
	assign I2C_SCL = (SCL_CTRL)? ~IMUI2CClock : SCL;
	assign I2C_SDA = (SCL_CTRL)?((SDI)? 1'bz : 1'b0):SDI;

	assign AccelX = {AccelXHB, AccelXLB};
	assign AccelY = {AccelYHB, AccelYLB};
	assign AccelZ = {AccelZHB, AccelZLB};

	assign GyroX = {GyroXHB, GyroXLB};
	assign GyroY = {GyroYHB, GyroYLB};
	assign GyroZ = {GyroZHB, GyroZLB};

	//|
	//| Device Read and Write Functions
	//|-------------------------------------------------------------------------------------------------

	//| Function: single byte write will return 1 when completed, otherwise zero. This is meant to allow this
	//| function to be called multiple times while the operation complete
	function bit SingleByteWrite([6:0] BusAddress, [7:0] RegisterAddress, toWrite);
		if(FIRSTPASS == 0)
			begin
				GO = 1;
				SD_COUNTER = 0;
				I2CADDRESS = BusAddress;
				RW_DIR = 0;
				REGADDRESS = RegisterAddress;
				DATAOUT = toWrite;
				FIRSTPASS = 1;
			end

		if(WriteDone)
			begin
				WriteDone = 0;
				FIRSTPASS = 0;
				return 1;
			end
		else
			return 0;
	endfunction

	//|
	//| Structural coding
	//|-------------------------------------------------------------------------------------------------
	//I2C Operation, Write
	always @ (posedge IMUI2CClock)
		begin

			//counter for I2C byte level transmitter
			if(!GO) SD_COUNTER = 0;
			else    SD_COUNTER++;
			begin
				case (StateControl)
					//| Acceleromter initializtion states
					//|-----------------------------------------------------------------------------------------
					INTITIALIZE_A1: if(SingleByteWrite(ACCEL_ADDR, 8'h2D, 8'h00)) StateControl = INTITIALIZE_A2;//First state should write 8'h00 to register 8'h2D (DATA RATE/POWER)
					INTITIALIZE_A2: if(SingleByteWrite(ACCEL_ADDR, 8'h2D, 8'h16)) StateControl = INTITIALIZE_A3;//Second state should write 8'h16 to register 8'h2D (DATA RATE/POWER)
					INTITIALIZE_A3: if(SingleByteWrite(ACCEL_ADDR, 8'h2D, 8'h08)) StateControl = INTITIALIZE_A4;//Third state should write 8'h08 to register 8'h2D  (DATA RATE/POWER)
					INTITIALIZE_A4: if(SingleByteWrite(ACCEL_ADDR, 8'h31, 8'h08)) StateControl = INTITIALIZE_A5;//Fouth state should write 8'h04 to register 8'h31 (FORMAT)
					INTITIALIZE_A5: if(SingleByteWrite(ACCEL_ADDR, 8'h2C, 8'h08)) StateControl = INTITIALIZE_G1;//Fifth state should write 8'h0F to register 8'h2C

					//| Gyroscope initializtion states
					//|-----------------------------------------------------------------------------------------
					INTITIALIZE_G1: if(SingleByteWrite(Gyro_ADDR, 8'h62, 8'h00)) StateControl = INTITIALIZE_G2;//Fouth state should write 8'h04 to register 8'h31 (FORMAT)
					INTITIALIZE_G2: if(SingleByteWrite(Gyro_ADDR, 8'h21, 8'h04)) StateControl = INTITIALIZE_G3;//Fifth state should write 8'h0F to register 8'h2C
					INTITIALIZE_G3: if(SingleByteWrite(Gyro_ADDR, 8'h22, 8'h1E)) StateControl = INTITIALIZE_G4;//Fifth state should write 8'h0F to register 8'h2C
					INTITIALIZE_G4: if(SingleByteWrite(Gyro_ADDR, 8'h23, 8'h00)) StateControl = ReadAcceletometerXaxisLB;//Fifth state should write 8'h0F to register 8'h2C

					//| Acceleromter debug readback states
					//|-----------------------------------------------------------------------------------------
					`ifdef debug
					ReadbackDataFormat:   //Sixth state should read from the speficified register at REGADDRESS
							begin
							if(FIRSTPASS == 0)
									begin
									SW[0] = 0;
									SD_COUNTER = 0;
									I2CADDRESS = ACCEL_ADDR;
									RW_DIR = 0;
									REGADDRESS = 8'h31;
									FIRSTPASS = 1;
									end

							if(ReadDone)
									begin
									StateControl = ReadbackPOWER_CTL;
									DataFormat = DATAIN;
									FIRSTPASS =0;
									ReadDone = 0;
									end
							end

					ReadbackPOWER_CTL:   //Sixth state should read from the speficified register at REGADDRESS
							begin
							if(FIRSTPASS == 0)
									begin
									SW[0] = 0;
									SD_COUNTER = 0;
									I2CADDRESS = ACCEL_ADDR;
									RW_DIR = 0;
									REGADDRESS = 8'h2D;
									FIRSTPASS = 1;
									end

							if(ReadDone)
									begin
									StateControl = ReadbackRW_RATE;
									POWER_CTL = DATAIN;
									ReadDone = 0;
									FIRSTPASS =0;
									end
							end

					ReadbackRW_RATE:   //Sixth state should read from the speficified register at REGADDRESS
							begin
							if(FIRSTPASS == 0)
									begin
									SW[0] = 0;
									SD_COUNTER = 0;
									I2CADDRESS = ACCEL_ADDR;
									RW_DIR = 0;
									REGADDRESS = 8'h2C;
									FIRSTPASS = 1;
									end

							if(ReadDone)
									begin
									StateControl = ReadAcceletometerXaxisLB;
									RW_RATE = DATAIN;
									ReadDone = 0;
									FIRSTPASS =0;
									end
							end
					`endif

					//| Accelerometer data read states
					//|-----------------------------------------------------------------------------------------
					ReadAcceletometerXaxisLB:   //Sixth state should read from the speficified register at REGADDRESS
							begin
							if(FIRSTPASS == 0)
									begin
									SW[0] = 0;
									SD_COUNTER = 0;
									I2CADDRESS = ACCEL_ADDR;
									RW_DIR = 0;
									REGADDRESS = 8'd50;
									FIRSTPASS = 1;
									end

							if(ReadDone)
									begin
									StateControl = ReadAcceletometerXaxisHB;
									AccelXLB = DATAIN;
									ReadDone = 0;
									FIRSTPASS =0;
									end
							end

					ReadAcceletometerXaxisHB:   //Sixth state should read from the speficified register at REGADDRESS
							begin
							if(FIRSTPASS == 0)
									begin
									SW[0] = 0;
									SD_COUNTER = 0;
									I2CADDRESS = ACCEL_ADDR;
									RW_DIR = 0;
									REGADDRESS = 8'd51;
									FIRSTPASS = 1;
									end
							if(ReadDone)
									begin
									StateControl = ReadAcceletometerYaxisLB;
									AccelXHB = DATAIN;
									ReadDone = 0;
									FIRSTPASS =0;
									end
							end

					ReadAcceletometerYaxisLB:   //Sixth state should read from the speficified register at REGADDRESS
							begin
							if(FIRSTPASS == 0)
									begin
									SW[0] = 0;
									SD_COUNTER = 0;
									I2CADDRESS = ACCEL_ADDR;
									RW_DIR = 0;
									REGADDRESS = 8'd52;
									FIRSTPASS = 1;
									end

							if(ReadDone)
									begin
									StateControl = ReadAcceletometerYaxisHB;
									AccelYLB = DATAIN;
									ReadDone = 0;
									FIRSTPASS =0;
									end
							end

					ReadAcceletometerYaxisHB:   //Sixth state should read from the speficified register at REGADDRESS
							begin
							if(FIRSTPASS == 0)
									begin
									SW[0] = 0;
									SD_COUNTER = 0;
									I2CADDRESS = ACCEL_ADDR;
									RW_DIR = 0;
									REGADDRESS = 8'd53;
									FIRSTPASS = 1;
									end
							if(ReadDone)
									begin
									StateControl = ReadAcceletometerZaxisLB;
									AccelYHB = DATAIN;
									ReadDone = 0;
									FIRSTPASS =0;
									end
							end

					ReadAcceletometerZaxisLB:   //Sixth state should read from the speficified register at REGADDRESS
							begin
							if(FIRSTPASS == 0)
									begin
									SW[0] = 0;
									SD_COUNTER = 0;
									I2CADDRESS = ACCEL_ADDR;
									RW_DIR = 0;
									REGADDRESS = 8'd54;
									FIRSTPASS = 1;
									end

							if(ReadDone)
									begin
									StateControl = ReadAcceletometerZaxisHB;
									AccelZLB = DATAIN;
									ReadDone = 0;
									FIRSTPASS= 0;
									end
							end

					ReadAcceletometerZaxisHB:   //Sixth state should read from the speficified register at REGADDRESS
							begin
							if(FIRSTPASS == 0)
									begin
									SW[0] = 0;
									SD_COUNTER = 0;
									I2CADDRESS = ACCEL_ADDR;
									RW_DIR = 0;
									REGADDRESS = 8'd55;
									FIRSTPASS = 1;
									end

							if(ReadDone)
									begin
									StateControl = ReadGyroscopeXaxisLB;
									AccelZHB = DATAIN;
									ReadDone = 0;
									FIRSTPASS =0;
									end
							end

					//| Gyroscope data read states
					//|-----------------------------------------------------------------------------------------
					ReadGyroscopeXaxisLB:   //Sixth state should read from the speficified register at REGADDRESS
							begin
							if(FIRSTPASS == 0)
									begin
									SW[0] = 0;
									SD_COUNTER = 0;
									I2CADDRESS = Gyro_ADDR;
									RW_DIR = 0;
									REGADDRESS = 8'd30;
									FIRSTPASS = 1;
									end

							if(ReadDone)
									begin
									StateControl = ReadGyroscopeXaxisHB;
									GyroXLB = DATAIN;
									ReadDone = 0;
									FIRSTPASS =0;
									end
							end

					ReadGyroscopeXaxisHB:   //Sixth state should read from the speficified register at REGADDRESS
							begin
							if(FIRSTPASS == 0)
									begin
									SW[0] = 0;
									SD_COUNTER = 0;
									I2CADDRESS = Gyro_ADDR;
									RW_DIR = 0;
									REGADDRESS = 8'd29;
									FIRSTPASS = 1;
									end
							if(ReadDone)
									begin
									StateControl = ReadGyroscopeYaxisLB;
									GyroXHB = DATAIN;
									ReadDone = 0;
									FIRSTPASS =0;
									end
							end

					ReadGyroscopeYaxisLB:   //Sixth state should read from the speficified register at REGADDRESS
							begin
							if(FIRSTPASS == 0)
									begin
									SW[0] = 0;
									SD_COUNTER = 0;
									I2CADDRESS = Gyro_ADDR;
									RW_DIR = 0;
									REGADDRESS = 8'd32;
									FIRSTPASS = 1;
									end

							if(ReadDone)
									begin
									StateControl = ReadGyroscopeYaxisHB;
									GyroYLB = DATAIN;
									ReadDone = 0;
									FIRSTPASS =0;
									end
							end

					ReadGyroscopeYaxisHB:   //Sixth state should read from the speficified register at REGADDRESS
							begin
							if(FIRSTPASS == 0)
									begin
									SW[0] = 0;
									SD_COUNTER = 0;
									I2CADDRESS = Gyro_ADDR;
									RW_DIR = 0;
									REGADDRESS = 8'd31;
									FIRSTPASS = 1;
									end
							if(ReadDone)
									begin
									StateControl = ReadGyroscopeZaxisLB;
									GyroYHB = DATAIN;
									ReadDone = 0;
									FIRSTPASS =0;
									end
							end

					ReadGyroscopeZaxisLB:   //Sixth state should read from the speficified register at REGADDRESS
							begin
							if(FIRSTPASS == 0)
									begin
									SW[0] = 0;
									SD_COUNTER = 0;
									I2CADDRESS = Gyro_ADDR;
									RW_DIR = 0;
									REGADDRESS = 8'd34;
									FIRSTPASS = 1;
									end

							if(ReadDone)
									begin
									StateControl = ReadGyroscopeZaxisHB;
									GyroZLB = DATAIN;
									ReadDone = 0;
									FIRSTPASS= 0;
									end
							end

					ReadGyroscopeZaxisHB:   //Sixth state should read from the speficified register at REGADDRESS
							begin
							if(FIRSTPASS == 0)
									begin
									SW[0] = 0;
									SD_COUNTER = 0;
									I2CADDRESS = Gyro_ADDR;
									RW_DIR = 0;
									REGADDRESS = 8'd33;
									FIRSTPASS = 1;
									end

							if(ReadDone)
									begin
									StateControl = Idle;
									GyroZHB = DATAIN;
									ReadDone = 0;
									FIRSTPASS =0;
									end
							end

					//| Idle state
					//|-----------------------------------------------------------------------------------------
					Idle:
							begin
							GO = 0;
							DataValid = 1;
							ReadDone = 0;
							WriteDone = 0;

							if(IdleCount > 200)
									begin
									if(intialWait == 0)
											begin
											StateControl = ReadAcceletometerXaxisLB;
											IdleCount = 0;
											DataValid = 0;
											GO = 1;
											end
									else
											begin
											StateControl = INTITIALIZE_A1;
											intialWait = 0;
											end
									end
							else
									begin
									IdleCount++;
									end
							end
					endcase


			//| I2C transmitter write cycle
			//|---------------------------------------------------------------------------------------------
			if (StateControl != Idle)
				begin
					if (SW[0])      //This acts as a flag to determine if it needs to read or write
						begin
							case (SD_COUNTER)
								6'd0        : begin SDI =1; SCL = 1; SCL_CTRL =0; end

								////////START///////////
								6'd1        :   SDI = 0;
								6'd2        :   SCL = 0;

								////////I2C Adress. 8th bit is 0 for write, then 9th is tristate for ACK///////
								6'd3        :   begin SDI = I2CADDRESS[6]; SCL_CTRL=1;  end
								6'd4        :   SDI = I2CADDRESS[5];
								6'd5        :   SDI = I2CADDRESS[4];
								6'd6        :   SDI = I2CADDRESS[3];
								6'd7        :   SDI = I2CADDRESS[2];
								6'd8        :   SDI = I2CADDRESS[1];
								6'd9        :   SDI = I2CADDRESS[0];
								6'd10       :   SDI = RW_DIR;
								6'd11       :   SDI = 1;

								/////////reg adress///////////
								6'd12       :   SDI = REGADDRESS[7];
								6'd13       :   SDI = REGADDRESS[6];
								6'd14       :   SDI = REGADDRESS[5];
								6'd15       :   SDI = REGADDRESS[4];
								6'd16       :   SDI = REGADDRESS[3];
								6'd17       :   SDI = REGADDRESS[2];
								6'd18       :   SDI = REGADDRESS[1];
								6'd19       :   SDI = REGADDRESS[0];
								6'd20       :   SDI = 1;

								//////////Data to be writen to the adress////////////////
								6'd21       :   SDI = DATAOUT[7];
								6'd22       :   SDI = DATAOUT[6];
								6'd23       :   SDI = DATAOUT[5];
								6'd24       :   SDI = DATAOUT[4];
								6'd25       :   SDI = DATAOUT[3];
								6'd26       :   SDI = DATAOUT[2];
								6'd27       :   SDI = DATAOUT[1];
								6'd28       :   SDI = DATAOUT[0];
								6'd29       :   begin SDI = 1'bz;SCL_CTRL =0; end           //Switch to next state: SDI = 1'bz

								////////////Stop////////////////
								6'd30       :   begin SDI = 0; SCL = 1;  end
								6'd31       :   SDI = 1; //bz
								6'd42       :   begin WriteDone = 1; SCL_CTRL = 1; end
							endcase
						end

					//| I2C transmitter read cycle
					//|-------------------------------------------------------------------------------------
					else
						begin
							case (SD_COUNTER)
								6'd0        : begin SDI =1; SCL = 1; SCL_CTRL =0;end

								////////START///////////
								6'd1        :   SDI = 0;
								6'd2        :   SCL = 0;

								////////I2C Adress. Still need to write first///////
								6'd3        :   begin SDI = I2CADDRESS[6]; SCL_CTRL=1;  end
								6'd4        :   SDI = I2CADDRESS[5];
								6'd5        :   SDI = I2CADDRESS[4];
								6'd6        :   SDI = I2CADDRESS[3];
								6'd7        :   SDI = I2CADDRESS[2];
								6'd8        :   SDI = I2CADDRESS[1];
								6'd9        :   SDI = I2CADDRESS[0];
								6'd10       :   SDI = RW_DIR;
								6'd11       :   SDI = 1;

								/////////Memory Adress///////////
								6'd12       :   SDI = REGADDRESS[7];
								6'd13       :   SDI = REGADDRESS[6];
								6'd14       :   SDI = REGADDRESS[5];
								6'd15       :   SDI = REGADDRESS[4];
								6'd16       :   SDI = REGADDRESS[3];
								6'd17       :   SDI = REGADDRESS[2];
								6'd18       :   SDI = REGADDRESS[1];
								6'd19       :   SDI = REGADDRESS[0];
								6'd20       :   begin SDI = 1; SCL =1'bz; RW_DIR = 1;end

								//////////Data////////////////
								6'd21       :   begin SDI =1; SCL = 1; end
								6'd22       :   begin SDI = 0; SCL_CTRL=0; end
								6'd23       :   SCL = 0;

								//////I2C Adress with read bit/////////
								6'd24       :   begin SDI = I2CADDRESS[6]; SCL_CTRL=1;  end
								6'd25       :   SDI = I2CADDRESS[5];
								6'd26       :   SDI = I2CADDRESS[4];
								6'd27       :   SDI = I2CADDRESS[3];
								6'd28       :   SDI = I2CADDRESS[2];
								6'd29       :   SDI = I2CADDRESS[1];
								6'd30       :   SDI = I2CADDRESS[0];
								6'd31       :   SDI = RW_DIR;
								6'd32       :   SDI = 1;
								6'd33       :       ;//blank wait for ACK

								/////First byte of data transfer from the slave.//////////
								6'd34       :   DATAIN[7] = I2C_SDA;
								6'd35       :   DATAIN[6] = I2C_SDA;
								6'd36       :   DATAIN[5] = I2C_SDA;
								6'd37       :   DATAIN[4] = I2C_SDA;
								6'd38       :   DATAIN[3] = I2C_SDA;
								6'd39       :   DATAIN[2] = I2C_SDA;
								6'd40       :   DATAIN[1] = I2C_SDA;
								6'd41       :   begin DATAIN[0] = I2C_SDA ;SCL_CTRL =0; end


								////////////Stop////////////////
								6'd42       :   begin SDI = 0; SCL = 1; end
								6'd43       :   begin SDI = 1; ReadDone = 1; end
							endcase
						end
					end
			end
	end
endmodule