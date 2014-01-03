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
//|     Sawtooth wave generator for CSUS senior design
//|
//|     Author: Mike Frith
//|
//|     This module generates a sawtooth wave for a 8 bit R2R DAC
//|	    This will provide the source required to drive a amplified
//|	    "Horn" safety device
//|
//| =========================================================================================
//| Revision History
//| 1/2/14  BS  added MIT License.
//|
//| =========================================================================================
module soundramp(
    input 	wire 				c50M,
    input 	wire 				Button,
    output 	reg [7:0] 	OutputToDAC=0
    );

	//| Local reg/wire declarations
	//|--------------------------------------------
    reg [7:0] clkbuffer = 0;

	//| Clock divider
	//|--------------------------------------------
    always @(posedge c50M)
		clkbuffer = clkbuffer  + 1;


	//| Structual coding
	//|--------------------------------------------
    always @(posedge clkbuffer[7])
		begin
			if(Button)
				begin
					OutputToDAC = OutputToDAC + 1;
				end
		end
endmodule