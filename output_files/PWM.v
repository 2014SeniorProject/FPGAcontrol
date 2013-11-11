module PWM(
ReadDone;

AccelZ;

PWMsignal;

)


reg 	[15:0]	total = 0;
reg 	[9:0]		PWMsignal = 0;
reg	[5:0]		averageCount = 0;
reg   [9:0]		averageData = 0;

IMUInterface(
	.ReadDone(ReadDone),	
	.AccelZ(AccelZ),	
	);

always @ (negedge ReadDone)
begin

	if (averageCount < 6)
		total = total + AccelZ;
	else
	begin
		total = total/6;
		averageData = total;
		averageCount =0;
	end

	if (averageCount <0 )
		PWMsignal = 0;
	else
		PWMsignal = 256-averageData;


end

endmodule
