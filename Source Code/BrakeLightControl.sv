module BrakeLightController(
  input   wire    brakeActive,
  input   wire    headlightActive,
  input   wire    c50M,
  output  wire    brakePWM
);

  //|
  //| Local reg/wire declarations
  //|--------------------------------------------
  motorPWMGenerator brakePWM(
    .offset(0)
    )#(
    .CLOCK_50(CLOCK_50),
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
  always @(posedge CLOCK_50)
    begin
      casex({brakeActive, headlightActive})
        1x: brakePWM <= 10'b1111111111;
        01: brakePWM <= 10'b0000011111;
        00: brakePWM <= 10'b0000000000;
      endcase
    end
endmodule