localparam PorportionalityConstant = 10;

module CurrentControl(
    input           c20k,
    input   [11:0]  AssistanceRequirement,
    input   [11:0]  PhaseWireVoltage,

    output  [7:0]   MotorSignal
);

    logic           [7:0]  AssistanceAdjusted;
    logic           [7:0]  ADCAdjustedReading;
    logic   signed  [8:0]  DeltaTorque;

    assign ADCAdjustedReading = PhaseWireVoltage>>4;
    assign AssistanceAdjusted = (AssistanceRequirement>>4)-65;
    assign DeltaTorque = AssistanceAdjusted - ADCAdjustedReading;

    ADCReadback ADCReadback_inst0 (.probe (ADCAdjustedReading));
    ADCReadback ADCReadback_inst1 (.probe (AssistanceAdjusted));
    ADCReadback ADCReadback_inst2 (.probe (MotorSignal));

always @(posedge c20k)
    begin
       casex({AssistanceAdjusted > 0, MotorSignal+DeltaTorque > 255, MotorSignal+DeltaTorque < 0})
            3'b100 :MotorSignal += DeltaTorque/PorportionalityConstant;
            3'b110 :MotorSignal = 255;
            3'bx01 :MotorSignal = 0;
            default: MotorSignal = 0;
        endcase
    end
endmodule