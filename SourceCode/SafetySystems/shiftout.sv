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
//|     8 bit parallel input to serial data output with enable clock for CSUS senior design
//|
//|     Author: Mike Frith and David Larribas
//|
//|     This module converts an 8 bit input to a serial output with a latch signal.
//|	    This will provide the source required to drive a amplified R2R DAC through a shift
//|	    register to a "Horn" safety device.
//|
//| =========================================================================================
//| Revision History
//| 3/19/14  MF & DL  Module Creation.
//|
//| =========================================================================================
module shiftout(
        input 	 				INPUTCLOCK,
        input 	 				Button,
        input 	logic   [7:0] 	OutputFromRamp=0,
        output 	logic 			serialoutput=0,
        output 	logic			registerlatch,
        output 	logic 			shiftclock

    );

	//| Local reg/wire declarations
	//|--------------------------------------------
    logic   [7:0]   clkbuffer = 0; //divisor
    logic 	[3:0] 	cnt = 0;
    logic	[7:0] 	datalatch = 0;

	//| Clock divider
	//|--------------------------------------------
    always @(posedge INPUTCLOCK)
		begin
			clkbuffer 	<= clkbuffer  + 1;
			shiftclock 	<= clkbuffer[7];
			cnt 		<= clkbuffer[7] + cnt;
		end
	//| Structural coding
	//|--------------------------------------------
	always@(posedge clkbuffer[7] && Button)
	begin
		case(cnt)
		4'd0: 	serialoutput	<= datalatch[0];
		4'd1: 	serialoutput	<= datalatch[1];
		4'd2: 	serialoutput	<= datalatch[2];
		4'd3: 	serialoutput	<= datalatch[3];
		4'd4: 	serialoutput	<= datalatch[4];
		4'd5: 	serialoutput	<= datalatch[5];
		4'd6: 	serialoutput	<= datalatch[6];
		4'd7: 	serialoutput	<= datalatch[7];
		4'd8: 	registerlatch	<= 1;
		4'd9: 	registerlatch	<= 0;
		4'd10;	datalatch      <= OutputFromRamp;
		default:
			begin
				registerlatch	<= 0,
				serialoutput 	<= 0;
			end
		endcase
	end

endmodule