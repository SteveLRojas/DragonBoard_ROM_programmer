module hazard_unit(
		input wire clk,
		input wire NZT1, NZT2,// NZT3, NZT4,
		input wire JMP,
		input wire XEC1, XEC2,// XEC3, XEC4,
		input wire RET,
		input wire CALL2,
		input wire interrupt,
		input wire ALU_NZ,
		input wire[2:0] alu_op1,
		input wire HALT,
		input wire RST,
		input wire[3:0] regf_a_read,
		input wire[3:0] regf_w_reg1,
		input wire regf_wren_reg1, regf_wren_reg2,
		input wire SC_reg, SC_reg1, SC_reg2, SC_reg3, SC_reg4, SC_reg5,
		input wire WC_reg1, WC_reg2, WC_reg3, WC_reg4, WC_reg5, WC_reg6,// WC_reg7,
		input wire RC_reg,
		input wire n_LB_w_reg1, n_LB_w_reg2, n_LB_w_reg3, n_LB_w_reg4, n_LB_w_reg5, n_LB_w_reg6,// n_LB_w_reg7,
		input wire n_LB_r,
		input wire rotate_mux,
		input wire rotate_source,
		input wire latch_wren, latch_wren1,
		input wire latch_address_w1,
		input wire latch_address_r,
		input wire[2:0] shift_L,
		input wire d_cache_miss,
		output wire hazard,
		output wire data_hazard,
		output wire branch_hazard,
		output wire pipeline_flush,
		output wire decoder_RST);
reg RST_hold;
wire decoder_flush;
wire regf_hazard1;
wire regf_hazard;
wire IO_hazard;
wire IO_hazard1, IO_hazard2, IO_hazard3, IO_hazard4, IO_hazard5, IO_hazard6;
wire IO_address_hazard;
wire IO_hazard_read_miss;
wire IO_hazard_write_miss;
wire latch_hazard;
wire OVF_hazard1;
wire OVF_hazard;
//assign branch_hazard = (JMP | RET) & (NZT1 | NZT2 | NZT3 | XEC1 | XEC2 | XEC3);
assign branch_hazard = (JMP | RET) & (NZT1 | XEC1);
assign decoder_flush = ((~branch_hazard) & (JMP | RET)) | ((NZT2 & ALU_NZ) | XEC2 | CALL2) | interrupt;
assign pipeline_flush = (NZT2 & ALU_NZ) | XEC2 | CALL2 | interrupt;
always @(posedge clk)
begin
	RST_hold <= decoder_flush;
end
assign decoder_RST = decoder_flush | RST_hold | RST;
assign latch_hazard = latch_wren1 & (shift_L != 3'h0) & (latch_address_w1 == latch_address_r) & latch_wren;	//no latch write means no latch read
assign OVF_hazard1 = (alu_op1 == 3'b001) & rotate_mux & (~rotate_source); //recent write, reading OVF
assign regf_hazard1 = regf_wren_reg1 & (~rotate_mux) & (~rotate_source) & (regf_a_read == regf_w_reg1);
assign IO_hazard1 = RC_reg & (SC_reg1 | (WC_reg1 & (n_LB_w_reg1 == n_LB_r)));
assign IO_hazard2 = RC_reg & (SC_reg2 | (WC_reg2 & (n_LB_w_reg2 == n_LB_r)));
assign IO_hazard3 = RC_reg & (SC_reg3 | (WC_reg3 & (n_LB_w_reg3 == n_LB_r)));
assign IO_hazard4 = RC_reg & (SC_reg4 | (WC_reg4 & (n_LB_w_reg4 == n_LB_r)));
assign IO_hazard5 = RC_reg & (SC_reg5 | (WC_reg5 & (n_LB_w_reg5 == n_LB_r)));
assign IO_hazard6 = RC_reg & (WC_reg6 & (n_LB_w_reg6 == n_LB_r));
assign IO_address_hazard = SC_reg & WC_reg1;	//cant do SC after WC because address is driven by stage 5 and data by stage 6
assign IO_hazard_read_miss = RC_reg & d_cache_miss;
assign IO_hazard_write_miss = d_cache_miss & WC_reg6;
assign OVF_hazard = OVF_hazard1;
assign regf_hazard = regf_hazard1;
assign IO_hazard = IO_hazard1 | IO_hazard2 | IO_hazard3 | IO_hazard4 | IO_hazard5 | IO_hazard6 | IO_address_hazard | IO_hazard_read_miss | IO_hazard_write_miss;
assign hazard = decoder_flush | IO_hazard | regf_hazard | branch_hazard | latch_hazard | HALT | OVF_hazard;
assign data_hazard = IO_hazard_write_miss;
endmodule
