module sram(
	input logic [5:0] ramaddr,
	input logic [7:0] ramin,
	input logic rwbar,
	input logic clk,
	input logic cs,
	output logic [7:0] ramout
);

logic [7:0] ram [0:63];
logic [5:0] addr_reg;

always_ff @(posedge clk) begin
	if(cs == 1) begin
	if (rwbar == 0) begin
		ram[ramaddr] <= ramin;
		
	end
	addr_reg <= ramaddr;
	end
end

always_comb begin
	if (cs == 1 && rwbar == 1)
		ramout = ram[addr_reg];
	else
		ramout = 8'b0;
end

endmodule
