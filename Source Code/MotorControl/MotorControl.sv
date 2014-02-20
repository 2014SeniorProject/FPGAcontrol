module MotorControl(
    //| IMU inputs
    input   logic   [11:0]  Roll,
    input   logic   [11:0]  Pitch,

    //| User control inputs
    input   logic
    //| Motor electrical inputs
    input   logic   [11:0]  PhaseWireVoltage,

    //| motor control outputs
    output  logic           MotorControlPWM
);
    //| This module takes in information about the user's current biometric state
    //| and prefrences. It then calculates an amount of assistance that they should
    //| receive and presents that number to the current control module
    AssistanceAlgorithm Assist(
        .resolvedAngle(),
        .HeartRate(heartRate),          //Commented for testing
        .HeartRateCap(initialHeartCap),
        .cadence(cadence),
        .PWMOut(PWMOutput),
        .brake(brakes),
    );

    //| This module attempts to infer torque from a number of system measurements.
    //| It will require significant testing and modification. The primary idea is
    //| to measure current as voltage across a sense resistor.
    CurrentControl CC(
        .AssistanceCoefficient(AssistanceCoefficient),
        .PhaseWireVoltage(PhaseWireVoltage),
        .MotorSignal(MotorSignal)
    );

    //| This is a pretty simple module that will convert the requested duty cycle
    //| from the current control module into a percentage duty cycle signal for the
    //| ESC's speed setting input. There are a few adjustments for the PWM -> setting
    //| transfer function
    MotorPWMGenerator MotorPWMController(
        .CLOCK_50(CLOCK_50),
        .PWMinput(MotorSignal),
        .PWMout(MotorSignal)
    );

endmodule