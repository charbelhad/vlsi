module comparator(
	input logic [7:0] data_t,
	input logic [7:0] ramout,
	output logic gt,
	output logic eq,
	output logic lt
);

always_comb begin
	if (data_t > ramout) begin
		gt = 1;
		eq = 0;
		lt = 0;
	end

	else if (data_t < ramout) begin
		gt = 0;
		eq = 0;
		lt = 1;
	end

	else if (data_t == ramout) begin
		gt = 0;
		eq = 1;
		lt = 0;
	end

end

endmodule
