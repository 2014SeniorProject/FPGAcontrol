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
//|     Motor assistance calculator
//|
//|     Authors: Ben Smith, Devin Moore
//|
//|     What are we doing here:
//|     kill motor when bike is over 45 degrees right away.
//|     PI heart rate(Hill increases PI constants?)
//|
//| =========================================================================================
//| Revision History
//| 1/2/14  BS  added MIT License.
//|
//| =========================================================================================
module MotorControl(
    input               c50m,
    input               CurrentControlClock,

	//| IMU inputs
    input       [11:0]  ResolvedRoll,
    input       [11:0]  ResolvedPitch,

    //| User control inputs
    input       [7:0]   HeartRate,
    input       [7:0]   HeartRateSetPoint,

    input       [11:0]  ThrottleTest,
	input 				PWMClock,
    input               cadence,

	input				MotorModeSelect,
	
    //| Motor electrical inputs
    input       [11:0]  PhaseWireVoltage,

    //| motor control outputs
    output             	MotorControlPWM
);

    wire        [11:0]  MotorSignal;
	wire        [11:0]  MotorSignalSafety;
    wire        [11:0]  AssistanceRequirement;
	wire        [11:0]  MotorCurrentSetting;

    //| This module takes in information about the user's current biometric state
    //| and prefrences. It then calculates an amount of assistance that they should
    //| receive and presents that number to the current control module
    AssistanceAlgorithm Assist(
        .HeartRate(HeartRate),          //Commented for testing
        .ResolvedPitch(ResolvedPitch),
        .ResolvedRoll(ResolvedRoll),
        .HeartRateSetPoint(HeartRateSetPoint),
        .cadence(cadence),
        .AssistanceRequirement(AssistanceRequirement),
        .brake()
    );

	//assign MotorCurrentSetting = (MotorModeSelect)?AssistanceRequirement:ThrottleTest; //allows override of assistance algorthmn to use twist throttle
	
    //| This module attempts to infer torque from a number of system measurements.
    //| It will require significant testing and modification. The primary idea is
    //| to measure current as voltage across a sense resistor.
    CurrentControl CC(
        .CurrentControlClock(CurrentControlClock),
        .AssistanceRequirement(AssistanceRequirement),
        .PhaseWireVoltage(PhaseWireVoltage),
        .MotorSignal(MotorSignal)
    );
	
	//assign MotorSignalSafety = (ResolvedPitch > 45 degrees && ResolvedRoll > 45degrees) ? MotorSignal : 1'b0; //turns motor signal off is roll or pitch is too large.
	
    //| This is a pretty simple module that will convert the requested duty cycle
    //| from the current control module into a percentage duty cycle signal for the
    //| ESC's speed setting input. There are a few adjustments for the PWM -> setting
    //| transfer function
    motorPWMgenerator MotorPWMController(
        .PWMClock(PWMClock),
        .PWMinput(MotorSignal),
        .PWMout(MotorControlPWM)
    );

endmodule