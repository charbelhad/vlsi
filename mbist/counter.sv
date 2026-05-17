module counter #(
	parameter int length = 10
)(
	input logic [length-1:0] d_in,
	input logic clk,
	input logic ld,
	input logic u_d,
	input logic cen,
	output logic [length-1:0] q,
	output logic cout);

always_ff @(posedge clk)
begin
	cout <= 1'b0;
	
	if (cen == 1) begin

		if (ld == 1) begin
		q <= d_in;
		cout <= 1'b0;
		end

		else if (u_d == 1) begin
			if (q == {length{1'b1}})
				cout <= 1'b1;
			q <= q + 1'b1;
		end

		else if(u_d == 0) begin
			if (q == {length{1'b0}})
				cout <= 1'b1;
			q <= q-1'b1;
		end

	end		
end

endmodule
