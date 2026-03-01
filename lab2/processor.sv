module mux32(
	input logic [31:0] a,
	input logic [31:0] b,
	input logic sel,
	output logic [31:0] y
);

always_comb begin
	y = b;
	if (sel)
		y = a;
end
endmodule 


module status_reg(
	input logic clk,
	input logic rstN,
	input logic int_en,
	input logic zero,
	input logic carry,
	input logic neg,
	input logic [1:0] parity,
	output logic [7:0] status
);

always_ff @(posedge clk) begin

	if (!rstN)
		status <= 8'h60;
	else begin
		status[7] <= int_en;
		status[6] <= 1'b1;
		status[5] <= 1'b1;
		status[4] <= zero;
		status[3] <= carry;
		status[2] <= neg;
		status[1:0] <= parity;
	end
end

endmodule


module Pri_En(
	input logic[7:0] D,
	output logic[2:0] Q
);

always_comb begin
	Q = 3'b000;
	if (D[7]) Q = 3'b111;
	else if (D[6]) Q = 3'b110;
	else if (D[5]) Q = 3'b101;
	else if (D[4]) Q = 3'b100;
	else if (D[3]) Q = 3'b011;
	else if (D[2]) Q = 3'b010;
	else if (D[1]) Q = 3'b001;
	else Q = 3'b000;	
end
endmodule

module processor(
	input logic clk,
	input logic rstN,
	input logic [31:0] data_in,
	input logic [31:0] i_data,
	input logic data_select,
	input logic [15:0] status_flags,
	output logic [31:0] data_out,
	output logic [7:0] status,
	output logic [2:0] Q
);


mux32 mux(.a(data_in),.b(i_data),.sel(data_select),.y(data_out));
Pri_En encoder(.D(status_flags[15:8]),.Q(Q));
status_reg register(.clk(clk),.rstN(rstN),.int_en(status_flags[7]),.zero(status_flags[4]),.carry(status_flags[3]),.neg(status_flags[2]),.parity(status_flags[1:0]),.status(status));

endmodule
