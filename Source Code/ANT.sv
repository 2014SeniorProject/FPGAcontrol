`define UCHAR unsigned char

`define MESG_TX_SYNC                      ((UCHAR)0xA4)
`define MESG_ASSIGN_CHANNEL_ID            ((UCHAR)0x42)
`define MESG_CHANNEL_MESG_PERIOD_ID       ((UCHAR)0x43)
`define MESG_CHANNEL_SEARCH_TIMEOUT_ID    ((UCHAR)0x44)
`define MESG_CHANNEL_RADIO_FREQ_ID        ((UCHAR)0x45)
`define MESG_NETWORK_KEY_ID               ((UCHAR)0x46)
`define MESG_SYSTEM_RESET_ID              ((UCHAR)0x4A)
`define MESG_OPEN_CHANNEL_ID              ((UCHAR)0x4B)
`define MESG_CHANNEL_ID_ID                ((UCHAR)0x51)

`define MESG_RESPONSE_EVENT_ID            ((UCHAR)0x40)
`define MESG_BROADCAST_DATA_ID            ((UCHAR)0x4E)
`define MESG_CAPABILITIES_ID              ((UCHAR)0x54)

// For Garmin HRM
`define ANT_CHAN           0
`define ANT_NET            0    // public network
`define ANT_TIMEOUT       12    // 12 * 2.5 = 30 seconds
`define ANT_DEVICETYPE   120    // bit 7 = 0 pairing requiest bits 6..0 = 120 for HRM
`define ANT_FREQ          57    // Garmin radio frequency
`define ANT_PERIOD      8070    // Garmin search period
`define ANT_NETWORKKEY {0xb9, 0xa5, 0x21, 0xfb, 0xbd, 0x72, 0xc3, 0x45}

// For Software Serial

`define ANT_CTS             12
`define ANT_TXD              8
`define ANT_RXD              7
`define ANT_BAUD          4800 // Baud for ANT chip

`define PACKETREADTIMEOUT  100
`define MAXPACKETLEN        80


module ANT(
    //| System inputs
    input             c50m,

    //| ANT+ Transmitter I/O Lines
    output  reg       ANTTEST,
    output  reg       ANTnRST,
    output  reg       ANTnSuspendControl,
    output  reg       ANTEnableSleepMode,
    output  reg       ANTPORTSEL,
    output  reg [3:0] ANTBR,
    output  reg       ANTTX,
    output  reg       ANTRX,
    output  reg       ANTReserved1,
    output  reg       ANTReserved2,
    output  reg       ANTRT
);

    //|
    //| Local reg/wire declarations
    //|--------------------------------------------
    reg     [6:0]   ClockDivider;
    wire            c100;

    //| UART module
    reg            transmit;
    reg    [7:0]   tx_byte;
    reg    [7:0]   rx_byte;
    reg            received;
    reg            is_receiving;
    reg            is_transmitting;

    reg     [3:0]  TransmitBytesLeft;

    reg     [7:0]  StateControl = 0;

    reg     [7:0]  transmitBuffer[10:0];

    reg     [7:0]  PacketChecksum;

    reg            ChecksumSent;

    //|
    //| Local reg/wire declarations
    //|--------------------------------------------
    assign c100 = ClockDivider[6];
    assign ANTBR = 3'b0;
    assign ANTTEST = 1'b0;
    assign ANTnRST = 1'b1;
    assign ANTnSuspendControl = 1'b1;
    assign ANTEnableSleepMode = 1'b0;
    assign ANTPORTSEL = 1'b0;
    assign ANTReserved1 = 1'b0;
    assign ANTReserved2 = 1'b0;

    //|
    //| Submodules
    //|--------------------------------------------
    uart #(
        .CLOCK_DIVIDE(2604)
    )ANTUARTModule(
        .clk(CLOCK_50),
        .rx(ANTRX),
        .tx(ANTTX),
        .transmit(transmit), // Signal to transmit
        .tx_byte(tx_byte), // Byte to transmit
        .received(received), // Indicated that a byte has been received.
        .rx_byte(rx_byte), // Byte received
        .is_receiving(is_receiving), // Low when receive line is idle.
        .is_transmitting(is_transmitting) // Low when transmit line is idle.
    );


    localparam InitializeReset = 0;

    //|
    //| StructualCoding
    //|--------------------------------------------
    always@(posedge received)
        begin
            //| 4 Bytes [sync][size][data][checksum]
        end

    always@(posedge c50m)
        begin
            case(StateControl)
                InitializeReset: if(SendPacket(3));
            endcase

        end
endmodule