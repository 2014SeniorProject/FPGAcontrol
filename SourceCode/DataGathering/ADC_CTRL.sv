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
//|     Sensor Fusion Module
//|
//|     Authors: Devin Moore and Ben Smith
//|
//|     This module is used to obtain a filtered angle of the system. It requires
//|     10 bit signed accelerometer axis data, and the corresponding gyroscope axis
//|     data. It then outputs a resolved "angle" from -255 to 255.
//|
//| Uncomment the `include "debug.sv" to enter debug mode on this module.
//| Uncomment the `include "timescale.sv" to run a simulation.
//`include "debug.sv"
//`include "timescale.sv"


module ADC_CTRL (
    input                     c1m,
    input                     SPI_IN,

    output  logic             Data_OUT,
    output  logic             CS_n,
    output  logic             SCLK_OUT,
    output  logic   [11:0]    adc_data[6:0]
    );

	logic   [3:0]       cont;
	logic   [3:0]       m_cont;
	logic   [2:0]       ADC_channel;
	logic   [11:0]      adc_dataIN;

	assign  CS_n        = 1'b0;
	assign  SCLK_OUT    = c1m;

	always@(posedge c1m)
	    begin
	        cont    <=  cont + 3'b001;
	    end

	always@(negedge c1m)
	    begin
	        m_cont  <=  cont;
	    end

	//| channel selct
	always@(negedge c1m)
	    begin
	        case(cont)
	        4'd03: Data_OUT <=  ADC_channel[2];
	        4'd04: Data_OUT <=  ADC_channel[1];
	        4'd05: Data_OUT <=  ADC_channel[0];
	        default: Data_OUT <= 1'b0;
	        endcase
	    end

	//| Data In
	always@(posedge c1m)
	    begin
	        case(m_cont)
	        4'd01: adc_data[ADC_channel] <= adc_dataIN[11:0];//(78*adc_data[ADC_channel] + 22*adc_dataIN[11:0])/100;
	        // shift data in
	        4'd03: adc_dataIN[11]   <=  SPI_IN;
	        4'd04: adc_dataIN[10]   <=  SPI_IN;
	        4'd05: adc_dataIN[9]    <=  SPI_IN;
	        4'd06: adc_dataIN[8]    <=  SPI_IN;
	        4'd07: adc_dataIN[7]    <=  SPI_IN;
	        4'd08: adc_dataIN[6]    <=  SPI_IN;
	        4'd09: adc_dataIN[5]    <=  SPI_IN;
	        4'd10: adc_dataIN[4]    <=  SPI_IN;
	        4'd11: adc_dataIN[3]    <=  SPI_IN;
	        4'd12: adc_dataIN[2]    <=  SPI_IN;
	        4'd13: adc_dataIN[1]    <=  SPI_IN;
	        4'd14: adc_dataIN[0]    <=  SPI_IN;
	        default: ;
	        endcase
	    end

	//| Data In
	always@(negedge c1m)
	    begin
	        if(m_cont == 4'd0001)
	            begin
	                if(ADC_channel > 3'd6) ADC_channel <= 0;
					else ADC_channel <= ADC_channel+1;
	            end
	    end
endmodule