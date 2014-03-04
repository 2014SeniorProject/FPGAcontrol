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

	ADCReadback ADCReadback_inst0 (.probe ( adc_data[0] ));
	ADCReadback ADCReadback_inst1 (.probe ( adc_data[1] ));
	ADCReadback ADCReadback_inst2 (.probe ( adc_data[2] ));
	ADCReadback ADCReadback_inst3 (.probe ( adc_data[3] ));
	ADCReadback ADCReadback_inst4 (.probe ( adc_data[4] ));
	ADCReadback ADCReadback_inst5 (.probe ( adc_data[5] ));
	ADCReadback ADCReadback_inst6 (.probe ( adc_data[6] ));

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
	        4'd01: adc_data[ADC_channel] <= (adc_data[ADC_channel]*98 + adc_dataIN[11:0]*2)/100;
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