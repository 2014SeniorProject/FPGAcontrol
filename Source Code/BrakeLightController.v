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