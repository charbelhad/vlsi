//Implement a traffic controller 
//Moore FSM with 2 directions: North-South and East-West
//00: RED, 01: YELLOW, 10: GREEN
module traffic_light_controller(
	input logic clk,
	input logic reset,
	output logic [1:0] light_NS,
	output logic [1:0] light_EW
);

logic [1:0] next_NS;
logic [1:0] next_EW;

//define enum to store states
typedef enum logic [2:0]{
	ALL_RED,
	NS_GREEN,
	NS_YELLOW,
	EW_GREEN,
	EW_YELLOW
} state_e;

state_e state;
state_e next_state;
always_ff @(posedge clk or posedge reset)
begin

	if (reset)
		state <= ALL_RED;
	else 
		state <= next_state;
end

always_comb begin
next_state = state;
light_NS = 2'b00;
light_EW = 2'b00;
	unique case (state)
	//uupdate next state, assign output
	ALL_RED: begin
		next_state = NS_GREEN;
		light_NS = 2'b00;
		light_EW = 2'b00;
	end
	
	NS_GREEN: begin
		next_state = NS_YELLOW;
		light_NS = 2'b10;
		light_EW = 2'b00;
	end

	NS_YELLOW: begin
		next_state = EW_GREEN;
		light_NS = 2'b01;
		light_EW = 2'b00;
	end 

	EW_GREEN: begin
		next_state = EW_YELLOW;
		light_NS = 2'b00;
		light_EW = 2'b10;
	end

	EW_YELLOW: begin
		next_state = NS_GREEN;
		light_NS = 2'b00;
		light_EW = 2'b01;
	end

	endcase
	
end





endmodule
