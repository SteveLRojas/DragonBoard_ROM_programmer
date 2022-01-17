//                     /\         /\__
//                   // \       (  0 )_____/\            __
//                  // \ \     (vv          o|          /^v\
//                //    \ \   (vvvv  ___-----^        /^^/\vv\
//              //  /     \ \ |vvvvv/               /^^/    \v\
//             //  /       (\\/vvvv/              /^^/       \v\
//            //  /  /  \ (  /vvvv/              /^^/---(     \v\
//           //  /  /    \( /vvvv/----(O        /^^/           \v\
//          //  /  /  \  (/vvvv/               /^^/             \v|
//        //  /  /    \( vvvv/                /^^/               ||
//       //  /  /    (  vvvv/                 |^^|              //
//      //  / /    (  |vvvv|                  /^^/            //
//     //  / /   (    \vvvvv\          )-----/^^/           //
//    // / / (          \vvvvv\            /^^^/          //
//   /// /(               \vvvvv\        /^^^^/          //
//  ///(              )-----\vvvvv\    /^^^^/-----(      \\
// //(                        \vvvvv\/^^^^/               \\
///(                            \vvvv^^^/                 //
//                                \vv^/         /        //
//                                             /<______//
//                                            <<<------/
//                                             \<
//                                              \
//***************************************************
//* Programmer tool for I2C EEPROMs.                *
//* Copyright (C) 2022 Esteban Looser-Rojas.        *
//* This is a subset of the RIPTIDE-III validation  *
//* platform. Only RS-232, I2C, timer, interrupt    *
//* controller, and CPU modules are used.           *
//***************************************************
module R3_programmer(
		input wire reset,
		input wire clk,
		input wire[3:0] button,
		output wire[3:0] LED,
		
		input wire RXD,
		output wire TXD,
		
		inout wire i2c_sda,
		inout wire i2c_scl
		);

//Address map for left bank:
// 0x0000 to 0x0FFF	unused
// 0x1000 to 0xFFEB	unused
// 0xFFEC to 0xFFED	I2C module (read write)
// 0xFFEE to 0xFFEF	interrupt controller (read write)
// 0xFFF0 to 0xFFF3	timer module
// 0xFFF4 to 0xFFF5	unused
// 0xFFF6 to 0xFFF7	unused
// 0xFFF8 to 0xFFFB	unused
// 0xFFFC to 0xFFFD	unused
// 0xFFFE to 0xFFFF	RS-232 module	(read write)

//Address map for right bank:
// 0x0000 to 0x1FFF	8KB RAM
// 0x2000 to 0xFFFF	unused

//Address map for program space:
// 0x0000 to 0x0FFF	8KB ROM
// 0x1000 to 0xFFFF	unused

// RS-232 module address map
// 0 data register
// 1 status register
//		bit 0: TX overwrite
//		bit 1: RX overwrite
//		bit 2: TX ready
//		bit 3: RX ready
//		bit 4: TX queue empty
//		bit 5: RX queue full

// Timer module address map
// 0 counter bits 7:0
// 1 counter bits 15:8
// 2 counter bits 23:16
// 3 status
//		bit 0: counter 7:0 not zero
//		bit 1: counter 15:8 not zero
//		bit 2: counter 23:16 not zero
//		bit 3: counter 23:0 not zero
//		bit 4: VSYNC
//		bit 5: HSYNC

// I2C module address map
// 0 data register
// 1 status and control register
//		bit 0: START
//		bit 1: STOP
//		bit 2: READ_REQ
//		bit 3: WRITE_REQ
//		bit 4: MASTER_ACK
//		bit 5: SLAVE_ACK
//		bit 6: READY

//####### PLL #################################################################
wire clk_sys;
PLL0 PLL_inst(.inclk0(clk), .c0(clk_sys));
//#############################################################################

//####### IO Control #########################################################
wire[15:0] data_address;
wire[7:0] from_CPU_left;
wire[7:0] to_CPU_left;
wire IO_WC;
wire IO_RC;
wire IO_n_LB_w;
wire IO_n_LB_r;
wire IO_wren;
wire IO_ren;
assign IO_wren = (~IO_n_LB_w & IO_WC);
assign IO_ren = (~IO_n_LB_r & IO_RC);

reg[3:0] button_s;
reg rst;
reg[3:0] led_q;

always @(posedge clk_sys)
begin
	button_s <= ~button;
	rst <= ~reset;
	led_q <= {i2c_scl, i2c_sda, RXD, TXD};
end

assign LED = led_q;
//#############################################################################

//####### Program ROM #########################################################
wire[15:0] PRG_address;
wire[15:0] PRG_data;

program_rom rom_inst(
		.address(PRG_address[11:0]),
		.clock(clk_sys),
		.q(PRG_data));
//#############################################################################

//####### Data RAM ############################################################
wire[7:0] to_CPU_right;
wire[7:0] from_CPU_right;

data_ram ram_inst(
		.address(data_address[12:0]),
		.clock(clk_sys),
		.data(from_CPU_right),
		.wren(IO_WC & IO_n_LB_w),
		.q(to_CPU_right));
//#############################################################################

//####### I2C Module ##########################################################
wire i2c_en;
wire[7:0] from_i2c;
wire i2c_int;
assign i2c_en = (&data_address[15:5] & ~data_address[4] & (&data_address[3:2]) & ~data_address[1]);	//0xFFEC - 0xFFED

I2C_ri i2c_ri_inst(
		.clk(clk_sys),
		.reset(rst),
		.a(data_address[0]),
		.ce(i2c_en),
		.wren(IO_wren),
		.ren(IO_ren),
		.i2c_int(i2c_int),
		.to_CPU(from_i2c),
		.from_CPU(from_CPU_left),
		.i2c_sda(i2c_sda),
		.i2c_scl(i2c_scl));
//#############################################################################

//####### Serial Module #######################################################
wire serial_en;
wire[7:0] from_serial;
wire uart_rx_int;
wire uart_tx_int;
assign serial_en = &data_address[15:1];	//0xFFFE - 0xFFFF

serial serial_inst(
		.clk(clk_sys),
		.reset(rst),
		.A(data_address[0]),
		.CE(serial_en),
		.WREN(IO_wren),
		.REN(IO_ren),
		.rx(RXD),
		.tx(TXD),
		.rx_int(uart_rx_int),
		.tx_int(uart_tx_int),
		.to_CPU(from_serial),
		.from_CPU(from_CPU_left));
//#############################################################################

//####### Timer Module ########################################################
wire timer_en;
wire[7:0] from_timer;
wire timer_int;
assign timer_en = (&data_address[15:4]) & ~data_address[3] & ~data_address[2];

timer timer_inst(
		.clk(clk_sys),
		.rst(rst),
		.ce(timer_en),
		.wren(IO_wren),
		.ren(IO_ren),
		.hsync(1'b1),
		.vsync(1'b1),
		.timer_int(timer_int),
		.addr(data_address[1:0]),
		.from_cpu(from_CPU_left),
		.to_cpu(from_timer));
//#############################################################################

//####### Interrupt Controller ################################################
wire intcon_en;
wire[7:0] from_intcon;
wire int_rq;
wire[2:0] int_addr;
assign intcon_en = (&data_address[15:5]) & ~data_address[4] & (&data_address[3:1]);

interrupt_controller intcon_inst(
		.clk(clk_sys),
		.rst(rst),
		.ce(intcon_en),
		.wren(IO_wren),
		.in0(button_s[1]), .in1(button_s[2]), .in2(button_s[3]), .in3(uart_rx_int), .in4(uart_tx_int), .in5(1'b0), .in6(timer_int), .in7(i2c_int),
		.ri_addr(data_address[0]),
		.from_cpu(from_CPU_left),
		.to_cpu(from_intcon),
		.int_addr(int_addr),
		.int_rq(int_rq));
//#############################################################################

//####### IO Multiplexer ######################################################
reg prev_serial_en;
reg prev_timer_en;
reg prev_intcon_en;
reg prev_i2c_en;

always @(posedge clk_sys)
begin
	prev_serial_en <= serial_en;
	prev_timer_en <= timer_en;
	prev_intcon_en <= intcon_en;
	prev_i2c_en <= i2c_en;
end

wire[7:0] m_from_serial;
wire[7:0] m_from_timer;
wire[7:0] m_from_intcon;
wire[7:0] m_from_i2c;

assign m_from_serial = from_serial & {8{prev_serial_en}};
assign m_from_timer = from_timer & {8{prev_timer_en}};
assign m_from_intcon = from_intcon & {8{prev_intcon_en}};
assign m_from_i2c = from_i2c & {8{prev_i2c_en}};
assign to_CPU_left = m_from_serial | m_from_timer | m_from_intcon | m_from_i2c;
//#############################################################################

//####### CPU Core ############################################################
RIPTIDE_III CPU_inst(
		.clk(clk_sys),
		.n_halt(~button_s[0]),
		.p_cache_miss(1'b0),
		.d_cache_miss(1'b0),
		.n_reset(~rst),
		.int_rq(int_rq),
		.int_addr(int_addr),
		.I(PRG_data),
		.A(PRG_address),
		.address(data_address),
		.data_out({from_CPU_left, from_CPU_right}),
		.data_in({to_CPU_left, to_CPU_right}),
		.IO_WC(IO_WC),
		.IO_RC(IO_RC),
		.IO_n_LB_w(IO_n_LB_w),
		.IO_n_LB_r(IO_n_LB_r));
//#############################################################################
endmodule
