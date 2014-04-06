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
//|     Hardware button debounce for CSUS senior design
//|
//|     Author: Mike Frith
//|
//| 		This module will prevent a hardware button's switching behavior
//|			from being registered as multiple button presses.
//|
//| =========================================================================================
//| Revision History
//| 1/2/14  BS  added MIT License.
//|
//| =========================================================================================
module debounced_button(
    input              clock,
    input              Button,
    output logic       ButtonOut =0
    );

	//| Local reg/wire declarations
	//|--------------------------------------------
    logic   [16:0] Clkbuffer = 0;

	//| Debounce logic
	//|--------------------------------------------
    always @(posedge clock)
        begin
            if (Button) Clkbuffer <= Clkbuffer + 1;
            else begin
                Clkbuffer <= 17'b0;
                ButtonOut <= 0;
            end
			
            if (Clkbuffer == 17'b1) begin
                Clkbuffer <= 17'b1;
                ButtonOut <= 1;
            end
        end
endmodule