module right_rotate(input wire clk, data_hazard, input wire[7:0] regf_in, IO_in, output wire[7:0] rotate_out, input wire[2:0] S0, R, input wire source);
wire[2:0] selector;
wire[7:0] selected;
reg[7:0] rotate_reg;
assign selector = (source) ? ~S0 : R;
assign selected = (source) ? IO_in : regf_in;
always @(posedge clk)
begin
	if(~data_hazard)
	begin
		case(selector)
		3'b000: rotate_reg <= selected;
		3'b001: rotate_reg <= {selected[0], selected[7:1]};
		3'b010: rotate_reg <= {selected[1:0], selected[7:2]};
		3'b011: rotate_reg <= {selected[2:0], selected[7:3]};
		3'b100: rotate_reg <= {selected[3:0], selected[7:4]};
		3'b101: rotate_reg <= {selected[4:0], selected[7:5]};
		3'b110: rotate_reg <= {selected[5:0], selected[7:6]};
		3'b111: rotate_reg <= {selected[6:0], selected[7]};
		endcase
	end
end
assign rotate_out = rotate_reg;
endmodule
