module ByteController(
    input   wire            c50m = 0,
    input   reg             start = 0,

    input   reg    [7:0]    DataIn = 0,
    output  reg    [7:0]    DataOut = 0,

    output  reg             busy = 0;

    );

//Reg/Wire Declarations
wire        reset_n;                            //This is assigned to key[0] and used to reset the SD counter for testing

reg     [1:0]       SW = 1;                     //read or write flag, 1 for write, 0 for read...
reg                 SCL_CTRL = 0;               //This is used for the clock. ----TEST!!!!!!
reg     [7:0]       DATAIN = 0;                 //This is where the data is stored when reading a byte
reg                 GO = 0;                     //This signals the operation to start
reg     [6:0]       SD_COUNTER = 0;             //This is used for the casses in the bitwise read and write states
reg                 SDI = 0;                    //place holder for I2C_SDA
reg                 SCL = 0;                    //Place holder for I2C_SCL during start/stop
reg     [9:0]       COUNT = 0;                  //Used to slow down clock for I2C
reg     [7:0]       LEDOUT = 0;                 //I think I stopped using this? again too lazy right now to check.
reg     [7:0]       REGADDRESS = 0;             //Address of the register
reg     [6:0]       I2CADDRESS = 0;             //7 bit address of slave
reg                 RW_DIR = 0;                 //Read write direction. 0 - Write, 1- Read.
reg     [7:0]       DATAOUT = 0;                //Data to be sent to slave
reg     [7:0]       FLAGS = 0;                  //Flag register. Starts at 0, then thing happen...
reg                 FIRSTPASS =0;
reg     [7:0]       RWDELAY = 0;

//| Bidirectional controls for SCL and SDA Pins
assign I2C_SCL = (SCL_CTRL)? ~COUNT[7] : SCL;   //Assign the SCL normal 100khz clk, besides the start/stop conditions
assign I2C_SDA = (SCL_CTRL)?((SDI)? 1'bz : 0):SDI;          //Yeah, just assign the placeholder SDI to the SDA line

//The Clock values will need to be changed as previously mentioned
always @ (posedge c50m) COUNT = COUNT +1;

//This just takes care of our "start operation" button
always @ (posedge COUNT[7] or negedge reset_n)
    begin
        if (!reset_n)
            GO = 0;
        else
            if(!KEY[1])
                GO =1;
    end

//This Allows for one opperation. We will probably need to change this to do continuously,
//or maybe just reset it everytime we need to read again?? something to think about.
always @ (posedge COUNT[7] or negedge reset_n)
    begin
        if(!reset_n)
            SD_COUNTER = 6'b0;
        else
            begin
                if(!GO)
                    SD_COUNTER = 0;
                else
                    if(SD_COUNTER < 50)
                        SD_COUNTER = SD_COUNTER+1;
                else            //The rest of this stuff is here to bypass the go and reset buttons.
                    begin
                        if(RWDELAY <250)
                            RWDELAY = RWDELAY +1;
                        else
                        begin
                            RWDELAY =0;
                            SD_COUNTER =0;
                        end
                    end
            end
    end

    //I2C Operation, Write
    always @ (posedge COUNT[7]/* or negedge reset_n*/)
    begin
        if(!reset_n)
        begin
            SCL = 1;
            SDI = 1;
        end
        else

    //This Section is for writing, If switch one is to the left
    //*********************************************************
    if (SW[0])      //This acts as a flag to determine if it needs to read or write
    begin

        case (SD_COUNTER)
            6'd0        : begin SDI =1; SCL = 1; SCL_CTRL =0; end

            ////////START///////////
            6'd1        :   SDI = 0;
            6'd2        :   SCL = 0;

            ////////I2C Adress. 8th bit is 0 for write, then 9th is tristate for ACK///////
            6'd3        :   begin SDI = I2CADDRESS[6]; I2CADDRESS = I2CADDRESS <<1; SCL_CTRL=1;  end
            6'd4        :   begin SDI = I2CADDRESS[6]; I2CADDRESS = I2CADDRESS <<1; end
            6'd5        :   begin SDI = I2CADDRESS[6]; I2CADDRESS = I2CADDRESS <<1; end
            6'd6        :   begin SDI = I2CADDRESS[6]; I2CADDRESS = I2CADDRESS <<1; end
            6'd7        :   begin SDI = I2CADDRESS[6]; I2CADDRESS = I2CADDRESS <<1; end
            6'd8        :   begin SDI = I2CADDRESS[6]; I2CADDRESS = I2CADDRESS <<1; end
            6'd9        :   begin SDI = I2CADDRESS[6]; I2CADDRESS = I2CADDRESS <<1; end
            6'd10       :   SDI = RW_DIR;
            6'd11       :   SDI = 1;

            /////////Memory Adress. Or reg adress for accel.///////////
            6'd12       :   begin SDI = REGADDRESS[7]; REGADDRESS = REGADDRESS << 1; end
            6'd13       :   begin SDI = REGADDRESS[7]; REGADDRESS = REGADDRESS << 1; end
            6'd14       :   begin SDI = REGADDRESS[7]; REGADDRESS = REGADDRESS << 1; end
            6'd15       :   begin SDI = REGADDRESS[7]; REGADDRESS = REGADDRESS << 1; end
            6'd16       :   begin SDI = REGADDRESS[7]; REGADDRESS = REGADDRESS << 1; end
            6'd17       :   begin SDI = REGADDRESS[7]; REGADDRESS = REGADDRESS << 1; end
            6'd18       :   begin SDI = REGADDRESS[7]; REGADDRESS = REGADDRESS << 1; end
            6'd19       :   begin SDI = REGADDRESS[7]; REGADDRESS = REGADDRESS << 1; end
            6'd20       :   SDI = 1;

            //////////Data to be writen to the adress////////////////
            6'd21       :   begin SDI = DATAOUT[7]; DATAOUT = DATAOUT << 1; end
            6'd22       :   begin SDI = DATAOUT[7]; DATAOUT = DATAOUT << 1; end
            6'd23       :   begin SDI = DATAOUT[7]; DATAOUT = DATAOUT << 1; end
            6'd24       :   begin SDI = DATAOUT[7]; DATAOUT = DATAOUT << 1; end
            6'd25       :   begin SDI = DATAOUT[7]; DATAOUT = DATAOUT << 1; end
            6'd26       :   begin SDI = DATAOUT[7]; DATAOUT = DATAOUT << 1; end
            6'd27       :   begin SDI = DATAOUT[7]; DATAOUT = DATAOUT << 1; end
            6'd28       :   begin SDI = DATAOUT[7]; DATAOUT = DATAOUT << 1; end
            6'd29       :   begin SDI = 1'bz;SCL_CTRL =0;end            //Switch to next state: SDI = 1'bz

            ////////////Stop////////////////
            6'd30       :   begin SDI = 0; SCL = 1;  end
            6'd31       :   SDI = 1; //bz
            6'd42       :   begin FLAGS = FLAGS +1;FIRSTPASS =0;end
        endcase
    end
    ///*********************************************************************
    //////This Section is supposed to Read... Hopefully. Edit: yup it now works  :) /////////////////////
    ///**********************************************************************
    else
    begin
        case (SD_COUNTER)
                6'd0        : begin SDI =1; SCL = 1; SCL_CTRL =0;end

                ////////START///////////
                6'd1        :   SDI = 0;
                6'd2        :   SCL = 0;

                ////////I2C Adress. Still need to write first///////
                6'd3        :   begin SDI = I2CADDRESS[6]; I2CADDRESS = I2CADDRESS <<1; SCL_CTRL=1;  end
                6'd4        :   begin SDI = I2CADDRESS[6]; I2CADDRESS = I2CADDRESS <<1; end
                6'd5        :   begin SDI = I2CADDRESS[6]; I2CADDRESS = I2CADDRESS <<1; end
                6'd6        :   begin SDI = I2CADDRESS[6]; I2CADDRESS = I2CADDRESS <<1; end
                6'd7        :   begin SDI = I2CADDRESS[6]; I2CADDRESS = I2CADDRESS <<1; end
                6'd8        :   begin SDI = I2CADDRESS[6]; I2CADDRESS = I2CADDRESS <<1; end
                6'd9        :   begin SDI = I2CADDRESS[6]; I2CADDRESS = I2CADDRESS <<1; end
                6'd10       :   SDI = RW_DIR;
                6'd11       :   SDI = 1;

                /////////Memory Adress///////////
                6'd12       :   begin SDI = REGADDRESS[7]; REGADDRESS = REGADDRESS << 1; end
                6'd13       :   begin SDI = REGADDRESS[7]; REGADDRESS = REGADDRESS << 1; end
                6'd14       :   begin SDI = REGADDRESS[7]; REGADDRESS = REGADDRESS << 1; end
                6'd15       :   begin SDI = REGADDRESS[7]; REGADDRESS = REGADDRESS << 1; end
                6'd16       :   begin SDI = REGADDRESS[7]; REGADDRESS = REGADDRESS << 1; end
                6'd17       :   begin SDI = REGADDRESS[7]; REGADDRESS = REGADDRESS << 1; end
                6'd18       :   begin SDI = REGADDRESS[7]; REGADDRESS = REGADDRESS << 1; end
                6'd19       :   begin SDI = REGADDRESS[7]; REGADDRESS = REGADDRESS << 1; end
                6'd20       :   begin SDI = 1; SCL =1'bz;I2CADDRESS = ACCEL_ADDR; RW_DIR = 1;end

                //////////Data////////////////
                6'd21       :   begin SDI =1; SCL = 1; end
                6'd22       :   begin SDI = 0; SCL_CTRL=0; end
                6'd23       :   SCL = 0;

                //////I2C Adress with read bit/////////
                6'd24       :   begin SDI = I2CADDRESS[6]; I2CADDRESS = I2CADDRESS <<1; SCL_CTRL=1;  end
                6'd25       :   begin SDI = I2CADDRESS[6]; I2CADDRESS = I2CADDRESS <<1; end
                6'd26       :   begin SDI = I2CADDRESS[6]; I2CADDRESS = I2CADDRESS <<1; end
                6'd27       :   begin SDI = I2CADDRESS[6]; I2CADDRESS = I2CADDRESS <<1; end
                6'd28       :   begin SDI = I2CADDRESS[6]; I2CADDRESS = I2CADDRESS <<1; end
                6'd29       :   begin SDI = I2CADDRESS[6]; I2CADDRESS = I2CADDRESS <<1; end
                6'd30       :   begin SDI = I2CADDRESS[6]; I2CADDRESS = I2CADDRESS <<1; end
                6'd31       :   SDI = RW_DIR;
                6'd32       :   SDI = 1;
                6'd33       :       ;

                /////First byte of data transfer from the slave.//////////
                6'd34       :   DATAIN[7] = I2C_SDA ;
                6'd35       :   DATAIN[6] = I2C_SDA ;
                6'd36       :   DATAIN[5] = I2C_SDA ;
                6'd37       :   DATAIN[4] = I2C_SDA ;
                6'd38       :   DATAIN[3] = I2C_SDA ;
                6'd39       :   DATAIN[2] = I2C_SDA ;
                6'd40       :   DATAIN[1] = I2C_SDA ;
                6'd41       :   begin DATAIN[0] = I2C_SDA ;SCL_CTRL =0;FIRSTPASS=0; end


                ////////////Stop////////////////
                6'd42       :   begin SDI = 0; SCL = 1; end
                6'd43       :   SDI = 1;
            endcase
    end

endmodule






