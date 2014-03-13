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
//|     This is the top level module for the IMU and its calculations. It instantiates modules to
//|         poll the accelerometer and gyroscope over I2C bus, filter the obtained data, and resolve
//|         angles from the filtered data.
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



module IMUCalculations (
    input                       CLOCK_50,           //Input clock

    inout                       I2C_SCL,            //I2C Clock Signal
    inout                       I2C_SDA,            //I2C Data Signal

    output      [9:0]           ResolvedPitch,      //Inclination data
    output      [9:0]           ResolvedRoll,        //Side to side angle
	output 	    [7:0]		    LED
    );

    //| Accelerometer
    wire        [9:0]           AccelX;
    wire        [9:0]           AccelY;
    wire        [9:0]           AccelZ;

    //| Gyroscope
    wire        [9:0]           GyroX;
    wire        [9:0]           GyroY;
    wire        [9:0]           GyroZ;

    //| Filtered Accelerometer
    wire        [9:0]           FAccelX;
    wire        [9:0]           FAccelY;
    wire        [9:0]           FAccelZ;

    //| Filtered Gyroscope
    wire        [9:0]           FGyroX;
    wire        [9:0]           FGyroY;
    wire        [9:0]           FGyroZ;

    //| IMU data trigger
    wire                        IMUDataReady;

    //| Low pass filter data ready flag
    wire                        LowPassDataReady;



    ADCReadback pitchProbe (.probe (ResolvedPitch));
    ADCReadback rollProbe (.probe (ResolvedRoll));


    //|
    //| Main interface to the Accelerometer and Gyroscope. Requires a 50mhz clock input
    //| And inout signals for the I2C line.
    //|---------------------------------------------
    IMUInterface IMU(
        //| Inputs
        .CLOCK_50(CLOCK_50),
        .I2C_SCL(I2C_SCL),
        .I2C_SDA(I2C_SDA),
        //| Outputs
        .AccelX(AccelX),
        .AccelY(AccelY),
        .AccelZ(AccelZ),
        .GyroX(GyroX),
        .GyroY(GyroY),
        .GyroZ(GyroZ),
        .DataValid(IMUDataReady)
    );



    //|
    //| This instanciation takes in the raw unfiltered accelerometer data from all axis and
    //| Passes them through a digital low pass filter to remove unwanted noise.
    //|---------------------------------------------
        LowPassFilterAverage #(
        .FilterLength(100)
    )AccelerometerFilter(
        //| Inputs
        .ReadDone(IMUDataReady),
        .AccelX(AccelX),
        .AccelY(AccelY),
        .AccelZ(AccelZ),
        //| Outputs
        .AccelXOut(FAccelX),
        .AccelYOut(FAccelY),
        .AccelZOut(FAccelZ),
        .DataReady(LowPassDataReady)
    );

    //|
    //| This will calculate a reliable value for the inclination, or pitch, of the system
    //|---------------------------------------------
    SensorFusion InclanationCalculator(
        //| Inputs
        .DataReady(IMUDataReady),
        .Accel1(FAccelX),
        .Gyro(GyroY),
        //| Outputs
        .ResolvedAngle(ResolvedPitch)
    );


    //|
    //| This will calculate the roll of the system, or the side to side angle of the bike
    //|---------------------------------------------
        SensorFusion RollCalculator(
        //| Inputs
        .DataReady(IMUDataReady),
        .Accel1(FAccelY),
        .Gyro(GyroX),
        //| Outputs
        .ResolvedAngle(ResolvedRoll)
    );


	//|
	//| IMU LED visualization
	//|--------------------------------------------
	PWMGenerator #(
		.Offset(0),
		.pNegEnable(1)
	)AccelAngleLED(
		.CLOCK_50(CLOCK_50),
		.PWMinput(ResolvedRoll),
		.PWMout(LED[7])
	);

	PWMGenerator #(
		.Offset(0),
		.pNegEnable(1)
	)AccelXLED(
		.CLOCK_50(CLOCK_50),
		.PWMinput(FAccelX),
		.PWMout(LED[0])
	);

	PWMGenerator #(
		.Offset(0),
		.pNegEnable(1)
	)AccelYLED(
		.CLOCK_50(CLOCK_50),
		.PWMinput(FAccelY),
		.PWMout(LED[1])
	);

	PWMGenerator #(
		.Offset(0),
		.pNegEnable(1)
	)AccelZLED(
		.CLOCK_50(CLOCK_50),
		.PWMinput(FAccelZ),
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

	endmodule