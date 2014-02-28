localparam byte PorportionalityConstant = 8'sd010;

module CurrentControl(
    input           c20k,
    input   [11:0]  AssistanceRequirement,
    input   [11:0]  PhaseWireVoltage,

    output  [7:0]   MotorSignal
);

    byte  			AssistanceAdjusted;
    byte  			ADCAdjustedReading;
    byte  			DeltaTorque;

	logic	[14:0] 	clkCount;
	logic	[2:0]	MotorState;
	
    assign ADCAdjustedReading = PhaseWireVoltage>>4;
    assign AssistanceAdjusted = (AssistanceRequirement>>4);
    assign DeltaTorque = signed'(AssistanceAdjusted) - signed'(ADCAdjustedReading);
	
	
    ADCReadback ADCReadback_inst0 (.probe (ADCAdjustedReading));
    ADCReadback ADCReadback_inst1 (.probe (AssistanceAdjusted));
	ADCReadback ADCReadback_inst2 (.probe (DeltaTorque));
    ADCReadback ADCReadback_inst3 (.probe (MotorSignal));
	ADCReadback ADCReadback_inst4 (.probe (MotorState));

	always @(posedge c20k)
    clkCount++;
	
	assign MotorState = {AssistanceAdjusted > 8'd0, signed'({1'b0,MotorSignal})+DeltaTorque > 10'sd0255, signed'({1'b0,MotorSignal})+DeltaTorque < 10'sd00};

	always @(posedge clkCount[7])
		begin
		   casex(MotorState)
				3'b100 :MotorSignal <= signed'({1'b0,MotorSignal}) + (DeltaTorque/PorportionalityConstant);
				3'b110 :MotorSignal <= 8'd255;
				3'b101 :MotorSignal <= 8'd0;
				default:MotorSignal <= 8'd0;
			endcase
		end
endmodule