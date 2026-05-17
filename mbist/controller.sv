module controller(
	input logic start,
	input logic rst,
	input logic clk,
	input logic cout,
	output logic NbarT,
	output logic ld
);

typedef enum logic {
	RESET, 
	TEST
} state_t;

state_t current_state, next_state;

always_ff @(posedge clk) begin
	if (rst)
		current_state <= RESET;

	else 
		current_state <= next_state;
end

always_comb begin
	case (current_state)

		RESET: begin
			ld = 1;
			NbarT = 0;
			if (start == 1)
				next_state = TEST;
			else next_state = RESET;
		end
		TEST: begin
			ld = 0;
			NbarT = 1;
			if (cout == 1) 
				next_state = RESET;
			else next_state = TEST;

		end

		default: begin
			ld = 1;
			NbarT = 0;
			next_state = RESET;
		end

	endcase

end

endmodule
