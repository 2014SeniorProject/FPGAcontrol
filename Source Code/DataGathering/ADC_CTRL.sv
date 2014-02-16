module ADC_CTRL	(
	input						c1m,
	input						SPI_IN,

	output	logic				Data_OUT,
	output	logic				CS_n,
	output	logic				SCLK_OUT,
	output	logic	[11:0]		adc_data[7]
	);

reg		[3:0]		cont;
reg		[3:0]		m_cont;
reg		[2:0]		ADC_channel;
logic	[11:0]		adc_dataIN;

assign	CS_n		= 0;
assign	SCLK_OUT	= c1m;

always@(posedge c1m)
begin
	cont	<=	cont + 1;
end

always@(posedge !c1m)
begin
	m_cont	<=	cont;
end

//| channel selct
always@(posedge n_c1m)
	begin
		case(cont)
			4'd02: Data_OUT	<=	ADC_channel[2];
			4'd03: Data_OUT	<=	ADC_channel[1];
			4'd04: Data_OUT	<=	ADC_channel[0];

			default: Data_OUT <= 0;
		endcase
	end

//| Data In
always@(posedge c1m)
	begin
		case(m_cont)
			// shift data in
			4'd04: adc_dataIN[11]	<=	SPI_IN;
			4'd05: adc_dataIN[10]	<=	SPI_IN;
			4'd06: adc_dataIN[9]	<=	SPI_IN;
			4'd07: adc_dataIN[8]	<=	SPI_IN;
			4'd08: adc_dataIN[7]	<=	SPI_IN;
			4'd09: adc_dataIN[6]	<=	SPI_IN;
			4'd10: adc_dataIN[5]	<=	SPI_IN;
			4'd11: adc_dataIN[4]	<=	SPI_IN;
			4'd12: adc_dataIN[3]	<=	SPI_IN;
			4'd13: adc_dataIN[2]	<=	SPI_IN;
			4'd14: adc_dataIN[1]	<=	SPI_IN;
			4'd15: adc_dataIN[0]	<=	SPI_IN;

			//save received data
			3'd01:
				begin
					adc_data[ADC_channel][11:0] <= adc_dataIN[11:0];
					ADC_channel++;

					if(ADC_channel > 6) ADC_channel = 0;
				end
			default: ;
		endcase
	end
endmodule