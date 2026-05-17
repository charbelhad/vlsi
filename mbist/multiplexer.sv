module multiplexer #(
       parameter int WIDTH
)(
 	input logic [WIDTH - 1:0] normal_in,
	input logic [WIDTH - 1:0] bist_in,
	input logic NbarT,
	output logic [WIDTH - 1:0] out
	);

always_comb begin

	if (NbarT == 0)
		out = normal_in;
	else if (NbarT == 1)
		out = bist_in;
end

endmodule
