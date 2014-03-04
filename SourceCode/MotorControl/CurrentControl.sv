//| Distributed under the MIT license.
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
//|     Motor control algorithm for CSUS Senior Design
//|
//|     Authors: Devin Moore and Ben Smith
//|
//|     This module solves an issue with our controller that only accepts speed while we need
//|     to control torque. This "conversion" is made with a PID type controller loop accepting
//|     a current measurement and target assistance amount. The controller will increase the
//|     speed setting sent to the controller until the current matches the desired assistance
//|     amount. This current control effectively controls the torque of the motor.
//|
//| =========================================================================================
//| Revision History
//| 1/2/14  BS  Initial Input
//|
//| =========================================================================================
localparam byte PorportionalityConstant = 8'sd010;

module CurrentControl(
    input           c20k,
    input   [11:0]  AssistanceRequirement,
    input   [11:0]  PhaseWireVoltage,

    output  [7:0]   MotorSignal
);

    byte  			AssistanceAdjusted;
    byte  			ADCAdjustedReading;
    assign DeltaTorque = signed'(AssistanceAdjusted) - signed'(ADCAdjustedReading); // calculate the required speed settings


	logic	[14:0] 			clkCount;
	logic	[2:0]			MotorState;

    assign ADCAdjustedReading = (PhaseWireVoltage)>>4;
    assign AssistanceAdjusted = (AssistanceRequirement>>4)-63;
    assign DeltaTorque = signed'({1'b0, AssistanceAdjusted}) - signed'({ 1'b0, ADCAdjustedReading});

    ADCReadback ADCReadback_inst0 (.probe (ADCAdjustedReading));
    ADCReadback ADCReadback_inst1 (.probe (AssistanceAdjusted));
	ADCReadback ADCReadback_inst2 (.probe (DeltaTorque));
    ADCReadback ADCReadback_inst3 (.probe (MotorSignal));
	ADCReadback ADCReadback_inst4 (.probe (MotorState));

    //| clock divider register for debugging
	always @(posedge c20k) clkCount++;

                                                    //| type cast for unsigned numbers,      |10 bit signed number used for comparison             |<bitwidth>'<signed><format><number>
                                                    //| preceding zero is required for       |if 8 bit is used the comparison can                  | constants must be specified as signed
                                                    //| proper sign extension                |overflow causing invalid operation                   | if all operands are not signed Verilog
                                                    //|                                      |                                                     | will default to unsigned operations
	assign MotorState = {AssistanceAdjusted > 8'd0, signed'({1'b0,MotorSignal})+DeltaTorque > 10'sd0255, signed'({1'b0,MotorSignal})+DeltaTorque < 10'sd00};

	always @(posedge clkCount[6])
		begin
		   casex(MotorState)
				3'b100 :MotorSignal <= signed'({1'b0,MotorSignal}) + (DeltaTorque/PorportionalityConstant);
				3'b110 :MotorSignal <= 8'd255;
				3'b101 :MotorSignal <= 8'd0;
				default:MotorSignal <= 8'd0;
			endcase
		end
endmodule
