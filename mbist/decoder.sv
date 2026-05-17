module decoder(
	input logic [2:0] q,
	output logic [7:0] data_t
);

always_comb begin
	if (q == 3'b000)
		data_t = 8'b10101010;
	else if (q == 3'b001)
		data_t = 8'b01010101;
	else if (q == 3'b010)
		data_t = 8'b11110000;
	else if (q == 3'b011)
		data_t = 8'b00001111;
	else if (q == 3'b100)
		data_t = 8'b00000000;
	else if (q == 3'b101)
		data_t = 8'b11111111;
	else 
		data_t = 8'bxxxxxxxx;
end
endmodule
