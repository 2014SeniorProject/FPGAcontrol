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
//|     This is the top level module for the safety systems of Project Forward. This module
//|     instanciates debounce modules for the user inputs, controls for the lighting system,
//|     and controls for the audible alert.
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


module SafetyControls(
    input                   CLOCK_50,
    input                   leftBlinker,        //buttons in
    input                   rightBlinker,       //buttons in
    input                   headLight,          //buttons in
    input                   horn,               //buttons in
    input                   brakes,

    output                  leftBlinkerOut,
    output                  rightBlinkerOut,
    output                  headLightOut,
    output                  brakeLightOut,
    output      [7:0]       DACout             //DAC output
);

    wire                    DBleftBlinker;
    wire                    DBrightBlinker;
    wire                    DBhorn;
    wire                    DBheadLight;

    assign headLightOut = DBheadLight;

    //|
    //| Light controls
    //|--------------------------------------------
    blinker blinkerControls(
        //| Inputs
        .c50M(CLOCK_50),
        .leftBlink(DBleftBlinker),
        .rightBlink(DBrightBlinker),
        //| Outputs
        .rightBlinkerOut(rightBlinkerOut),
        .leftBlinkerOut(leftBlinkerOut)
    );


    BrakeLightController BrakeLightController(
        //| Inputs
        .c50M(CLOCK_50),
        .brakeActive(brakes),
        .headLightActive(headLightOut),
        //| Outputs
        .brakePWM(brakeLightOut)
    );

    //|
    //| Horn Controller
    //|--------------------------------------------
    soundramp   HornOut (
        //| Inputs
        .c50M(CLOCK_50),
        .Button(DBhorn),
        //| Outputs
        .OutputToDAC(DACout)
    );

    //|
    //| Debounce all of the inputs from the buttons
    //|---------------------------------------------
    debounced_button RightBlinker(
        //| Inputs
        .c50M(CLOCK_50),
        .Button(rightBlinker),
        //| Outputs
        .ButtonOut(DBrightBlinker)
    );

    debounced_button LeftBlinker(
        //| Inputs
        .c50M(CLOCK_50),
        .Button(leftBlinker),
        //| Outputs
        .ButtonOut(DBleftBlinker)
    );

    debounced_button HeadLight(
        //| Inputs
        .c50M(CLOCK_50),
        .Button(headLight),
        //| Outputs
        .ButtonOut(DBheadLight)
    );

    debounced_button Horn(
        //| Inputs
        .c50M(CLOCK_50),
        .Button(horn),
        //| Outputs
        .ButtonOut(DBhorn)
    );

	endmodule