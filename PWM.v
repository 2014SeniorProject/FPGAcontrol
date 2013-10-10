module PWM(

//Clock of 50mhz from the De0-Nano Board
input CLOCK_50,   
////////////////////////////////////////

//10 Bit input from the filter module. Depends on the accelerometer data.
input wire [9:0] PWMinput,
/////////////////////////////////////////////////////////////////////////

//The PWM output the the Motor Controller. 
output reg PWMout
//////////////////////////////////////////

);
//This is an offset for the PWM output. The motor requires around 60% duty cycle to 
//start running smoothly. This will depend on the cycle time of the PWM.
localparam 		Offset = 250;	
///////////////////////////////////////////////////////////////////////////////////

//These deal with the timing of the PWM output. CLOCKslow slows down
reg 	[7:0]		CLOCKslow =0;
reg 	[15:0] 	COUNT = 0;

//These are test points for the In-System Sources and Probes Editor in Quartus
AccelerometerDataRegisters  pwmProbe2 (
   .probe (PWMinput),
   .source ()
);
AccelerometerDataRegisters  pwmProbe3 (
   .probe (PWMout),
   .source ()
);
//////////////////////////////////////////////////////////////////////////////


always @ (posedge CLOCK_50) 
begin 
		CLOCKslow= CLOCKslow + 1;
		if (CLOCKslow > 256) CLOCKslow = 0;
end



always @(posedge CLOCKslow[6])
begin
    COUNT = COUNT + 1;	 
	 if(PWMinput > 12)
	 begin
		 if(COUNT < PWMinput + Offset)
			PWMout=1;
		 else
			PWMout=0;
	 end
	 else PWMout = 0;
	 
    if(COUNT>=530)COUNT=0;
    

end

endmodule