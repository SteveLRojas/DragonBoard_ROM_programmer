module shift_merge(
			input wire clk,
			input wire data_hazard,
			input wire[7:0] shift_in,
			input wire[2:0] D0,
			input wire[2:0] L_select,
			input wire latch_wren,
			input wire[1:0] latch_address_w,
			input wire[1:0] latch_address_r,
			output wire[15:0] address,
			output wire[15:0] data_out);
reg[7:0] merge_in;
reg[7:0] shift_reg;
reg[7:0] merge_result;
reg[7:0] merge_mask;
reg[3:0] w_address_exp;
//Quartus is stupid and insists on using block ram even with ramstyle = "logic"
reg[7:0] LBA_reg;
reg[7:0] RBA_reg;
reg[7:0] LBD_reg;
reg[7:0] RBD_reg;

initial
begin
	LBA_reg = 8'h00;	//actual value does not matter, but it must be defined so that the cache controller is not stuck in a miss state.
	RBA_reg = 8'h00;
end

always @(posedge clk)
begin
	if(~data_hazard)
	begin
		case(L_select)
		3'b000: shift_reg <= shift_in;
		3'b001: shift_reg <= {7'h0, shift_in[0]};
		3'b010: shift_reg <= {6'h0, shift_in[1:0]};
		3'b011: shift_reg <= {5'h0, shift_in[2:0]};
		3'b100: shift_reg <= {4'h0, shift_in[3:0]};
		3'b101: shift_reg <= {3'h0, shift_in[4:0]};
		3'b110: shift_reg <= {2'b0, shift_in[5:0]};
		3'b111: shift_reg <= {1'b0, shift_in[6:0]};
		endcase
		case(L_select)
		3'b000: merge_mask <= 8'h0;
		3'b001: merge_mask <= {7'b1111111, 1'b0};
		3'b010: merge_mask <= {6'b111111, 2'b00};
		3'b011: merge_mask <= {5'b11111, 3'b000};
		3'b100: merge_mask <= {4'b1111, 4'b0000};
		3'b101: merge_mask <= {3'b111, 5'b00000};
		3'b110: merge_mask <= {2'b11, 6'b000000};
		3'b111: merge_mask <= {1'b1, 7'b0000000};
		endcase
	end
end

always @(*)
begin
	case(D0)
	3'b000: merge_result = {shift_reg[0], 7'h00} | (merge_in & {merge_mask[0], merge_mask[7:1]});
	3'b001: merge_result = {shift_reg[1:0], 6'h00} | (merge_in & {merge_mask[1:0], merge_mask[7:2]});
	3'b010: merge_result = {shift_reg[2:0], 5'h00} | (merge_in & {merge_mask[2:0], merge_mask[7:3]});
	3'b011: merge_result = {shift_reg[3:0], 4'h0} | (merge_in & {merge_mask[3:0], merge_mask[7:4]});
	3'b100: merge_result = {shift_reg[4:0], 3'h0} | (merge_in & {merge_mask[4:0], merge_mask[7:5]});
	3'b101: merge_result = {shift_reg[5:0], 2'b00} | (merge_in & {merge_mask[5:0], merge_mask[7:6]});
	3'b110: merge_result = {shift_reg[6:0], 1'b0} | (merge_in & {merge_mask[6:0], merge_mask[7]});
	3'b111: merge_result = shift_reg | (merge_in & merge_mask);
	endcase
	case(latch_address_w)
	2'h0: w_address_exp = 4'b0001;
	2'h1: w_address_exp = 4'b0010;
	2'h2: w_address_exp = 4'b0100;
	2'h3: w_address_exp = 4'b1000;
	endcase
end
	
always @(posedge clk)
begin
	if(~data_hazard)
	begin
		if(latch_wren & w_address_exp[0])
			LBA_reg <= merge_result;
		if(latch_wren & w_address_exp[1])
			RBA_reg <= merge_result;
		if(latch_wren & w_address_exp[2])
			LBD_reg <= merge_result;
		if(latch_wren & w_address_exp[3])
			RBD_reg <= merge_result;
	
		case(latch_address_r)
		2'h0: merge_in <= LBA_reg;
		2'h1: merge_in <= RBA_reg;
		2'h2: merge_in <= LBD_reg;
		2'h3: merge_in <= RBD_reg;
		endcase
	end
end

assign address = {LBA_reg, RBA_reg};
assign data_out = {LBD_reg, RBD_reg};
endmodule
