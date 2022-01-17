module mask_unit(input wire clk, data_hazard, input wire[7:0] mask_in, input wire[2:0] L_select, output wire[7:0] mask_out);
reg[7:0] mask_reg;
always @(posedge clk)
begin
	if(~data_hazard)
	begin
		case(L_select)
		3'b000: mask_reg <= mask_in;
		3'b001: mask_reg <= {7'h0, mask_in[0]};
		3'b010: mask_reg <= {6'h0, mask_in[1:0]};
		3'b011: mask_reg <= {5'h0, mask_in[2:0]};
		3'b100: mask_reg <= {4'h0, mask_in[3:0]};
		3'b101: mask_reg <= {3'h0, mask_in[4:0]};
		3'b110: mask_reg <= {2'b0, mask_in[5:0]};
		3'b111: mask_reg <= {1'b0, mask_in[6:0]};
		endcase
	end
end
assign mask_out = mask_reg;
endmodule
