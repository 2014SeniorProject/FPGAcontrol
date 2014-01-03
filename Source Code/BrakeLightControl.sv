//| Distributed under the MIT licence.
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
//|     Brake light controller for Team 3 CSUS senior project
//|
//|     Authors: Devin Moore and Ben Smith
//|
//|     This module dims the brake light to 50% for "off" when the headlight is on otherwise
//|     it operates as a normal brake light.
//|
//|
//| =========================================================================================
//| Revision History
//| 1/2/14  BS  added MIT License.
//|
//| =========================================================================================
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