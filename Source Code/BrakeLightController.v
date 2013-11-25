module BrakeLightController(
  input   wire    brakeActive,
  input   wire    headLightActive,
  input   wire    c50M,
  output  wire    brakePWM
);

  //|
  //| Local reg/wire declarations
  //|--------------------------------------------
  PWMGenerator #(
    .Offset(0)
    )brakeOutPWM(
    .CLOCK_50(c50M),
    .PWMinput(PWMinput),
    .PWMout(brakePWM)
    );

  //|
  //| Local reg/wire declarations
  //|--------------------------------------------
  reg   [9:0]   PWMinput = 0;

  //|
  //| Structual coding
  //|--------------------------------------------
  always @(posedge c50M)
    begin
      casex({brakeActive, headLightActive})
        2'b1x: PWMinput <= 10'b1111111111;
        01: PWMinput <= 10'b0000011111;
        00: PWMinput <= 10'b0000000000;
      endcase
    end
endmodule