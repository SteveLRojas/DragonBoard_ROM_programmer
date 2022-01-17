module PC(
		input wire clk,
		input wire NZT4,
		input wire XEC4,
		input wire JMP,
		input wire CALL4,
		input wire RET,
		//input wire decoder_RST,
		input wire RST,
		input wire ALU_NZ,
		input wire hazard,
		input wire data_hazard,
		input wire branch_hazard,
		input wire p_cache_miss,
		input wire long_I,
		input wire[7:0] ALU_data,
		input wire[12:0] PC_I_field,
		input wire[7:0] PC_I_field4,
		output wire[15:0] A);
reg[15:0] A_miss;
reg prev_hazard;
reg prev_p_cache_miss;
//reg[7:0] PC_I_field1, PC_I_field2, PC_I_field3, PC_I_field4;
reg[15:0] A_next_I;

reg[15:0] A_reg;
reg[15:0] PC_reg;
reg[15:0] A_current_I, A_current_I_alternate, A_pipe0, A_pipe1, A_pipe2, A_pipe3, A_pipe4;

wire[15:0] stack_out;
wire stack_pop = RET & (~branch_hazard) & (~((NZT4 & ALU_NZ) | XEC4) & (~CALL4));
call_stack cstack0(.rst(RST), .clk(clk), .push(CALL4), .pop(stack_pop), .data_in(A_pipe3), .data_out(stack_out));
always @(posedge clk)
begin
	A_next_I <= A_reg;
end
always @(posedge clk or posedge RST)	//reset needs not be asynchronous, but doing this eliminates a mux and improves timing.
begin
	if(RST)
	begin
		prev_hazard <= 1'b0;
		prev_p_cache_miss <= 1'b0;
		A_miss <= 16'h0;
		A_current_I_alternate <= 16'h0000;
		A_current_I <= 16'h0000;
		A_pipe0 <= 16'h0000;
		A_pipe1 <= 16'h0000;
		A_pipe2 <= 16'h0000;
		A_pipe3 <= 16'h0000;
		A_pipe4 <= 16'h0000;
	end
	else
	begin
		prev_p_cache_miss <= p_cache_miss;
		if(~p_cache_miss)
			A_miss <= A_reg;
			
//		if(decoder_RST)
//			prev_hazard <= 1'b0;
//		else
//		begin
			if(~p_cache_miss)
			begin
				prev_hazard <= hazard;
			end
			if(hazard && ~prev_hazard)
				A_current_I_alternate <= A_next_I;
			if(~hazard)
			begin
				if(prev_hazard)
					A_current_I <= A_current_I_alternate;
				else
					A_current_I <= A_next_I;
				A_pipe0 <= A_current_I;
			end
		//end
		
		if(~data_hazard)
		begin
			A_pipe1 <= A_pipe0;
			A_pipe2 <= A_pipe1;
			A_pipe3 <= A_pipe2;
			A_pipe4 <= A_pipe3;
		end
	end
end

always @(posedge clk or posedge RST)
begin
	if(RST)
	begin
		A_reg <= 16'h0;
		PC_reg <= 16'h0;
	end
	else if(CALL4 | ((NZT4 & ALU_NZ) | XEC4) | (RET & (~branch_hazard)) | JMP | (p_cache_miss & ~prev_p_cache_miss) | (~hazard & ~p_cache_miss))
	begin
		if(CALL4)
		begin
			A_reg <= {ALU_data, PC_I_field4};
			PC_reg <= {ALU_data, PC_I_field4};
		end
		else if((NZT4 & ALU_NZ) | XEC4)
		begin
			if(long_I)
				A_reg <= {A_pipe4[15:8], ALU_data};
			else
				A_reg <= {A_pipe4[15:5], ALU_data[4:0]};
			if(XEC4)
				PC_reg <= A_pipe4;
			else if(long_I)
				PC_reg <= {A_pipe4[15:8], ALU_data};
			else
				PC_reg <= {A_pipe4[15:5], ALU_data[4:0]};
		end
		else if(RET & (~branch_hazard))
		begin
			A_reg <= stack_out;
			PC_reg <= stack_out;
		end
		else if(JMP)
		begin
			A_reg <= {A_pipe0[15:13], PC_I_field};
			PC_reg <= {A_pipe0[15:13], PC_I_field};
		end
		else if(p_cache_miss & ~prev_p_cache_miss)
		begin
			A_reg <= A_miss;
			PC_reg <= A_miss;
		end
		else //if(~hazard & ~p_cache_miss)
		begin
			A_reg <= PC_reg + 16'h01;
			PC_reg <= PC_reg + 16'h01;
		end
	end
end

assign A = A_reg;

endmodule
