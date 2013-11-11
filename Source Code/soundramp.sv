//|     Sawtooth wave generator for CSUS senior design
//|
//|     Author: Mike Frith
//|
//| 		This module generates a sawtooth wave for a 8 bit R2R DAC   
//|			This will provide the source required to drive a amplified
//|			"Horn" safety device
//|
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