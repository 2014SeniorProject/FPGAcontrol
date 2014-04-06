`define DEBUG

localparam byte PorportionalityConstant = 8'sd0100;

module CurrentControl(

    input           		CurrentControlClock,
    input   		[11:0]  AssistanceRequirement,
    input   		[11:0]  PhaseWireVoltage,

    output  logic	[11:0]   MotorSignal
);

    logic  			[11:0]	AssistanceAdjusted;
    logic  		 	[11:0]	ADCAdjustedReading;
    logic  	signed 	[11:0]	DeltaTorque;
	logic	signed	[11:0]  PorportionalityConstant;
	logic			[2:0]	MotorState;
	
	logic	    	[14:0] 	clkCount;
		
    assign ADCAdjustedReading = PhaseWireVoltage;
    assign AssistanceAdjusted = AssistanceRequirement;
    assign DeltaTorque = signed'({1'b0, AssistanceAdjusted}) - signed'({ 1'b0, ADCAdjustedReading});
	
	always @(posedge CurrentControlClock) clkCount++;

	assign MotorState = {(AssistanceAdjusted > 16'd00), signed'({1'b0,MotorSignal})+DeltaTorque > 16'sd04096, signed'({1'b0,MotorSignal})+DeltaTorque < 16'sd00};
	
	always @(posedge clkCount[7])
		begin
		   casex(MotorState)
				3'b100 :MotorSignal <= MotorSignal + signed'(DeltaTorque >>> 3);
				3'b110 :MotorSignal <= 12'd4095;
				3'b101 :MotorSignal <= 12'd0;
				default:MotorSignal <= 12'd0;
			endcase
		end
endmodule
