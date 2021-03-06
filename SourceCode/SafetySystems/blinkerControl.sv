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
//|     Turn signal blinker module for CSUS Senior Design
//|
//|     Authors: Devin Moore and Ben Smith
//|
//|     This module generates a half second period square wave when the right or left blink
//|		input goes high.
//|
//| =========================================================================================
//| Revision History
//| 1/2/14  BS  added MIT License.
//|
//| =========================================================================================
module blinker (
	input				c50M,
	input				rightBlink,				//Debounced input for blinker
	input				leftBlink,
	output	logic		rightBlinkerOut,
	output 	logic		leftBlinkerOut
);

	logic 		[24:0] 	count;

	always@(posedge c50M) count++;

	always@(posedge c50M)
		begin
			if(leftBlink)
				begin
					if(count[24] == 0) leftBlinkerOut = 1;
					else leftBlinkerOut = 0;
				end
			else leftBlinkerOut = 0;

			if(rightBlink)
				begin
					if(count[24] == 0) rightBlinkerOut = 1;
					else rightBlinkerOut = 0;
				end
			else	rightBlinkerOut = 0;
		end

endmodule