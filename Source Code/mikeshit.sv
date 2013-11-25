module mikeshit(
input clk,
input button,
output [7:0]	DAC
);

reg			[7:0]		CLK_SLOW = 0;



always@(posedge clk) CLK_SLOW = CLK_SLOW++;

always@(posedge CLK_SLOW[7])
	begin	
		if(button)
			begin
				DAC++;
			end
	end
endmodule
