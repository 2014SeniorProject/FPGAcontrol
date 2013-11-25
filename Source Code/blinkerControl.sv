//| Module to blink control a blinker
//|
//|	Author: Devin Moore
//|

module blinker (
input		wire	c50M,
input		wire	rightBlink,				//Debounced input for blinker
input		wire	leftBlink,
output	wire	rightBlinkerOut,
output 	wire	leftBlinkerOut	
);

reg 		[24:0] 	count;

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