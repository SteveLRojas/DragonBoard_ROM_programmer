module right_rotate(input wire clk, data_hazard, input wire[7:0] rotate_in, output wire[7:0] rotate_out, input wire[2:0] R);
reg[7:0] rotate_reg;

always @(posedge clk)
begin
	if(~data_hazard)
	begin
		case(R)
		3'b000: rotate_reg <= rotate_in;
		3'b001: rotate_reg <= {rotate_in[0], rotate_in[7:1]};
		3'b010: rotate_reg <= {rotate_in[1:0], rotate_in[7:2]};
		3'b011: rotate_reg <= {rotate_in[2:0], rotate_in[7:3]};
		3'b100: rotate_reg <= {rotate_in[3:0], rotate_in[7:4]};
		3'b101: rotate_reg <= {rotate_in[4:0], rotate_in[7:5]};
		3'b110: rotate_reg <= {rotate_in[5:0], rotate_in[7:6]};
		3'b111: rotate_reg <= {rotate_in[6:0], rotate_in[7]};
		endcase
	end
end
assign rotate_out = rotate_reg;
endmodule
