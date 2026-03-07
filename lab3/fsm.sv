`include "fsm_pkg.svh"
import fsm10_pkg::*;

module fsm(
	input logic rst_n, 
	input logic clk,
	input logic jmp,
	input logic go,
	output logic y,
	output state_e state
);

state_e next_state;
always_ff @(posedge clk or negedge rst_n) begin

	if (!rst_n)
		state <= S0;
	else
		state <= next_state;
end

always_comb begin
	next_state = state;
	unique case (state)
	S0: begin
		if (!go)
			next_state = S0;
		else if (!jmp)
			next_state = S1;
		else next_state = S3;
	end
	
	S1: begin
		if (jmp)
			next_state = S3;
		else next_state = S2;
	end

	S2: begin
		next_state = S3;
	end

	S3: begin
		if (!jmp)
			next_state = S4;
	end

	S4: begin
		if (jmp)
			next_state = S3;
		else next_state = S5;
	end 

	S5: begin
                if (jmp)
                        next_state = S3;
                else next_state = S6;
        end

	S6: begin
                if (jmp)
                        next_state = S3;
                else next_state = S7;
        end

	S7: begin
                if (jmp)
                        next_state = S3;
                else next_state = S8;
        end

	S8: begin
                if (jmp)
                        next_state = S3;
                else next_state = S9;
        end

	S9: begin
                if (jmp)
                        next_state = S3;
                else next_state = S0;
        end



	



	endcase 
end

always_comb begin
if (state == S3)
	y = 1;
else y = 0;
end

endmodule
