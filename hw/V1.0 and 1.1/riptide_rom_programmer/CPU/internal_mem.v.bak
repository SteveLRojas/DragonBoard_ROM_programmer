module reg_file(input wire clk, data_hazard, wren, input wire[2:0] a_address, w_address, input wire[7:0] w_data, output wire[7:0] a_data, b_data);
reg[7:0] a_reg;
(* ramstyle = "logic" *) reg[7:0] rfile[7:0];
always @(posedge clk)
begin
	if(~data_hazard)
	begin
		if(wren)
			rfile[w_address] <= w_data;
		a_reg <= rfile[a_address];
	end
end
assign a_data = a_reg;
assign b_data = rfile[0];
endmodule

module call_stack(input wire rst, clk, push, pop, input wire[15:0] data_in, output wire[15:0] data_out);
reg[2:0] address;
reg[15:0] input_buf;
reg[15:0] output_buf;
reg prev_push;
(* ramstyle = "logic" *) reg[15:0] stack_mem[7:0];

always @(posedge clk)
begin
	input_buf <= data_in;
	prev_push <= push;
	output_buf <= stack_mem[address];
	if(prev_push)
		stack_mem[address] <= input_buf;
	if(rst)
		address <= 3'b000;
	else if(push | pop)
		address <= address + {{2{pop}}, 1'b1};
end
assign data_out = output_buf;
endmodule
