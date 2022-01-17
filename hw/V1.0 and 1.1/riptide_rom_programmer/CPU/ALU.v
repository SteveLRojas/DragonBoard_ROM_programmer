module ALU(input wire clk, data_hazard, input wire[2:0] op, input wire[7:0] in_a, in_b, output wire[7:0] alu_out, output wire OVF_out);
reg[7:0] alu_reg;
reg OVF_reg;
//reg NZ_reg;
wire[8:0] add_result;
assign add_result = in_a + in_b;
initial
begin
	//NZ_reg = 1'b0;
	OVF_reg = 1'b0;
end
always @(posedge clk)
begin
	if(~data_hazard)
	begin
		case(op)
		3'b000: alu_reg <= in_a;
		3'b001: alu_reg <= add_result[7:0];	//add affecting the overflow flag
		3'b010: alu_reg <= in_a & in_b;
		3'b011: alu_reg <= in_a ^ in_b;
		3'b100: alu_reg <= in_b;
		3'b101: alu_reg <= add_result[7:0];	//add without affecting the overflow flag
		3'b110: alu_reg <= in_a & in_b;
		3'b111: alu_reg <= in_a ^ in_b;
		endcase
//		if(op == 3'b001)
//			OVF_reg <= add_result[8];
	end
	if (~data_hazard && (op == 3'b001))
	begin 	
		OVF_reg <= add_result[8];
	end 
end
assign alu_out = alu_reg;
assign OVF_out = OVF_reg;
endmodule
