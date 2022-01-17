module RIPTIDE_III(
		input wire clk,
		input wire n_halt,
		input wire p_cache_miss,
		input wire d_cache_miss,
		input wire n_reset,
		input wire int_rq,
		input wire[2:0] int_addr,
		input wire[15:0] I,	//program data
		output wire[15:0] A,	//program address
		output wire[15:0] address,	//data address
		output wire[15:0] data_out,
		input wire[15:0] data_in,
		output wire IO_WC,	//high during IO writes
		output wire IO_RC,
		output wire IO_n_LB_w,	//low when left bank is selected for writing (does notimply a write operation)
		output wire IO_n_LB_r	//low when left bank is selected for reading (does not imply read operation)
		);

reg RST, RST_hold;
reg HALT;
reg prev_int_rq;
reg interrupt;
reg[7:0] IV_in;
reg SC1, SC2, SC3, SC4, SC5;
reg WC1, WC2, WC3, WC4, WC5, WC6;//, WC7;
reg n_LB_w1, n_LB_w2, n_LB_w3, n_LB_w4, n_LB_w5, n_LB_w6;//, n_LB_w7;
reg latch_wren1, latch_wren2, latch_wren3, latch_wren4, latch_wren5;
reg latch_address_w1, latch_address_w2, latch_address_w3, latch_address_w4, latch_address_w5;
wire[3:0] src_raddr;
reg[3:0] src_raddr1;
wire[3:0] dest_waddr;
reg[3:0] dest_waddr1, dest_waddr2, dest_waddr3, dest_waddr4;
wire regf_wren;
reg regf_wren1, regf_wren2, regf_wren3, regf_wren4;
wire[7:0] a_data, aux_data;
wire[7:0] rotate_out_IO, rotate_out_RF;
reg[2:0] rotate_S01, rotate_R1, rotate_R2;
reg alu_a_source1, alu_a_source2, alu_a_source3;
reg rotate_mux1, rotate_mux2;
wire[7:0] rmux_out;
wire[2:0] mask_L;
reg[2:0] mask_L1, mask_L2;
wire[7:0] mask_out;
reg[2:0] alu_op1, alu_op2, alu_op3;
wire[7:0] alu_b_mux_out, alu_a_mux_out;
reg[7:0] alu_I_field1, alu_I_field2, alu_I_field3;
reg alu_b_source1, alu_b_source2, alu_b_source3;
wire[7:0] alu_out;
wire alu_b_source;
wire[7:0] alu_I_field;
wire OVF;
wire NZ;
wire decoder_RST;
wire SC;	//select command
wire WC;	//write command
wire RC;	//read command
wire n_LB_w;
wire n_LB_r;
wire[2:0] merge_D0;
wire[2:0] shift_L;
wire[2:0] alu_op;
wire[2:0] rotate_S0;
wire[2:0] rotate_R;
wire alu_a_source;
wire rotate_mux;
wire latch_wren;
wire latch_address_w;
reg NZT1, NZT2;
reg XEC1, XEC2;
reg CALL1, CALL2;
wire NZT;
wire XEC;
wire JMP;
wire RET;
wire CALL;
wire long_I;
wire[12:0] PC_I_field;
reg[7:0] PC_I_field1, PC_I_field2;
reg[2:0] merge_D01, merge_D02, merge_D03, merge_D04, merge_D05;
reg[2:0] shift_L1, shift_L2, shift_L3, shift_L4;
wire hazard;
wire data_hazard;
wire branch_hazard;
wire pipeline_flush;

assign IO_WC = WC6;
//no IO read during IO hazard to prevent false cache misses (Assuming all IO registers are read only or write only or cached).
assign IO_RC = RC & ~(SC1 | SC2 | SC3 | SC4 | SC5);
assign IO_n_LB_w = n_LB_w6;
assign IO_n_LB_r = n_LB_r;

always @(posedge clk)
begin
	RST <= (~n_reset) | RST_hold;
	RST_hold <= ~n_reset;
	HALT <= ~n_halt;
	IV_in <= (n_LB_r)? data_in[7:0] : data_in[15:8];
	
	if(RST)
	begin
		interrupt <= 1'b0;
		prev_int_rq <= 1'b1;
	end
	else
	begin
		prev_int_rq <= int_rq & (~decoder_RST | prev_int_rq);	//set when int_rq & ~decoder_RST, clear when ~int_rq
		interrupt <= int_rq & ~prev_int_rq & ~decoder_RST;
	end
end

always @(posedge clk or posedge RST)
begin
	if(RST)
	begin
		SC1 <= 1'b0;
		SC2 <= 1'b0;
		WC1 <= 1'b0;
		WC2 <= 1'b0;
		n_LB_w1 <= 1'b0;
		n_LB_w2 <= 1'b0;
		latch_wren1 <= 1'b0;
		latch_wren2 <= 1'b0;
		regf_wren1 <= 1'b0;
		regf_wren2 <= 1'b0;
		rotate_S01 <= 3'h0;
		rotate_R1 <= 3'h0;
		rotate_R2 <= 3'h0;
		alu_a_source1 <= 1'b0;
		alu_a_source2 <= 1'b0;
		rotate_mux1 <= 1'b0;
		rotate_mux2 <= 1'b0;
		mask_L1 <= 3'h0;
		mask_L2 <= 3'h0;
		alu_op1 <= 3'h0;
		alu_op2 <= 3'h0;
		alu_I_field1 <= 8'h0;
		alu_I_field2 <= 8'h0;
		alu_b_source1 <= 1'b0;
		alu_b_source2 <= 1'b0;
		merge_D01 <= 3'h0;
		merge_D02 <= 3'h0;
		shift_L1 <= 3'h0;
		shift_L2 <= 3'h0;
		NZT1 <= 1'b0;
		NZT2 <= 1'b0;
		XEC1 <= 1'b0;
		XEC2 <= 1'b0;
		CALL1 <= 1'b0;
		CALL2 <= 1'b0;
	end
	else if(~data_hazard)
	begin	//not reset
		if(pipeline_flush)
		begin
			SC1 <= 1'b0;
			SC2 <= 1'b0;
			WC1 <= 1'b0;
			WC2 <= 1'b0;
			n_LB_w1 <= 1'b0;
			n_LB_w2 <= 1'b0;
			latch_wren1 <= 1'b0;
			latch_wren2 <= 1'b0;
			regf_wren1 <= 1'b0;
			regf_wren2 <= 1'b0;
			rotate_S01 <= 3'h0;
			rotate_R1 <= 3'h0;
			rotate_R2 <= 3'h0;
			alu_a_source1 <= 1'b0;
			alu_a_source2 <= 1'b0;
			rotate_mux1 <= 1'b0;
			rotate_mux2 <= 1'b0;
			mask_L1 <= 3'h0;
			mask_L2 <= 3'h0;
			alu_op1 <= 3'h0;
			alu_op2 <= 3'h0;
			alu_I_field1 <= 8'h0;
			alu_I_field2 <= 8'h0;
			alu_b_source1 <= 1'b0;
			alu_b_source2 <= 1'b0;
			merge_D01 <= 3'h0;
			merge_D02 <= 3'h0;
			shift_L1 <= 3'h0;
			shift_L2 <= 3'h0;
			NZT1 <= 1'b0;
			NZT2 <= 1'b0;
			XEC1 <= 1'b0;
			XEC2 <= 1'b0;
			CALL1 <= 1'b0;
			CALL2 <= 1'b0;
		end
		else
		begin	//not flush
			if(hazard)
			begin
				SC1 <= 1'b0;
				WC1 <= 1'b0;
				n_LB_w1 <= 1'b0;
				latch_wren1 <= 1'b0;
				regf_wren1 <= 1'b0;
				rotate_S01 <= 3'h0;
				rotate_R1 <= 3'h0;
				alu_a_source1 <= 1'b0;
				rotate_mux1 <= 1'b0;
				mask_L1 <= 3'h0;
				alu_op1 <= 3'h0;
				alu_I_field1 <= 8'h0;
				alu_b_source1 <= 1'b0;
				merge_D01 <= 3'h0;
				shift_L1 <= 3'h0;
				NZT1 <= 1'b0;
				XEC1 <= 1'b0;
				CALL1 <= 1'b0;
			end
			else
			begin	//not hazard
				SC1 <= SC;
				WC1 <= WC;
				n_LB_w1 <= n_LB_w;
				latch_wren1 <= latch_wren;
				regf_wren1 <= regf_wren;
				rotate_S01 <= rotate_S0;
				rotate_R1 <= rotate_R;
				alu_a_source1 <= alu_a_source;
				rotate_mux1 <= rotate_mux;
				mask_L1 <= mask_L;
				alu_op1 <= alu_op;
				alu_I_field1 <= alu_I_field;
				alu_b_source1 <= alu_b_source;
				merge_D01 <= merge_D0;
				shift_L1 <= shift_L;
				NZT1 <= NZT;
				XEC1 <= XEC;
				CALL1 <= CALL;
			end	//not flush
			SC2 <= SC1;
			WC2 <= WC1;
			n_LB_w2 <= n_LB_w1;
			latch_wren2 <= latch_wren1;
			regf_wren2 <= regf_wren1;
			rotate_R2 <= rotate_R1;
			alu_a_source2 <= alu_a_source1;
			rotate_mux2 <= rotate_mux1;
			mask_L2 <= mask_L1;
			alu_op2 <= alu_op1;
			alu_I_field2 <= alu_I_field1;
			alu_b_source2 <= alu_b_source1;
			merge_D02 <= merge_D01;
			shift_L2 <= shift_L1;
			NZT2 <= NZT1;
			XEC2 <= XEC1;
			CALL2 <= CALL1;
		end
	end
end

always @(posedge clk)
begin
	if(~data_hazard)
	begin
		latch_address_w1 <= latch_address_w;
		latch_address_w2 <= latch_address_w1;
		latch_address_w3 <= latch_address_w2;
		latch_address_w4 <= latch_address_w3;
		SC5 <= SC4;
		n_LB_w5 <= n_LB_w4;
		n_LB_w6 <= n_LB_w5;
		latch_wren5 <= latch_wren4;
		latch_address_w5 <= latch_address_w4;
		src_raddr1 <= src_raddr;
		dest_waddr1 <= dest_waddr;
		dest_waddr2 <= dest_waddr1;
		dest_waddr3 <= dest_waddr2;
		dest_waddr4 <= dest_waddr3;
		merge_D05 <= merge_D04;
		PC_I_field1 <= PC_I_field[7:0];
		PC_I_field2 <= PC_I_field1;
	end
end

always @(posedge clk or posedge RST)
begin
	if(RST)
	begin
		SC3 <= 1'b0;
		SC4 <= 1'b0;
		WC3 <= 1'b0;
		WC4 <= 1'b0;
		WC5 <= 1'b0;
		WC6 <= 1'b0;
		n_LB_w3 <= 1'b0;
		n_LB_w4 <= 1'b0;
		latch_wren3 <= 1'b0;
		latch_wren4 <= 1'b0;
		regf_wren3 <= 1'b0;
		regf_wren4 <= 1'b0;
		alu_a_source3 <= 1'b0;
		alu_op3 <= 3'h0;
		alu_I_field3 <= 8'h0;
		alu_b_source3 <= 1'b0;
		merge_D03 <= 3'h0;
		merge_D04 <= 3'h0;
		shift_L3 <= 3'h0;
		shift_L4 <= 3'h0;
	end
	else if(~data_hazard)
	begin
		SC3 <= SC2;
		SC4 <= SC3;
		WC3 <= WC2;
		WC4 <= WC3;
		WC5 <= WC4;
		WC6 <= WC5;
		n_LB_w3 <= n_LB_w2;
		n_LB_w4 <= n_LB_w3;
		latch_wren3 <= latch_wren2;
		latch_wren4 <= latch_wren3;
		regf_wren3 <= regf_wren2;
		regf_wren4 <= regf_wren3;
		alu_a_source3 <= alu_a_source2;
		alu_op3 <= alu_op2;
		alu_I_field3 <= alu_I_field2;
		alu_b_source3 <= alu_b_source2;
		merge_D03 <= merge_D02;
		merge_D04 <= merge_D03;
		shift_L3 <= shift_L2;
		shift_L4 <= shift_L3;
	end
end

//register file
reg_file reg_file0(
		.clk(clk),
		.data_hazard(data_hazard),
		.a_address(src_raddr1),
		.w_address(dest_waddr4),
		.wren(regf_wren4),
		.w_data(alu_out),
		.a_data(a_data),
		.aux_data(aux_data),
		.ivr(address[7:0]),
		.ivl(address[15:8]));
		
//right rotate module
assign rmux_out = rotate_mux2 ? {7'h0, OVF} : a_data;
right_rotate right_rotate0(
		.clk(clk),
		.data_hazard(data_hazard),
		.rotate_in(rmux_out),
		.rotate_out(rotate_out_RF),
		.R(rotate_R2));

right_rotate right_rotate1(
		.clk(clk),
		.data_hazard(data_hazard),
		.rotate_in(IV_in),
		.rotate_out(rotate_out_IO),
		.R(rotate_S01));
		
//mask module
mask_unit mask0(.clk(clk), .data_hazard(data_hazard), .mask_in(rotate_out_IO), .L_select(mask_L2), .mask_out(mask_out));

//ALU
assign alu_b_mux_out = alu_b_source3 ? alu_I_field3 : aux_data;
assign alu_a_mux_out = alu_a_source3 ? mask_out : rotate_out_RF;
ALU ALU0(
		.clk(clk),
		.data_hazard(data_hazard),
		.op(alu_op3),
		.in_a(alu_a_mux_out),
		.in_b(alu_b_mux_out),
		.alu_out(alu_out),
		.OVF_out(OVF));

//shift and merge unit
shift_merge shift_merge0(
		.clk(clk),
		.data_hazard(data_hazard),
		.shift_in(alu_out),
		.D0(merge_D05),
		.L_select(shift_L4),
		.latch_wren(latch_wren5),
		.latch_address_w(latch_address_w5),
		.latch_address_r(latch_address_w4),
		.data_out(data_out));
		
//PC
PC PC0(
		.clk(clk),
		.rst(RST),
		.NZT2(NZT2),
		.XEC2(XEC2),
		.JMP(JMP),
		.CALL2(CALL2),
		.RET(RET),
		.interrupt(interrupt),
		.int_addr(int_addr),
		.hazard(hazard),
		.data_hazard(data_hazard),
		.branch_hazard(branch_hazard),
		.pipeline_flush(pipeline_flush),
		.p_cache_miss(p_cache_miss),
		.register_data(a_data),
		.PC_I_field(PC_I_field),
		.PC_I_field2(PC_I_field2),
		.reg_nz(NZ),
		.A(A));
		
//control unit
decode_unit decode_unit0(
		.clk(clk),
		.RST(decoder_RST),
		.hazard(hazard),
		.p_cache_miss(p_cache_miss),
		.I(I),
		.SC(SC),
		.WC(WC),
		.RC(RC),
		.n_LB_w(n_LB_w),
		.n_LB_r(n_LB_r),
		.rotate_S0(rotate_S0),
		.rotate_R(rotate_R),
		.rotate_source(alu_a_source),
		.rotate_mux(rotate_mux),
		.mask_L(mask_L),
		.alu_op(alu_op),
		.alu_mux(alu_b_source),
		.alu_I_field(alu_I_field),
		.latch_wren(latch_wren),
		.latch_address_w(latch_address_w),
		.merge_D0(merge_D0),
		.shift_L(shift_L),
		.src_raddr(src_raddr),
		.dest_waddr(dest_waddr),
		.regf_wren(regf_wren),
		.PC_JMP(JMP),
		.PC_XEC(XEC),
		.PC_NZT(NZT),
		.PC_CALL(CALL),
		.PC_RET(RET),
		.PC_I_field(PC_I_field));
		
//hazard unit
hazard_unit hazard_unit0(
		.clk(clk),
		.NZT1(NZT1), .NZT2(NZT2),
		.JMP(JMP),
		.XEC1(XEC1), .XEC2(XEC2),
		.RET(RET),
		.CALL2(CALL2),
		.interrupt(interrupt),
		.ALU_NZ(NZ),
		.alu_op1(alu_op1),
		.HALT(HALT),
		.RST(RST),
		.regf_a_read(src_raddr),
		.regf_w_reg1(dest_waddr1),
		.regf_wren_reg1(regf_wren1), .regf_wren_reg2(regf_wren2),
		.SC_reg(SC), .SC_reg1(SC1), .SC_reg2(SC2), .SC_reg3(SC3), .SC_reg4(SC4), .SC_reg5(SC5),
		.WC_reg1(WC1), .WC_reg2(WC2), .WC_reg3(WC3), .WC_reg4(WC4), .WC_reg5(WC5), .WC_reg6(WC6),
		.RC_reg(RC),
		.n_LB_w_reg1(n_LB_w1), .n_LB_w_reg2(n_LB_w2), .n_LB_w_reg3(n_LB_w3), .n_LB_w_reg4(n_LB_w4), .n_LB_w_reg5(n_LB_w5), .n_LB_w_reg6(n_LB_w6),
		.n_LB_r(n_LB_r),
		.rotate_mux(rotate_mux),
		.rotate_source(alu_a_source),
		.latch_wren(latch_wren), .latch_wren1(latch_wren1),
		.latch_address_w1(latch_address_w1),
		.latch_address_r(latch_address_w),
		.shift_L(shift_L),
		.d_cache_miss(d_cache_miss),
		.hazard(hazard),
		.data_hazard(data_hazard),
		.branch_hazard(branch_hazard),
		.pipeline_flush(pipeline_flush),
		.decoder_RST(decoder_RST));
endmodule
