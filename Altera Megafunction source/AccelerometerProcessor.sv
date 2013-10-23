module AccelerometerProcessor(
    input      wire                    c50m,
    input      wire        [11:0]      AccelX,
    input      wire        [11:0]      AccelY,
    input      wire        [11:0]      AccelZ,

    input      wire                    IMUDataReady,

    output     reg         [11:0]      OutputX
    );

parameter AverageLength = 100;  //| drops accelerometer datarate

reg     [7:0]        AccelerometerData [AverageLength : 0];
reg     [10 : 0]     OutputCounter; //limits to 1000 samples
reg     [24 : 0]     SummingRegister; //limits to 1000 samples

//|
//| Generates large shift register to hold the accelerometer data
genvar c;
generate
    for (c = 1; c < AverageLength; c = c + 1)
        begin: test
        always @(posedge IMUDataReady)
            begin
            AccelerometerData[c] <= AccelerometerData[c-1];
            end
        end
endgenerate

//|
//| Load first register and
reg [20:0] i = 0;
always @(posedge IMUDataReady)
    begin
        AccelerometerData[0] = AccelX;

        //| Average all the bits in array
        if(OutputCounter > AverageLength)
            begin
            for(i = 0; i < AverageLength; i++) SummingRegister += AccelerometerData[i];
            OutputX = SummingRegister/AverageLength;

		    OutputCounter = 0;
            end
        else
            begin
		    OutputCounter++;
            end
    end
endmodule