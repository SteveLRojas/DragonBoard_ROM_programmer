`timescale 10ns/1ns
module Testbench();

//External signals
reg clk;
reg n_reset;
reg[3:0] button;
wire[3:0] LED;
reg RXD;
wire TXD;
wire sdram_clk;
wire sdram_cke;
wire sdram_cs_n;
wire sdram_wre_n;
wire sdram_cas_n;
wire sdram_ras_n;
wire[11:0] sdram_a;
wire[1:0] sdram_ba;
wire[1:0] sdram_dqm;
wire[15:0] sdram_dq;
//wire R, G, B;
wire HSYNC, VSYNC;

//platform internal signals
wire[11:0] init_address;
wire[7:0] hex_low;
wire[7:0] hex_high;
wire[5:0] p1_page;
wire[6:0] p2_page;

//interrupt controller external signals
wire intcon_en;
wire[7:0] from_intcon;
wire int_rq;
wire[2:0] int_addr;

//interrupt controller internal signals
wire[7:0] in;
wire[7:0] prev_in;
wire[7:0] control;
wire[7:0] status;
wire[7:0] trig;
wire[7:0] interrupt;

//CPU external signals
wire[15:0] PRG_address;
wire[15:0] PRG_data;
wire[15:0] CPU_data_address;
wire[15:0] CPU_data_in;
wire[15:0] CPU_data_out;
wire IO_WC;
wire IO_RC;
wire IO_n_LB_w;
wire IO_n_LB_r;

//CPU internal signals
wire IO_SC;
//wire[15:0] data_address;
//wire[15:0] data_address_hold;
wire[15:0] I_reg;
//wire[15:0] I_alternate;
wire[3:0] REGF_A_ADDRESS;
wire[3:0] REGF_W_ADDRESS;
wire REGF_WREN;
wire[7:0] REGF_W_DATA;
wire[7:0] REGF_A_DATA;
wire[7:0] REGF_AUX_DATA;
wire NZT;
wire XEC;
wire JMP;
wire CALL;
wire CALL2;
wire RET;
wire hazard;
//wire aux_hazard;
wire latch_hazard;
wire regf_hazard;
wire IO_hazard;
wire pipeline_flush;
wire decoder_RST;
//wire[7:0] amux_out;
wire[7:0] alu_out;
wire OVF;
//wire[2:0] shift_L4;
//wire[2:0] merge_D05;
//wire[2:0] stack_addr;
wire[15:0] A_pipe0;
wire[15:0] A_pipe1;
wire[15:0] A_pipe2;
//wire[15:0] A_pipe3;

//cache controller signals
wire p_cache_miss;
wire d_cache_miss;
wire p1_req;
wire p1_ready;
wire p2_req;
wire p2_ready;
wire[13:0] p1_address;
wire[12:0] p2_address;
wire[63:0] p1_data;
wire[63:0] p2_from_mem;
wire[63:0] p2_to_mem;
wire p1_reset;
wire p2_reset;
wire p2_flush;
wire p2_wren;

R3_PVP PVP_inst(
		.reset(n_reset),
		.clk(clk),
		.button(button[3:0]),
		.RXD(RXD),
		.TXD(TXD),
		.ps2_clk_d(1'b1),
		.ps2_data_d(1'b1),
		.ps2_clk_q(),
		.ps2_data_q(),
		.LED(LED[3:0]),
		.sdram_clk(sdram_clk),
		.sdram_cke(sdram_cke),
		.sdram_cs_n(sdram_cs_n),
		.sdram_wre_n(sdram_wre_n),
		.sdram_cas_n(sdram_cas_n),
		.sdram_ras_n(sdram_ras_n),
		.sdram_a(sdram_a),
		.sdram_ba(sdram_ba),
		.sdram_dqm(sdram_dqm),
		.sdram_dq(sdram_dq),
		//.R(R), .G(G), .B(B),
      .HSYNC(HSYNC), .VSYNC(VSYNC),
		.R(), .G(), .B(),
		.seg_sel(),
		.hex_out()
		);
		
sdr sdram0(
		.Dq(sdram_dq),
		.Addr(sdram_a),
		.Ba(sdram_ba),
		.Clk(sdram_clk),
		.Cke(sdram_cke),
		.Cs_n(sdram_cs_n),
		.Ras_n(sdram_ras_n),
		.Cas_n(sdram_cas_n),
		.We_n(sdram_wre_n),
		.Dqm(sdram_dqm));

assign p1_page = PVP_inst.p1_page;
assign p2_page = PVP_inst.p2_page;
assign hex_low = PVP_inst.hex_low;
assign hex_high = PVP_inst.hex_high;	
assign init_address = PVP_inst.init_address;
assign p1_address = PVP_inst.p1_address;
assign p2_address = PVP_inst.p2_address;

assign intcon_en = PVP_inst.intcon_en;
assign from_intcon = PVP_inst.from_intcon;
assign int_rq = PVP_inst.int_rq;
assign int_addr = PVP_inst.int_addr;
//interrupt controller internal signals
assign in = PVP_inst.intcon_inst.in;
assign prev_in = PVP_inst.intcon_inst.prev_in;
assign control = PVP_inst.intcon_inst.control;
assign status = PVP_inst.intcon_inst.status;
assign trig = PVP_inst.intcon_inst.trig;
assign interrupt = PVP_inst.intcon_inst.interrupt;

assign PRG_address = PVP_inst.PRG_address;
assign PRG_data = PVP_inst.PRG_data;
assign CPU_data_address = PVP_inst.data_address;
assign p1_data = PVP_inst.p1_data;
assign p2_from_mem = PVP_inst.p2_from_mem;
assign p2_to_mem = PVP_inst.p2_to_mem;
assign p1_reset = PVP_inst.p1_reset;
assign p2_reset = PVP_inst.p2_reset;
assign p2_flush = PVP_inst.p2_flush;
assign p2_wren = PVP_inst.p2_wren;
assign IO_WC = PVP_inst.IO_WC;
assign IO_RC = PVP_inst.IO_RC;
assign IO_n_LB_w = PVP_inst.IO_n_LB_w;
assign IO_n_LB_r = PVP_inst.IO_n_LB_r;
assign IO_SC = PVP_inst.CPU_inst.SC5;
//assign data_address = PVP_inst.CPU_inst.address;
assign CPU_data_in = PVP_inst.CPU_inst.data_in;
assign CPU_data_out = PVP_inst.CPU_inst.data_out;
//assign data_address_hold = PVP_inst.CPU_inst.data_address_hold;
assign I_reg = PVP_inst.CPU_inst.decode_unit0.I_reg;
//assign I_alternate = PVP_inst.CPU_inst.decode_unit0.I_alternate;
assign REGF_A_ADDRESS = PVP_inst.CPU_inst.reg_file0.a_address;
assign REGF_W_ADDRESS = PVP_inst.CPU_inst.reg_file0.w_address;
assign REGF_WREN = PVP_inst.CPU_inst.reg_file0.wren;
assign REGF_W_DATA = PVP_inst.CPU_inst.reg_file0.w_data;
assign REGF_A_DATA = PVP_inst.CPU_inst.reg_file0.a_data;
assign REGF_AUX_DATA = PVP_inst.CPU_inst.reg_file0.aux_data;
assign NZT = PVP_inst.CPU_inst.NZT;
assign XEC = PVP_inst.CPU_inst.XEC;
assign JMP = PVP_inst.CPU_inst.JMP;
assign CALL = PVP_inst.CPU_inst.CALL;
assign CALL2 = PVP_inst.CPU_inst.CALL2;
assign RET = PVP_inst.CPU_inst.RET;
assign hazard = PVP_inst.CPU_inst.hazard;
//assign aux_hazard = PVP_inst.CPU_inst.hazard_unit0.aux_hazard;
assign latch_hazard = PVP_inst.CPU_inst.hazard_unit0.latch_hazard;
assign regf_hazard = PVP_inst.CPU_inst.hazard_unit0.regf_hazard;
assign IO_hazard = PVP_inst.CPU_inst.hazard_unit0.IO_hazard;
assign pipeline_flush = PVP_inst.CPU_inst.pipeline_flush;
assign decoder_RST = PVP_inst.CPU_inst.decoder_RST;
//assign amux_out = PVP_inst.CPU_inst.amux_out;
assign alu_out = PVP_inst.CPU_inst.alu_out;
assign OVF = PVP_inst.CPU_inst.OVF;
//assign merge_D05 = PVP_inst.CPU_inst.merge_D05;
//assign shift_L4 = PVP_inst.CPU_inst.shift_L4;
//assign stack_addr = PVP_inst.CPU_inst.PC0.cstack0.address;
assign A_pipe0 = PVP_inst.CPU_inst.PC0.A_pipe0;
assign A_pipe1 = PVP_inst.CPU_inst.PC0.A_pipe1;
assign A_pipe2 = PVP_inst.CPU_inst.PC0.A_pipe2;
//assign A_pipe3 = PVP_inst.CPU_inst.PC0.A_pipe3;

assign p_cache_miss = PVP_inst.p_cache_miss;
assign d_cache_miss = PVP_inst.d_cache_miss;
assign p1_req = PVP_inst.p1_req;
assign p1_ready = PVP_inst.p1_ready;
assign p2_req = PVP_inst.p2_req;
assign p2_ready = PVP_inst.p2_ready;

always begin: CLOCK_GENERATION
#1 clk =  ~clk;
end

initial begin: CLOCK_INITIALIZATION
	clk = 0;
end

initial begin: TEST_VECTORS
//initial conditions
n_reset = 1'b0;
button = 4'b1110;
RXD = 1'b1;

#20 n_reset = 1'b1;	//release reset
#20 button = 4'b1111;	//release halt
//#1000 n_reset = 1'b0;
//#20 n_reset = 1'b1;
end
endmodule
