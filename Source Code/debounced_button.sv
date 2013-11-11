//|     Hardware button debounce for CSUS senior design
//|
//|     Author: Mike Frith
//|
//| 		This module will prevent a hardware button's switching behavior 
//|			from being registered as multiple button presses. 
//|			
//|
module debounced_button(
    input wire c50M,
    input wire Button,
    output reg ButtonOut =0
    );

		//| Local reg/wire declarations
		//|-------------------------------------------- 
    reg [16:0] Clkbuffer = 0;

		//| Debounce logic
		//|--------------------------------------------
    always @(posedge c50M)
        begin
            if (Button)
                Clkbuffer = Clkbuffer + 1;
            else
            begin
                Clkbuffer = 17'b0;
                ButtonOut = 0;
            end
            if (Clkbuffer == 17'b1)
                begin
                Clkbuffer = 17'b1;
                ButtonOut = 1;
                end
        end
endmodule