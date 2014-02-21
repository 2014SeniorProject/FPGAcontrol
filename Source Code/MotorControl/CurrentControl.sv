localparam PorportionalityConstant = 1;

module CurrentControl(
    input   [9:0]   AssistanceRequirement,
    input   [11:0]  PhaseWireVoltage,

    output  [9:0]   MotorSignal
);

    logic   [11:0]  ADCAdjustedReading;

    assign ADCAdjustedReading = PhaseWireVoltage - 1000;

always @(*)
    begin
       if(AssistanceRequirement > 0) MotorSignal += PorportionalityConstant*(AssistanceRequirement - ADCAdjustedReading);
        else MotorSignal = 0;
    end

endmodule