module reg_file(
			input wire clk,
			input wire data_hazard,
			input wire wren,
			input wire[3:0] a_address,
			input wire[3:0] w_address,
			input wire[7:0] w_data,
			output wire[7:0] a_data,
			output wire[7:0]aux_data,
			output wire[7:0] ivr, ivl);
reg[7:0] a_reg;
reg[7:0] aux, r1, r2, r3, r4, r5, r6, r11, r12, r13, r14, r15, r16, ivl_reg, ivr_reg;
reg[3:0] prev_w_address;
reg[3:0] prev_a_address;
reg[7:0] prev_w_data;
reg prev_wren;

initial
begin
	ivl_reg = 8'h00;	//actual value does not matter, but it must be defined so that the cache controller is not stuck in a miss state.
	ivr_reg = 8'h00;
end

wire aux_forward;
wire a_forward0;
wire a_forward1;
assign aux_forward = (w_address == 4'h0) & wren;
assign a_forward0 = (w_address == prev_a_address) & wren;
assign a_forward1 = (prev_w_address == prev_a_address) & prev_wren;

always @(posedge clk)
begin
	//write logic
	if(~data_hazard)
	begin
		prev_w_address <= w_address;
		prev_a_address <= a_address;
		prev_w_data <= w_data;
		prev_wren <= wren;
		if(wren)
		begin
			case(w_address)
			4'b0000: aux <= w_data;
			4'b0001: r1 <= w_data;
			4'b0010: r2 <= w_data;
			4'b0011: r3 <= w_data;
			4'b0100: r4 <= w_data;
			4'b0101: r5 <= w_data;
			4'b0110: r6 <= w_data;
			4'b0111: ivl_reg <= w_data;
			4'b1000: ;	//OVF
			4'b1001: r11 <= w_data;
			4'b1010: r12 <= w_data;
			4'b1011: r13 <= w_data;
			4'b1100: r14 <= w_data;
			4'b1101: r15 <= w_data;
			4'b1110: r16 <= w_data;
			4'b1111: ivr_reg <= w_data;
			endcase
		end
		//read logic
		case(a_address)
		4'b0000: a_reg <= aux;
		4'b0001: a_reg <= r1;
		4'b0010: a_reg <= r2;
		4'b0011: a_reg <= r3;
		4'b0100: a_reg <= r4;
		4'b0101: a_reg <= r5;
		4'b0110: a_reg <= r6;
		4'b0111: a_reg <= ivl_reg;	//IVL
		4'b1000: a_reg <= 8'hxx;	//OVF
		4'b1001: a_reg <= r11;
		4'b1010: a_reg <= r12;
		4'b1011: a_reg <= r13;
		4'b1100: a_reg <= r14;
		4'b1101: a_reg <= r15;
		4'b1110: a_reg <= r16;
		4'b1111: a_reg <= ivr_reg;	//IVR
		endcase
	end
end
assign ivl = ivl_reg;
assign ivr = ivr_reg;
assign a_data = a_forward0 ? w_data : (a_forward1 ? prev_w_data : a_reg);
assign aux_data = aux_forward ? w_data : aux;
endmodule

module call_stack(input wire rst, clk, push, pop, input wire[15:0] data_in, output wire[15:0] data_out);
reg[3:0] address;
reg[15:0] input_buf;
reg[15:0] output_buf;
reg prev_push;
(* ramstyle = "logic" *) reg[15:0] stack_mem[15:0];

always @(posedge clk)
begin
	input_buf <= data_in;
	prev_push <= push;
	output_buf <= stack_mem[address];
	if(prev_push)
		stack_mem[address] <= input_buf;
	if(rst)
		address <= 4'b0000;
	else if(push | pop)
		address <= address + {{3{pop}}, 1'b1};
end
assign data_out = output_buf;
endmodule
