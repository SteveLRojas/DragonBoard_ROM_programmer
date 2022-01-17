module decode_unit(
		input wire clk,
		input wire RST,
		input wire hazard,
		input wire p_cache_miss,
		input wire[15:0] I,
		output wire SC,
		output wire WC,
		output wire RC,
		output wire n_LB_w,
		output wire n_LB_r,
		output wire[2:0] rotate_S0,
		output wire[2:0] rotate_R,
		output wire rotate_source,
		output wire rotate_mux,
		output wire[2:0] mask_L,
		output wire[2:0] alu_op,
		output wire alu_mux,
		output wire[7:0] alu_I_field,
		output wire latch_wren,
		output wire latch_address_w,
		output wire[2:0] merge_D0,
		output wire[2:0] shift_L,
		output wire[3:0] src_raddr,
		output wire[3:0] dest_waddr,
		output wire regf_wren,
		output wire PC_JMP,
		output wire PC_XEC,
		output wire PC_NZT,
		output wire PC_CALL,
		output wire PC_RET,
		output wire[12:0] PC_I_field);
reg[15:0] I_reg;
reg[15:0] I_alternate;
reg prev_hazard;

reg JMP;
reg NZT;
reg XEC;
reg CALL;
reg RET;
reg regf_wren_reg;
reg SC_reg;
reg WC_reg;
reg RC_reg;
reg[2:0] alu_op_reg;
reg n_LB_w_reg;
reg n_LB_r_reg;
reg[2:0] rotate_S0_reg;
reg[2:0] rotate_R_reg;
reg rotate_source_reg;
reg rotate_mux_reg;
reg[2:0] mask_L_reg;
reg alu_mux_reg;
reg[7:0] alu_I_field_reg;
reg latch_wren_reg;
reg latch_address_w_reg;
reg[2:0] merge_D0_reg;
reg[2:0] shift_L_reg;
reg[3:0] src_raddr_reg, dest_waddr_reg;

reg[12:0] PC_I_field_reg;
//reg long_I_reg;

always @(posedge clk)
begin
	if(RST)
	begin
		I_reg <= 16'h00;
		I_alternate <= 16'h0000;
		prev_hazard <= 1'b0;
	end
	else 
	begin
		if(~p_cache_miss)
			prev_hazard <= hazard;
		if(hazard & (~prev_hazard))
			I_alternate <= I;
		if(~hazard)
		begin
			if(prev_hazard)
				I_reg <= I_alternate;
			else if(p_cache_miss)
				I_reg <= 16'h0000;	//NOP
			else
				I_reg <= I;
		end
	end
	
	if(RST)
	begin
		JMP <= 1'b0;
		NZT <= 1'b0;
		XEC <= 1'b0;
		CALL <= 1'b0;
		RET <= 1'b0;
		regf_wren_reg <= 1'b0;
		SC_reg <= 1'b0;
		WC_reg <= 1'b0;
		RC_reg <= 1'b0;
		alu_op_reg <= 0;
		rotate_source_reg <= 1'b0;
		rotate_mux_reg <= 1'b0;
		latch_wren_reg <= 1'b0;
	end
	else if(~hazard)
	begin
		PC_I_field_reg <= I_reg[12:0];
		//long_I_reg <= ~I_reg[12];
		case(I_reg[4])
		1'b0: rotate_R_reg <= I_reg[7:5];
		1'b1: rotate_R_reg <= 3'b000;
		endcase
		n_LB_r_reg <= I_reg[11];
		
		case(I_reg[15:13])
		3'h0:	//move
		begin
			src_raddr_reg <= I_reg[11:8];
			//n_LB_r_reg <= I_reg[11];
			JMP <= 1'b0;
			
			rotate_mux_reg <= I_reg[11] & (~|I_reg[10:8]);	// true for OVF only, don't care for IV bus
			if((~I_reg[4] & (~&I_reg[2:0])) & (I_reg[7:5] == 3'h0) & (I_reg[12:8] == I_reg[4:0]))	//if NOP
			begin
				rotate_source_reg <= 1'b1;
				RC_reg <= 1'b0;
			end
			else
			begin
				rotate_source_reg <= I_reg[12];
				RC_reg <= I_reg[12];
			end
			
//			case(I_reg[4])
//			1'b0: rotate_R_reg <= I_reg[7:5];
//			1'b1: rotate_R_reg <= 3'b000;
//			endcase
			rotate_S0_reg <= I_reg[10:8];
			
			if(I_reg[12])
				mask_L_reg <= I_reg[7:5];
			else
				mask_L_reg <= 3'h0;
				
			alu_op_reg <= 3'h0;	//move
			alu_mux_reg <= 1'b0;
			alu_I_field_reg <= I_reg[7:0] & {{3{~I_reg[12]}}, 5'b11111};
			
			shift_L_reg <= I_reg[7:5];
			dest_waddr_reg <= I_reg[3:0];
			if(~I_reg[4])
				regf_wren_reg <= ((I_reg[7:5] != 3'h0) | (I_reg[12:8] != I_reg[4:0]));	//prevent NOP from triggering hazard detection
			else
				regf_wren_reg <= 1'b0;
			NZT <= 1'b0;
			XEC <= 1'b0;
			CALL <= 1'b0;
			RET <= 1'b0;
			
			merge_D0_reg <= I_reg[2:0];
			WC_reg <= I_reg[4];
			if(I_reg[4] == 1'b0 && (I_reg[2:0] == 3'h7))
				SC_reg <= 1'b1;
			else
				SC_reg <= 1'b0;
			n_LB_w_reg <= I_reg[3];
			latch_wren_reg <= I_reg[4];
			latch_address_w_reg <= I_reg[3];
		end
		3'h1:	//add
		begin
			src_raddr_reg <= I_reg[11:8];
			//n_LB_r_reg <= I_reg[11];
			JMP <= 1'b0;
			
			rotate_mux_reg <= I_reg[11] & (~|I_reg[10:8]);	// true for OVF only, don't care for IV bus
			rotate_source_reg <= I_reg[12];
			RC_reg <= I_reg[12];
//			case(I_reg[4])
//			1'b0: rotate_R_reg <= I_reg[7:5];
//			1'b1: rotate_R_reg <= 3'b000;
//			endcase
			rotate_S0_reg <= I_reg[10:8];
			
			if(I_reg[12])
				mask_L_reg <= I_reg[7:5];
			else
				mask_L_reg <= 3'h0;
				
			alu_op_reg <= 3'h1;	//add
			alu_mux_reg <= 1'b0;
			alu_I_field_reg <= I_reg[7:0] & {{3{~I_reg[12]}}, 5'b11111};
			
			shift_L_reg <= I_reg[7:5];
			dest_waddr_reg <= I_reg[3:0];
			regf_wren_reg <= ~I_reg[4];
			NZT <= 1'b0;
			XEC <= 1'b0;
			CALL <= 1'b0;
			RET <= 1'b0;
			
			merge_D0_reg <= I_reg[2:0];
			WC_reg <= I_reg[4];
			if(I_reg[4] == 1'b0 && (I_reg[2:0] == 3'h7))
				SC_reg <= 1'b1;
			else
				SC_reg <= 1'b0;
			n_LB_w_reg <= I_reg[3];
			latch_wren_reg <= I_reg[4];
			latch_address_w_reg <= I_reg[3];
		end
		3'h2:	//and
		begin
			src_raddr_reg <= I_reg[11:8];
			//n_LB_r_reg <= I_reg[11];
			JMP <= 1'b0;
			
			rotate_mux_reg <= I_reg[11] & (~|I_reg[10:8]);	// true for OVF only, don't care for IV bus
			rotate_source_reg <= I_reg[12];
			RC_reg <= I_reg[12];
//			case(I_reg[4])
//			1'b0: rotate_R_reg <= I_reg[7:5];
//			1'b1: rotate_R_reg <= 3'b000;
//			endcase
			rotate_S0_reg <= I_reg[10:8];
			
			if(I_reg[12])
				mask_L_reg <= I_reg[7:5];
			else
				mask_L_reg <= 3'h0;
				
			alu_op_reg <= 3'h2;	//and
			alu_mux_reg <= 1'b0;
			alu_I_field_reg <= I_reg[7:0] & {{3{~I_reg[12]}}, 5'b11111};
			
			shift_L_reg <= I_reg[7:5];
			dest_waddr_reg <= I_reg[3:0];
			regf_wren_reg <= ~I_reg[4];
			NZT <= 1'b0;
			XEC <= 1'b0;
			CALL <= 1'b0;
			RET <= 1'b0;
			
			merge_D0_reg <= I_reg[2:0];
			WC_reg <= I_reg[4];
			if(I_reg[4] == 1'b0 && (I_reg[2:0] == 3'h7))
				SC_reg <= 1'b1;
			else
				SC_reg <= 1'b0;
			n_LB_w_reg <= I_reg[3];
			latch_wren_reg <= I_reg[4];
			latch_address_w_reg <= I_reg[3];
		end
		3'h3:	//xor
		begin
			src_raddr_reg <= I_reg[11:8];
			//n_LB_r_reg <= I_reg[11];
			JMP <= 1'b0;
			
			rotate_mux_reg <= I_reg[11] & (~|I_reg[10:8]);	// true for OVF only, don't care for IV bus
			rotate_source_reg <= I_reg[12];
			RC_reg <= I_reg[12];
//			case(I_reg[4])
//			1'b0: rotate_R_reg <= I_reg[7:5];
//			1'b1: rotate_R_reg <= 3'b000;
//			endcase
			rotate_S0_reg <= I_reg[10:8];
			
			if(I_reg[12])
				mask_L_reg <= I_reg[7:5];
			else
				mask_L_reg <= 3'h0;
				
			alu_op_reg <= 3'h3;	//xor
			alu_mux_reg <= 1'b0;
			alu_I_field_reg <= I_reg[7:0] & {{3{~I_reg[12]}}, 5'b11111};
			
			shift_L_reg <= I_reg[7:5];
			dest_waddr_reg <= I_reg[3:0];
			regf_wren_reg <= ~I_reg[4];
			NZT <= 1'b0;
			XEC <= 1'b0;
			CALL <= 1'b0;
			RET <= 1'b0;
			
			merge_D0_reg <= I_reg[2:0];
			WC_reg <= I_reg[4];
			if(I_reg[4] == 1'b0 && (I_reg[2:0] == 3'h7))
				SC_reg <= 1'b1;
			else
				SC_reg <= 1'b0;
			n_LB_w_reg <= I_reg[3];
			latch_wren_reg <= I_reg[4];
			latch_address_w_reg <= I_reg[3];
		end
		3'h4:	//xec
		begin
			src_raddr_reg <= I_reg[11:8];
			//n_LB_r_reg <= I_reg[11];
			JMP <= 1'b0;
			
			rotate_mux_reg <= I_reg[11] & (~|I_reg[10:8]);	// true for OVF only, don't care for IV bus
			rotate_source_reg <= I_reg[12];
			RC_reg <= I_reg[12];
			//rotate_R_reg <= 3'b000;
			rotate_S0_reg <= I_reg[10:8];
			
			if(I_reg[12])
				mask_L_reg <= I_reg[7:5];
			else
				mask_L_reg <= 3'h0;
			
			alu_op_reg <= 3'h5;
			alu_mux_reg <= 1'b1;
			alu_I_field_reg <= I_reg[7:0] & {{3{~I_reg[12]}}, 5'b11111};
			
			shift_L_reg <= I_reg[7:5];
			dest_waddr_reg <= I_reg[3:0];
			regf_wren_reg <= 1'b0;
			NZT <= 1'b0;
			XEC <= 1'b1;
			CALL <= 1'b0;
			RET <= 1'b0;
			
			merge_D0_reg <= I_reg[2:0];
			WC_reg <= 1'b0;
			SC_reg <= 1'b0;
			n_LB_w_reg <= I_reg[3];
			latch_wren_reg <= 1'b0;
			latch_address_w_reg <= I_reg[3];
		end
		3'h5:	//nzt
		begin
			if(&I_reg[10:8])
				src_raddr_reg <= 4'h0;	//read AUX for CALL
			else
				src_raddr_reg <= I_reg[11:8];
			//n_LB_r_reg <= I_reg[11];
			JMP <= 1'b0;
			
			rotate_mux_reg <= I_reg[11] & (~|I_reg[10:8]);	// true for OVF only, don't care for IV bus
			rotate_source_reg <= I_reg[12];
			RC_reg <= I_reg[12];
			//rotate_R_reg <= 3'b000;
			rotate_S0_reg <= I_reg[10:8];
			
			if(I_reg[12])
				mask_L_reg <= I_reg[7:5];
			else
				mask_L_reg <= 3'h0;
			
			alu_op_reg <= 3'h4;
			alu_mux_reg <= ((~I_reg[12]) & (&I_reg[10:8])) ? 1'b0 : 1'b1;
			alu_I_field_reg <= I_reg[7:0] & {{3{~I_reg[12]}}, 5'b11111};
			
			shift_L_reg <= I_reg[7:5];
			dest_waddr_reg <= I_reg[3:0];
			regf_wren_reg <= 1'b0;
			NZT <= ~((~I_reg[12]) & (I_reg[11]) & (&I_reg[10:8]));	//no NZT for return instructions
			XEC <= 1'b0;
			CALL <= (~I_reg[12]) & (~I_reg[11]) & (&I_reg[10:8]);
			RET <= (~I_reg[12]) & (I_reg[11]) & (&I_reg[10:8]);
			
			merge_D0_reg <= I_reg[2:0];
			WC_reg <= 1'b0;
			SC_reg <= 1'b0;
			n_LB_w_reg <= I_reg[3];
			latch_wren_reg <= 1'b0;
			latch_address_w_reg <= I_reg[3];
		end
		3'h6:	//xmit
		begin
			src_raddr_reg <= I_reg[11:8];
			//n_LB_r_reg <= I_reg[11];
			JMP <= 1'b0;
			
			rotate_mux_reg <= I_reg[11] & (~|I_reg[10:8]);	// true for OVF only, don't care for IV bus
			rotate_source_reg <= 1'b1;
			RC_reg <= 1'b0;
			//rotate_R_reg <= 3'b000;
			rotate_S0_reg <= I_reg[10:8];
			mask_L_reg <= 3'h0;
			
			if(I_reg[12])
				shift_L_reg <= I_reg[7:5];
			else
				shift_L_reg <= 3'h0;
			
			alu_op_reg <= 3'h4;
			alu_mux_reg <= 1'b1;
			alu_I_field_reg <= I_reg[7:0] & {{3{~I_reg[12]}}, 5'b11111};
			
			dest_waddr_reg <= I_reg[11:8];
			regf_wren_reg <= ~I_reg[12];
			NZT <= 1'b0;
			XEC <= 1'b0;
			CALL <= 1'b0;
			RET <= 1'b0;
			
			merge_D0_reg <= I_reg[10:8];
			WC_reg <= I_reg[12];
			if(I_reg[12] == 1'b0 && (I_reg[10:8] == 3'h7))
				SC_reg <= 1'b1;
			else
				SC_reg <= 1'b0;
			n_LB_w_reg <= I_reg[11];
			latch_wren_reg <= I_reg[12];
			latch_address_w_reg <= I_reg[11];
		end
		3'h7:	//jmp
		begin
			src_raddr_reg <= I_reg[11:8];
			//n_LB_r_reg <= I_reg[11];
			JMP <= 1'b1;
			
			rotate_mux_reg <= I_reg[11] & (~|I_reg[10:8]);	// true for OVF only, don't care for IV bus
			rotate_source_reg <= 1'b1;
			RC_reg <= 1'b0;
			//rotate_R_reg <= 3'b000;
			rotate_S0_reg <= I_reg[10:8];
			
			if(I_reg[12])
				mask_L_reg <= I_reg[7:5];
			else
				mask_L_reg <= 3'h0;
			
			alu_op_reg <= 3'h7;
			alu_mux_reg <= 1'b1;
			alu_I_field_reg <= I_reg[7:0] & {{3{~I_reg[12]}}, 5'b11111};
			
			shift_L_reg <= I_reg[7:5];
			dest_waddr_reg <= I_reg[11:8];
			regf_wren_reg <= 1'b0;
			NZT <= 1'b0;
			XEC <= 1'b0;
			CALL <= 1'b0;
			RET <= 1'b0;
			
			merge_D0_reg <= I_reg[2:0];
			WC_reg <= 1'b0;
			SC_reg <= 1'b0;
			n_LB_w_reg <= I_reg[3];
			latch_wren_reg <= 1'b0;
			latch_address_w_reg <= I_reg[3];
		end
		endcase
	end
end
assign SC = SC_reg;
assign WC = WC_reg;
assign RC = RC_reg;
assign n_LB_w = n_LB_w_reg;
assign n_LB_r = n_LB_r_reg;
assign rotate_S0 = rotate_S0_reg;
assign rotate_R = rotate_R_reg;
assign rotate_source = rotate_source_reg;
assign rotate_mux = rotate_mux_reg;
assign mask_L = mask_L_reg;
assign alu_op = alu_op_reg;
assign alu_mux = alu_mux_reg;
assign alu_I_field = alu_I_field_reg;
assign latch_wren = latch_wren_reg;
assign latch_address_w = latch_address_w_reg;
assign merge_D0 = merge_D0_reg;
assign shift_L = shift_L_reg;
assign src_raddr = src_raddr_reg;
assign dest_waddr = dest_waddr_reg;
assign regf_wren = regf_wren_reg;
assign PC_JMP = JMP;
assign PC_XEC = XEC;
assign PC_NZT = NZT;
assign PC_CALL = CALL;
assign PC_RET = RET;
assign PC_I_field = PC_I_field_reg;
//assign long_I = long_I_reg;
endmodule
