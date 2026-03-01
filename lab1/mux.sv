//`timescale 1ns/1ps
module mux(
	input logic en,
	input logic sel,
	input logic [3:0] D0,
	input logic [3:0] D1,
	output logic [3:0] Y
);

always_comb begin

	if (!en) Y = '0;
	else begin
		if (!sel) Y = D0;
		else if (sel) Y = D1;
		else Y = '0; //for X or Z
		end
end

endmodule
