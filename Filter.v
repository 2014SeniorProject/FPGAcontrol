module Filter(

input ReadDone,

input wire [9:0] AccelX,

output reg [9:0] PWMinput

);

	

AccelerometerDataRegisters  pwmProbe1 (
   .probe (AccelX),
   .source ()
);
AccelerometerDataRegisters  pwmProbe2 (
   .probe (PWMinput),
   .source ()
);



reg 	[15:0]	total = 0;
//reg 	[9:0]		PWMsignal = 0;
reg	[5:0]		averageCount = 0;
reg   [9:0]		averageData = 0;



	 
	 

always @ (posedge ReadDone)
begin
if(AccelX[9]==0)
	if (averageCount < 50)	
		begin
			total = total + AccelX;
			averageCount = averageCount +1;
		end
		else
		begin
			total = total/50;
			averageData = total;
			averageCount =0;
		end
else averageData[9] =1;
	
	if (averageData[9] == 1 )
		PWMinput = 0;
	else
		PWMinput = averageData;


end
endmodule
