module CurrentControl(
    input   [9:0]   AssistanceCoefficient,
    input   [11:0]  PhaseWireVoltage,

    output  [9:0]   MotorSignal
);

always @(*)
    begin
       MotorSignal = PhaseWireVoltage - AssistanceCoefficient;
    end

endmodule