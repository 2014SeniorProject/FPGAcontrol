`define DEBUG

localparam byte PorportionalityConstant = 8'sd050;

module CurrentControl(
    input           c20k,
    input   		[11:0]  AssistanceRequirement,
    input   		[11:0]  PhaseWireVoltage,

    output  		[11:0]   MotorSignal
);

    logic  			[11:0]	AssistanceAdjusted;
    logic  		 	[11:0]	ADCAdjustedReading;
    logic  	signed 	[11:0]	DeltaTorque;
	logic	signed	[11:0]  PorportionalityConstant;
	
	logic	        [14:0] 	clkCount;
	logic	        [2:0]	MotorState;
	logic			[3:0]	clockSelect;
	
    assign ADCAdjustedReading = PhaseWireVoltage;
    assign AssistanceAdjusted = AssistanceRequirement;
    assign DeltaTorque = signed'({1'b0, AssistanceAdjusted}) - signed'({ 1'b0, ADCAdjustedReading});

	//|Debug Systems and Probes
	`ifdef DEBUG 
		CurrentControlProbe cc1(ADCAdjustedReading);
		CurrentControlProbe cc2(.probe(DeltaTorque));
		CurrentControlProbe cc3(.probe(MotorSignal));
	`endif
	
	always @(posedge c20k) clkCount++;

	assign MotorState = {AssistanceAdjusted > 16'd03, signed'({1'b0,MotorSignal})+DeltaTorque > 16'sd04096, signed'({1'b0,MotorSignal})+DeltaTorque < 16'sd00};
	
	always @(posedge clkCount[3])
		begin
		   casex(MotorState)
				3'b100 :MotorSignal <= signed'({1'b0,MotorSignal}) + (DeltaTorque/PorportionalityConstant);
				3'b110 :MotorSignal <= 12'd4095;
				3'b101 :MotorSignal <= 12'd0;
				default:MotorSignal <= 12'd0;
			endcase
		end
endmodule
