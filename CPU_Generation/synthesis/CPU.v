// CPU.v

// Generated using ACDS version 13.1 173 at 2014.02.18.07:25:51

`timescale 1 ps / 1 ps
module CPU (
		input  wire        clk_clk,                //             clk.clk
		output wire [12:0] sdram_addr,             //           sdram.addr
		output wire [1:0]  sdram_ba,               //                .ba
		output wire        sdram_cas_n,            //                .cas_n
		output wire        sdram_cke,              //                .cke
		output wire        sdram_cs_n,             //                .cs_n
		inout  wire [15:0] sdram_dq,               //                .dq
		output wire [1:0]  sdram_dqm,              //                .dqm
		output wire        sdram_ras_n,            //                .ras_n
		output wire        sdram_we_n,             //                .we_n
		input  wire        antuart_rxd,            //         antuart.rxd
		output wire        antuart_txd,            //                .txd
		output wire [7:0]  heartrateoutput_export  // heartrateoutput.export
	);

	wire         nios2_qsys_0_jtag_debug_module_reset_reset;                   // nios2_qsys_0:jtag_debug_module_resetrequest -> [rst_controller:reset_in0, rst_controller:reset_in1]
	wire         nios2_qsys_0_data_master_waitrequest;                         // mm_interconnect_0:nios2_qsys_0_data_master_waitrequest -> nios2_qsys_0:d_waitrequest
	wire  [31:0] nios2_qsys_0_data_master_writedata;                           // nios2_qsys_0:d_writedata -> mm_interconnect_0:nios2_qsys_0_data_master_writedata
	wire  [26:0] nios2_qsys_0_data_master_address;                             // nios2_qsys_0:d_address -> mm_interconnect_0:nios2_qsys_0_data_master_address
	wire         nios2_qsys_0_data_master_write;                               // nios2_qsys_0:d_write -> mm_interconnect_0:nios2_qsys_0_data_master_write
	wire         nios2_qsys_0_data_master_read;                                // nios2_qsys_0:d_read -> mm_interconnect_0:nios2_qsys_0_data_master_read
	wire  [31:0] nios2_qsys_0_data_master_readdata;                            // mm_interconnect_0:nios2_qsys_0_data_master_readdata -> nios2_qsys_0:d_readdata
	wire         nios2_qsys_0_data_master_debugaccess;                         // nios2_qsys_0:jtag_debug_module_debugaccess_to_roms -> mm_interconnect_0:nios2_qsys_0_data_master_debugaccess
	wire   [3:0] nios2_qsys_0_data_master_byteenable;                          // nios2_qsys_0:d_byteenable -> mm_interconnect_0:nios2_qsys_0_data_master_byteenable
	wire         mm_interconnect_0_jtag_uart_avalon_jtag_slave_waitrequest;    // jtag_uart:av_waitrequest -> mm_interconnect_0:jtag_uart_avalon_jtag_slave_waitrequest
	wire  [31:0] mm_interconnect_0_jtag_uart_avalon_jtag_slave_writedata;      // mm_interconnect_0:jtag_uart_avalon_jtag_slave_writedata -> jtag_uart:av_writedata
	wire   [0:0] mm_interconnect_0_jtag_uart_avalon_jtag_slave_address;        // mm_interconnect_0:jtag_uart_avalon_jtag_slave_address -> jtag_uart:av_address
	wire         mm_interconnect_0_jtag_uart_avalon_jtag_slave_chipselect;     // mm_interconnect_0:jtag_uart_avalon_jtag_slave_chipselect -> jtag_uart:av_chipselect
	wire         mm_interconnect_0_jtag_uart_avalon_jtag_slave_write;          // mm_interconnect_0:jtag_uart_avalon_jtag_slave_write -> jtag_uart:av_write_n
	wire         mm_interconnect_0_jtag_uart_avalon_jtag_slave_read;           // mm_interconnect_0:jtag_uart_avalon_jtag_slave_read -> jtag_uart:av_read_n
	wire  [31:0] mm_interconnect_0_jtag_uart_avalon_jtag_slave_readdata;       // jtag_uart:av_readdata -> mm_interconnect_0:jtag_uart_avalon_jtag_slave_readdata
	wire         mm_interconnect_0_sdram_s1_waitrequest;                       // SDRAM:za_waitrequest -> mm_interconnect_0:SDRAM_s1_waitrequest
	wire  [15:0] mm_interconnect_0_sdram_s1_writedata;                         // mm_interconnect_0:SDRAM_s1_writedata -> SDRAM:az_data
	wire  [23:0] mm_interconnect_0_sdram_s1_address;                           // mm_interconnect_0:SDRAM_s1_address -> SDRAM:az_addr
	wire         mm_interconnect_0_sdram_s1_chipselect;                        // mm_interconnect_0:SDRAM_s1_chipselect -> SDRAM:az_cs
	wire         mm_interconnect_0_sdram_s1_write;                             // mm_interconnect_0:SDRAM_s1_write -> SDRAM:az_wr_n
	wire         mm_interconnect_0_sdram_s1_read;                              // mm_interconnect_0:SDRAM_s1_read -> SDRAM:az_rd_n
	wire  [15:0] mm_interconnect_0_sdram_s1_readdata;                          // SDRAM:za_data -> mm_interconnect_0:SDRAM_s1_readdata
	wire         mm_interconnect_0_sdram_s1_readdatavalid;                     // SDRAM:za_valid -> mm_interconnect_0:SDRAM_s1_readdatavalid
	wire   [1:0] mm_interconnect_0_sdram_s1_byteenable;                        // mm_interconnect_0:SDRAM_s1_byteenable -> SDRAM:az_be_n
	wire  [31:0] mm_interconnect_0_onchip_memory2_0_s1_writedata;              // mm_interconnect_0:onchip_memory2_0_s1_writedata -> onchip_memory2_0:writedata
	wire  [12:0] mm_interconnect_0_onchip_memory2_0_s1_address;                // mm_interconnect_0:onchip_memory2_0_s1_address -> onchip_memory2_0:address
	wire         mm_interconnect_0_onchip_memory2_0_s1_chipselect;             // mm_interconnect_0:onchip_memory2_0_s1_chipselect -> onchip_memory2_0:chipselect
	wire         mm_interconnect_0_onchip_memory2_0_s1_clken;                  // mm_interconnect_0:onchip_memory2_0_s1_clken -> onchip_memory2_0:clken
	wire         mm_interconnect_0_onchip_memory2_0_s1_write;                  // mm_interconnect_0:onchip_memory2_0_s1_write -> onchip_memory2_0:write
	wire  [31:0] mm_interconnect_0_onchip_memory2_0_s1_readdata;               // onchip_memory2_0:readdata -> mm_interconnect_0:onchip_memory2_0_s1_readdata
	wire   [3:0] mm_interconnect_0_onchip_memory2_0_s1_byteenable;             // mm_interconnect_0:onchip_memory2_0_s1_byteenable -> onchip_memory2_0:byteenable
	wire         mm_interconnect_0_nios2_qsys_0_jtag_debug_module_waitrequest; // nios2_qsys_0:jtag_debug_module_waitrequest -> mm_interconnect_0:nios2_qsys_0_jtag_debug_module_waitrequest
	wire  [31:0] mm_interconnect_0_nios2_qsys_0_jtag_debug_module_writedata;   // mm_interconnect_0:nios2_qsys_0_jtag_debug_module_writedata -> nios2_qsys_0:jtag_debug_module_writedata
	wire   [8:0] mm_interconnect_0_nios2_qsys_0_jtag_debug_module_address;     // mm_interconnect_0:nios2_qsys_0_jtag_debug_module_address -> nios2_qsys_0:jtag_debug_module_address
	wire         mm_interconnect_0_nios2_qsys_0_jtag_debug_module_write;       // mm_interconnect_0:nios2_qsys_0_jtag_debug_module_write -> nios2_qsys_0:jtag_debug_module_write
	wire         mm_interconnect_0_nios2_qsys_0_jtag_debug_module_read;        // mm_interconnect_0:nios2_qsys_0_jtag_debug_module_read -> nios2_qsys_0:jtag_debug_module_read
	wire  [31:0] mm_interconnect_0_nios2_qsys_0_jtag_debug_module_readdata;    // nios2_qsys_0:jtag_debug_module_readdata -> mm_interconnect_0:nios2_qsys_0_jtag_debug_module_readdata
	wire         mm_interconnect_0_nios2_qsys_0_jtag_debug_module_debugaccess; // mm_interconnect_0:nios2_qsys_0_jtag_debug_module_debugaccess -> nios2_qsys_0:jtag_debug_module_debugaccess
	wire   [3:0] mm_interconnect_0_nios2_qsys_0_jtag_debug_module_byteenable;  // mm_interconnect_0:nios2_qsys_0_jtag_debug_module_byteenable -> nios2_qsys_0:jtag_debug_module_byteenable
	wire  [31:0] mm_interconnect_0_heartrateout_s1_writedata;                  // mm_interconnect_0:HeartRateOut_s1_writedata -> HeartRateOut:writedata
	wire   [1:0] mm_interconnect_0_heartrateout_s1_address;                    // mm_interconnect_0:HeartRateOut_s1_address -> HeartRateOut:address
	wire         mm_interconnect_0_heartrateout_s1_chipselect;                 // mm_interconnect_0:HeartRateOut_s1_chipselect -> HeartRateOut:chipselect
	wire         mm_interconnect_0_heartrateout_s1_write;                      // mm_interconnect_0:HeartRateOut_s1_write -> HeartRateOut:write_n
	wire  [31:0] mm_interconnect_0_heartrateout_s1_readdata;                   // HeartRateOut:readdata -> mm_interconnect_0:HeartRateOut_s1_readdata
	wire  [15:0] mm_interconnect_0_uart_0_s1_writedata;                        // mm_interconnect_0:uart_0_s1_writedata -> uart_0:writedata
	wire   [2:0] mm_interconnect_0_uart_0_s1_address;                          // mm_interconnect_0:uart_0_s1_address -> uart_0:address
	wire         mm_interconnect_0_uart_0_s1_chipselect;                       // mm_interconnect_0:uart_0_s1_chipselect -> uart_0:chipselect
	wire         mm_interconnect_0_uart_0_s1_write;                            // mm_interconnect_0:uart_0_s1_write -> uart_0:write_n
	wire         mm_interconnect_0_uart_0_s1_read;                             // mm_interconnect_0:uart_0_s1_read -> uart_0:read_n
	wire  [15:0] mm_interconnect_0_uart_0_s1_readdata;                         // uart_0:readdata -> mm_interconnect_0:uart_0_s1_readdata
	wire         mm_interconnect_0_uart_0_s1_begintransfer;                    // mm_interconnect_0:uart_0_s1_begintransfer -> uart_0:begintransfer
	wire   [0:0] mm_interconnect_0_sysid_qsys_0_control_slave_address;         // mm_interconnect_0:sysid_qsys_0_control_slave_address -> sysid_qsys_0:address
	wire  [31:0] mm_interconnect_0_sysid_qsys_0_control_slave_readdata;        // sysid_qsys_0:readdata -> mm_interconnect_0:sysid_qsys_0_control_slave_readdata
	wire         nios2_qsys_0_instruction_master_waitrequest;                  // mm_interconnect_0:nios2_qsys_0_instruction_master_waitrequest -> nios2_qsys_0:i_waitrequest
	wire  [26:0] nios2_qsys_0_instruction_master_address;                      // nios2_qsys_0:i_address -> mm_interconnect_0:nios2_qsys_0_instruction_master_address
	wire         nios2_qsys_0_instruction_master_read;                         // nios2_qsys_0:i_read -> mm_interconnect_0:nios2_qsys_0_instruction_master_read
	wire  [31:0] nios2_qsys_0_instruction_master_readdata;                     // mm_interconnect_0:nios2_qsys_0_instruction_master_readdata -> nios2_qsys_0:i_readdata
	wire  [15:0] mm_interconnect_0_timer_0_s1_writedata;                       // mm_interconnect_0:timer_0_s1_writedata -> timer_0:writedata
	wire   [3:0] mm_interconnect_0_timer_0_s1_address;                         // mm_interconnect_0:timer_0_s1_address -> timer_0:address
	wire         mm_interconnect_0_timer_0_s1_chipselect;                      // mm_interconnect_0:timer_0_s1_chipselect -> timer_0:chipselect
	wire         mm_interconnect_0_timer_0_s1_write;                           // mm_interconnect_0:timer_0_s1_write -> timer_0:write_n
	wire  [15:0] mm_interconnect_0_timer_0_s1_readdata;                        // timer_0:readdata -> mm_interconnect_0:timer_0_s1_readdata
	wire         irq_mapper_receiver0_irq;                                     // jtag_uart:av_irq -> irq_mapper:receiver0_irq
	wire         irq_mapper_receiver1_irq;                                     // uart_0:irq -> irq_mapper:receiver1_irq
	wire         irq_mapper_receiver2_irq;                                     // timer_0:irq -> irq_mapper:receiver2_irq
	wire  [31:0] nios2_qsys_0_d_irq_irq;                                       // irq_mapper:sender_irq -> nios2_qsys_0:d_irq
	wire         rst_controller_reset_out_reset;                               // rst_controller:reset_out -> [HeartRateOut:reset_n, SDRAM:reset_n, irq_mapper:reset, jtag_uart:rst_n, mm_interconnect_0:nios2_qsys_0_reset_n_reset_bridge_in_reset_reset, nios2_qsys_0:reset_n, onchip_memory2_0:reset, rst_translator:in_reset, sysid_qsys_0:reset_n, timer_0:reset_n, uart_0:reset_n]
	wire         rst_controller_reset_out_reset_req;                           // rst_controller:reset_req -> [nios2_qsys_0:reset_req, onchip_memory2_0:reset_req, rst_translator:reset_req_in]

	CPU_nios2_qsys_0 nios2_qsys_0 (
		.clk                                   (clk_clk),                                                      //                       clk.clk
		.reset_n                               (~rst_controller_reset_out_reset),                              //                   reset_n.reset_n
		.reset_req                             (rst_controller_reset_out_reset_req),                           //                          .reset_req
		.d_address                             (nios2_qsys_0_data_master_address),                             //               data_master.address
		.d_byteenable                          (nios2_qsys_0_data_master_byteenable),                          //                          .byteenable
		.d_read                                (nios2_qsys_0_data_master_read),                                //                          .read
		.d_readdata                            (nios2_qsys_0_data_master_readdata),                            //                          .readdata
		.d_waitrequest                         (nios2_qsys_0_data_master_waitrequest),                         //                          .waitrequest
		.d_write                               (nios2_qsys_0_data_master_write),                               //                          .write
		.d_writedata                           (nios2_qsys_0_data_master_writedata),                           //                          .writedata
		.jtag_debug_module_debugaccess_to_roms (nios2_qsys_0_data_master_debugaccess),                         //                          .debugaccess
		.i_address                             (nios2_qsys_0_instruction_master_address),                      //        instruction_master.address
		.i_read                                (nios2_qsys_0_instruction_master_read),                         //                          .read
		.i_readdata                            (nios2_qsys_0_instruction_master_readdata),                     //                          .readdata
		.i_waitrequest                         (nios2_qsys_0_instruction_master_waitrequest),                  //                          .waitrequest
		.d_irq                                 (nios2_qsys_0_d_irq_irq),                                       //                     d_irq.irq
		.jtag_debug_module_resetrequest        (nios2_qsys_0_jtag_debug_module_reset_reset),                   //   jtag_debug_module_reset.reset
		.jtag_debug_module_address             (mm_interconnect_0_nios2_qsys_0_jtag_debug_module_address),     //         jtag_debug_module.address
		.jtag_debug_module_byteenable          (mm_interconnect_0_nios2_qsys_0_jtag_debug_module_byteenable),  //                          .byteenable
		.jtag_debug_module_debugaccess         (mm_interconnect_0_nios2_qsys_0_jtag_debug_module_debugaccess), //                          .debugaccess
		.jtag_debug_module_read                (mm_interconnect_0_nios2_qsys_0_jtag_debug_module_read),        //                          .read
		.jtag_debug_module_readdata            (mm_interconnect_0_nios2_qsys_0_jtag_debug_module_readdata),    //                          .readdata
		.jtag_debug_module_waitrequest         (mm_interconnect_0_nios2_qsys_0_jtag_debug_module_waitrequest), //                          .waitrequest
		.jtag_debug_module_write               (mm_interconnect_0_nios2_qsys_0_jtag_debug_module_write),       //                          .write
		.jtag_debug_module_writedata           (mm_interconnect_0_nios2_qsys_0_jtag_debug_module_writedata),   //                          .writedata
		.no_ci_readra                          ()                                                              // custom_instruction_master.readra
	);

	CPU_onchip_memory2_0 onchip_memory2_0 (
		.clk        (clk_clk),                                          //   clk1.clk
		.address    (mm_interconnect_0_onchip_memory2_0_s1_address),    //     s1.address
		.clken      (mm_interconnect_0_onchip_memory2_0_s1_clken),      //       .clken
		.chipselect (mm_interconnect_0_onchip_memory2_0_s1_chipselect), //       .chipselect
		.write      (mm_interconnect_0_onchip_memory2_0_s1_write),      //       .write
		.readdata   (mm_interconnect_0_onchip_memory2_0_s1_readdata),   //       .readdata
		.writedata  (mm_interconnect_0_onchip_memory2_0_s1_writedata),  //       .writedata
		.byteenable (mm_interconnect_0_onchip_memory2_0_s1_byteenable), //       .byteenable
		.reset      (rst_controller_reset_out_reset),                   // reset1.reset
		.reset_req  (rst_controller_reset_out_reset_req)                //       .reset_req
	);

	CPU_jtag_uart jtag_uart (
		.clk            (clk_clk),                                                   //               clk.clk
		.rst_n          (~rst_controller_reset_out_reset),                           //             reset.reset_n
		.av_chipselect  (mm_interconnect_0_jtag_uart_avalon_jtag_slave_chipselect),  // avalon_jtag_slave.chipselect
		.av_address     (mm_interconnect_0_jtag_uart_avalon_jtag_slave_address),     //                  .address
		.av_read_n      (~mm_interconnect_0_jtag_uart_avalon_jtag_slave_read),       //                  .read_n
		.av_readdata    (mm_interconnect_0_jtag_uart_avalon_jtag_slave_readdata),    //                  .readdata
		.av_write_n     (~mm_interconnect_0_jtag_uart_avalon_jtag_slave_write),      //                  .write_n
		.av_writedata   (mm_interconnect_0_jtag_uart_avalon_jtag_slave_writedata),   //                  .writedata
		.av_waitrequest (mm_interconnect_0_jtag_uart_avalon_jtag_slave_waitrequest), //                  .waitrequest
		.av_irq         (irq_mapper_receiver0_irq)                                   //               irq.irq
	);

	CPU_SDRAM sdram (
		.clk            (clk_clk),                                  //   clk.clk
		.reset_n        (~rst_controller_reset_out_reset),          // reset.reset_n
		.az_addr        (mm_interconnect_0_sdram_s1_address),       //    s1.address
		.az_be_n        (~mm_interconnect_0_sdram_s1_byteenable),   //      .byteenable_n
		.az_cs          (mm_interconnect_0_sdram_s1_chipselect),    //      .chipselect
		.az_data        (mm_interconnect_0_sdram_s1_writedata),     //      .writedata
		.az_rd_n        (~mm_interconnect_0_sdram_s1_read),         //      .read_n
		.az_wr_n        (~mm_interconnect_0_sdram_s1_write),        //      .write_n
		.za_data        (mm_interconnect_0_sdram_s1_readdata),      //      .readdata
		.za_valid       (mm_interconnect_0_sdram_s1_readdatavalid), //      .readdatavalid
		.za_waitrequest (mm_interconnect_0_sdram_s1_waitrequest),   //      .waitrequest
		.zs_addr        (sdram_addr),                               //  wire.export
		.zs_ba          (sdram_ba),                                 //      .export
		.zs_cas_n       (sdram_cas_n),                              //      .export
		.zs_cke         (sdram_cke),                                //      .export
		.zs_cs_n        (sdram_cs_n),                               //      .export
		.zs_dq          (sdram_dq),                                 //      .export
		.zs_dqm         (sdram_dqm),                                //      .export
		.zs_ras_n       (sdram_ras_n),                              //      .export
		.zs_we_n        (sdram_we_n)                                //      .export
	);

	CPU_uart_0 uart_0 (
		.clk           (clk_clk),                                   //                 clk.clk
		.reset_n       (~rst_controller_reset_out_reset),           //               reset.reset_n
		.address       (mm_interconnect_0_uart_0_s1_address),       //                  s1.address
		.begintransfer (mm_interconnect_0_uart_0_s1_begintransfer), //                    .begintransfer
		.chipselect    (mm_interconnect_0_uart_0_s1_chipselect),    //                    .chipselect
		.read_n        (~mm_interconnect_0_uart_0_s1_read),         //                    .read_n
		.write_n       (~mm_interconnect_0_uart_0_s1_write),        //                    .write_n
		.writedata     (mm_interconnect_0_uart_0_s1_writedata),     //                    .writedata
		.readdata      (mm_interconnect_0_uart_0_s1_readdata),      //                    .readdata
		.dataavailable (),                                          //                    .dataavailable
		.readyfordata  (),                                          //                    .readyfordata
		.rxd           (antuart_rxd),                               // external_connection.export
		.txd           (antuart_txd),                               //                    .export
		.irq           (irq_mapper_receiver1_irq)                   //                 irq.irq
	);

	CPU_timer_0 timer_0 (
		.clk        (clk_clk),                                 //   clk.clk
		.reset_n    (~rst_controller_reset_out_reset),         // reset.reset_n
		.address    (mm_interconnect_0_timer_0_s1_address),    //    s1.address
		.writedata  (mm_interconnect_0_timer_0_s1_writedata),  //      .writedata
		.readdata   (mm_interconnect_0_timer_0_s1_readdata),   //      .readdata
		.chipselect (mm_interconnect_0_timer_0_s1_chipselect), //      .chipselect
		.write_n    (~mm_interconnect_0_timer_0_s1_write),     //      .write_n
		.irq        (irq_mapper_receiver2_irq)                 //   irq.irq
	);

	CPU_sysid_qsys_0 sysid_qsys_0 (
		.clock    (clk_clk),                                               //           clk.clk
		.reset_n  (~rst_controller_reset_out_reset),                       //         reset.reset_n
		.readdata (mm_interconnect_0_sysid_qsys_0_control_slave_readdata), // control_slave.readdata
		.address  (mm_interconnect_0_sysid_qsys_0_control_slave_address)   //              .address
	);

	CPU_HeartRateOut heartrateout (
		.clk        (clk_clk),                                      //                 clk.clk
		.reset_n    (~rst_controller_reset_out_reset),              //               reset.reset_n
		.address    (mm_interconnect_0_heartrateout_s1_address),    //                  s1.address
		.write_n    (~mm_interconnect_0_heartrateout_s1_write),     //                    .write_n
		.writedata  (mm_interconnect_0_heartrateout_s1_writedata),  //                    .writedata
		.chipselect (mm_interconnect_0_heartrateout_s1_chipselect), //                    .chipselect
		.readdata   (mm_interconnect_0_heartrateout_s1_readdata),   //                    .readdata
		.out_port   (heartrateoutput_export)                        // external_connection.export
	);

	CPU_mm_interconnect_0 mm_interconnect_0 (
		.clk_0_clk_clk                                    (clk_clk),                                                      //                                  clk_0_clk.clk
		.nios2_qsys_0_reset_n_reset_bridge_in_reset_reset (rst_controller_reset_out_reset),                               // nios2_qsys_0_reset_n_reset_bridge_in_reset.reset
		.nios2_qsys_0_data_master_address                 (nios2_qsys_0_data_master_address),                             //                   nios2_qsys_0_data_master.address
		.nios2_qsys_0_data_master_waitrequest             (nios2_qsys_0_data_master_waitrequest),                         //                                           .waitrequest
		.nios2_qsys_0_data_master_byteenable              (nios2_qsys_0_data_master_byteenable),                          //                                           .byteenable
		.nios2_qsys_0_data_master_read                    (nios2_qsys_0_data_master_read),                                //                                           .read
		.nios2_qsys_0_data_master_readdata                (nios2_qsys_0_data_master_readdata),                            //                                           .readdata
		.nios2_qsys_0_data_master_write                   (nios2_qsys_0_data_master_write),                               //                                           .write
		.nios2_qsys_0_data_master_writedata               (nios2_qsys_0_data_master_writedata),                           //                                           .writedata
		.nios2_qsys_0_data_master_debugaccess             (nios2_qsys_0_data_master_debugaccess),                         //                                           .debugaccess
		.nios2_qsys_0_instruction_master_address          (nios2_qsys_0_instruction_master_address),                      //            nios2_qsys_0_instruction_master.address
		.nios2_qsys_0_instruction_master_waitrequest      (nios2_qsys_0_instruction_master_waitrequest),                  //                                           .waitrequest
		.nios2_qsys_0_instruction_master_read             (nios2_qsys_0_instruction_master_read),                         //                                           .read
		.nios2_qsys_0_instruction_master_readdata         (nios2_qsys_0_instruction_master_readdata),                     //                                           .readdata
		.HeartRateOut_s1_address                          (mm_interconnect_0_heartrateout_s1_address),                    //                            HeartRateOut_s1.address
		.HeartRateOut_s1_write                            (mm_interconnect_0_heartrateout_s1_write),                      //                                           .write
		.HeartRateOut_s1_readdata                         (mm_interconnect_0_heartrateout_s1_readdata),                   //                                           .readdata
		.HeartRateOut_s1_writedata                        (mm_interconnect_0_heartrateout_s1_writedata),                  //                                           .writedata
		.HeartRateOut_s1_chipselect                       (mm_interconnect_0_heartrateout_s1_chipselect),                 //                                           .chipselect
		.jtag_uart_avalon_jtag_slave_address              (mm_interconnect_0_jtag_uart_avalon_jtag_slave_address),        //                jtag_uart_avalon_jtag_slave.address
		.jtag_uart_avalon_jtag_slave_write                (mm_interconnect_0_jtag_uart_avalon_jtag_slave_write),          //                                           .write
		.jtag_uart_avalon_jtag_slave_read                 (mm_interconnect_0_jtag_uart_avalon_jtag_slave_read),           //                                           .read
		.jtag_uart_avalon_jtag_slave_readdata             (mm_interconnect_0_jtag_uart_avalon_jtag_slave_readdata),       //                                           .readdata
		.jtag_uart_avalon_jtag_slave_writedata            (mm_interconnect_0_jtag_uart_avalon_jtag_slave_writedata),      //                                           .writedata
		.jtag_uart_avalon_jtag_slave_waitrequest          (mm_interconnect_0_jtag_uart_avalon_jtag_slave_waitrequest),    //                                           .waitrequest
		.jtag_uart_avalon_jtag_slave_chipselect           (mm_interconnect_0_jtag_uart_avalon_jtag_slave_chipselect),     //                                           .chipselect
		.nios2_qsys_0_jtag_debug_module_address           (mm_interconnect_0_nios2_qsys_0_jtag_debug_module_address),     //             nios2_qsys_0_jtag_debug_module.address
		.nios2_qsys_0_jtag_debug_module_write             (mm_interconnect_0_nios2_qsys_0_jtag_debug_module_write),       //                                           .write
		.nios2_qsys_0_jtag_debug_module_read              (mm_interconnect_0_nios2_qsys_0_jtag_debug_module_read),        //                                           .read
		.nios2_qsys_0_jtag_debug_module_readdata          (mm_interconnect_0_nios2_qsys_0_jtag_debug_module_readdata),    //                                           .readdata
		.nios2_qsys_0_jtag_debug_module_writedata         (mm_interconnect_0_nios2_qsys_0_jtag_debug_module_writedata),   //                                           .writedata
		.nios2_qsys_0_jtag_debug_module_byteenable        (mm_interconnect_0_nios2_qsys_0_jtag_debug_module_byteenable),  //                                           .byteenable
		.nios2_qsys_0_jtag_debug_module_waitrequest       (mm_interconnect_0_nios2_qsys_0_jtag_debug_module_waitrequest), //                                           .waitrequest
		.nios2_qsys_0_jtag_debug_module_debugaccess       (mm_interconnect_0_nios2_qsys_0_jtag_debug_module_debugaccess), //                                           .debugaccess
		.onchip_memory2_0_s1_address                      (mm_interconnect_0_onchip_memory2_0_s1_address),                //                        onchip_memory2_0_s1.address
		.onchip_memory2_0_s1_write                        (mm_interconnect_0_onchip_memory2_0_s1_write),                  //                                           .write
		.onchip_memory2_0_s1_readdata                     (mm_interconnect_0_onchip_memory2_0_s1_readdata),               //                                           .readdata
		.onchip_memory2_0_s1_writedata                    (mm_interconnect_0_onchip_memory2_0_s1_writedata),              //                                           .writedata
		.onchip_memory2_0_s1_byteenable                   (mm_interconnect_0_onchip_memory2_0_s1_byteenable),             //                                           .byteenable
		.onchip_memory2_0_s1_chipselect                   (mm_interconnect_0_onchip_memory2_0_s1_chipselect),             //                                           .chipselect
		.onchip_memory2_0_s1_clken                        (mm_interconnect_0_onchip_memory2_0_s1_clken),                  //                                           .clken
		.SDRAM_s1_address                                 (mm_interconnect_0_sdram_s1_address),                           //                                   SDRAM_s1.address
		.SDRAM_s1_write                                   (mm_interconnect_0_sdram_s1_write),                             //                                           .write
		.SDRAM_s1_read                                    (mm_interconnect_0_sdram_s1_read),                              //                                           .read
		.SDRAM_s1_readdata                                (mm_interconnect_0_sdram_s1_readdata),                          //                                           .readdata
		.SDRAM_s1_writedata                               (mm_interconnect_0_sdram_s1_writedata),                         //                                           .writedata
		.SDRAM_s1_byteenable                              (mm_interconnect_0_sdram_s1_byteenable),                        //                                           .byteenable
		.SDRAM_s1_readdatavalid                           (mm_interconnect_0_sdram_s1_readdatavalid),                     //                                           .readdatavalid
		.SDRAM_s1_waitrequest                             (mm_interconnect_0_sdram_s1_waitrequest),                       //                                           .waitrequest
		.SDRAM_s1_chipselect                              (mm_interconnect_0_sdram_s1_chipselect),                        //                                           .chipselect
		.sysid_qsys_0_control_slave_address               (mm_interconnect_0_sysid_qsys_0_control_slave_address),         //                 sysid_qsys_0_control_slave.address
		.sysid_qsys_0_control_slave_readdata              (mm_interconnect_0_sysid_qsys_0_control_slave_readdata),        //                                           .readdata
		.timer_0_s1_address                               (mm_interconnect_0_timer_0_s1_address),                         //                                 timer_0_s1.address
		.timer_0_s1_write                                 (mm_interconnect_0_timer_0_s1_write),                           //                                           .write
		.timer_0_s1_readdata                              (mm_interconnect_0_timer_0_s1_readdata),                        //                                           .readdata
		.timer_0_s1_writedata                             (mm_interconnect_0_timer_0_s1_writedata),                       //                                           .writedata
		.timer_0_s1_chipselect                            (mm_interconnect_0_timer_0_s1_chipselect),                      //                                           .chipselect
		.uart_0_s1_address                                (mm_interconnect_0_uart_0_s1_address),                          //                                  uart_0_s1.address
		.uart_0_s1_write                                  (mm_interconnect_0_uart_0_s1_write),                            //                                           .write
		.uart_0_s1_read                                   (mm_interconnect_0_uart_0_s1_read),                             //                                           .read
		.uart_0_s1_readdata                               (mm_interconnect_0_uart_0_s1_readdata),                         //                                           .readdata
		.uart_0_s1_writedata                              (mm_interconnect_0_uart_0_s1_writedata),                        //                                           .writedata
		.uart_0_s1_begintransfer                          (mm_interconnect_0_uart_0_s1_begintransfer),                    //                                           .begintransfer
		.uart_0_s1_chipselect                             (mm_interconnect_0_uart_0_s1_chipselect)                        //                                           .chipselect
	);

	CPU_irq_mapper irq_mapper (
		.clk           (clk_clk),                        //       clk.clk
		.reset         (rst_controller_reset_out_reset), // clk_reset.reset
		.receiver0_irq (irq_mapper_receiver0_irq),       // receiver0.irq
		.receiver1_irq (irq_mapper_receiver1_irq),       // receiver1.irq
		.receiver2_irq (irq_mapper_receiver2_irq),       // receiver2.irq
		.sender_irq    (nios2_qsys_0_d_irq_irq)          //    sender.irq
	);

	altera_reset_controller #(
		.NUM_RESET_INPUTS          (2),
		.OUTPUT_RESET_SYNC_EDGES   ("deassert"),
		.SYNC_DEPTH                (2),
		.RESET_REQUEST_PRESENT     (1),
		.RESET_REQ_WAIT_TIME       (1),
		.MIN_RST_ASSERTION_TIME    (3),
		.RESET_REQ_EARLY_DSRT_TIME (1),
		.USE_RESET_REQUEST_IN0     (0),
		.USE_RESET_REQUEST_IN1     (0),
		.USE_RESET_REQUEST_IN2     (0),
		.USE_RESET_REQUEST_IN3     (0),
		.USE_RESET_REQUEST_IN4     (0),
		.USE_RESET_REQUEST_IN5     (0),
		.USE_RESET_REQUEST_IN6     (0),
		.USE_RESET_REQUEST_IN7     (0),
		.USE_RESET_REQUEST_IN8     (0),
		.USE_RESET_REQUEST_IN9     (0),
		.USE_RESET_REQUEST_IN10    (0),
		.USE_RESET_REQUEST_IN11    (0),
		.USE_RESET_REQUEST_IN12    (0),
		.USE_RESET_REQUEST_IN13    (0),
		.USE_RESET_REQUEST_IN14    (0),
		.USE_RESET_REQUEST_IN15    (0),
		.ADAPT_RESET_REQUEST       (0)
	) rst_controller (
		.reset_in0      (nios2_qsys_0_jtag_debug_module_reset_reset), // reset_in0.reset
		.reset_in1      (nios2_qsys_0_jtag_debug_module_reset_reset), // reset_in1.reset
		.clk            (clk_clk),                                    //       clk.clk
		.reset_out      (rst_controller_reset_out_reset),             // reset_out.reset
		.reset_req      (rst_controller_reset_out_reset_req),         //          .reset_req
		.reset_req_in0  (1'b0),                                       // (terminated)
		.reset_req_in1  (1'b0),                                       // (terminated)
		.reset_in2      (1'b0),                                       // (terminated)
		.reset_req_in2  (1'b0),                                       // (terminated)
		.reset_in3      (1'b0),                                       // (terminated)
		.reset_req_in3  (1'b0),                                       // (terminated)
		.reset_in4      (1'b0),                                       // (terminated)
		.reset_req_in4  (1'b0),                                       // (terminated)
		.reset_in5      (1'b0),                                       // (terminated)
		.reset_req_in5  (1'b0),                                       // (terminated)
		.reset_in6      (1'b0),                                       // (terminated)
		.reset_req_in6  (1'b0),                                       // (terminated)
		.reset_in7      (1'b0),                                       // (terminated)
		.reset_req_in7  (1'b0),                                       // (terminated)
		.reset_in8      (1'b0),                                       // (terminated)
		.reset_req_in8  (1'b0),                                       // (terminated)
		.reset_in9      (1'b0),                                       // (terminated)
		.reset_req_in9  (1'b0),                                       // (terminated)
		.reset_in10     (1'b0),                                       // (terminated)
		.reset_req_in10 (1'b0),                                       // (terminated)
		.reset_in11     (1'b0),                                       // (terminated)
		.reset_req_in11 (1'b0),                                       // (terminated)
		.reset_in12     (1'b0),                                       // (terminated)
		.reset_req_in12 (1'b0),                                       // (terminated)
		.reset_in13     (1'b0),                                       // (terminated)
		.reset_req_in13 (1'b0),                                       // (terminated)
		.reset_in14     (1'b0),                                       // (terminated)
		.reset_req_in14 (1'b0),                                       // (terminated)
		.reset_in15     (1'b0),                                       // (terminated)
		.reset_req_in15 (1'b0)                                        // (terminated)
	);

endmodule
