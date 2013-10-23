//|     Motor assistance calculator
//|
//|     Authors: Ben Smith
//|
//|     This module will take in the cadence, heart rate, wheel speed, and IMU data to calculate the required
//|     motor thrust to assist the rider.
//|
//|
`timescale 10 ns / 1 ns

module AssistanceAlgorithm(
    input  wire                clk,

    //| IMU Inputs
    input  wire    [17:0]      AccelX,
    input  wire    [17:0]      AccelY,
    input  wire    [17:0]      AccelZ,

    input  wire    [17:0]      GyroX,
    input  wire    [17:0]      GyroY,
    input  wire    [17:0]      GyroZ,

    input  wire    [7:0]       HeartRateSetting,
    //| Motor output
    output reg                 PWMOut
    );

    //|
    //| Local reg/wire declarations
    //|--------------------------------------------


    //| State machine control
    //|--------------------------------------------


    //|
    //| Structual Coding
    //|--------------------------------------------

    always @ (posedge clk)
        begin

        end
endmodule