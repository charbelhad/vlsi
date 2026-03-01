//`timescale 1ns/1ps
module pri_en(
	input logic [3:0] I,
	output logic [1:0] Y
);

always_comb begin

	if (I[3]) Y=2'b11;
	else if (I[2]) Y=2'b10;
	else if (I[1]) Y=2'b01;
	else Y = '0;
end
endmodule


