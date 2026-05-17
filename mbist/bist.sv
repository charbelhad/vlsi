module bist #(
	parameter int size = 6, 
	parameter int length = 8
)(
	input logic start,
	input logic rst,
	input logic clk,
	input logic csin, 
	input logic rwbarin,
	input logic opr,
	input logic [size-1:0] address,
	input logic [length-1:0] datain,
	output logic [length-1:0] dataout,
	output logic fail
);

//init counter and controller
logic [9:0] counter_in = 10'b0;
logic cen = 1;
logic [9:0] q;
logic u_d = 1;
logic ld;
logic cout;
logic NbarT;

counter #(.length(10)) BIST_counter(
	.d_in(counter_in), 
	.clk(clk), 
	.ld(ld), 
	.u_d(u_d), 
	.cen(cen), 
	.q(q), 
	.cout(cout)
);

controller BIST_controller(
	.start(start), 
	.rst(rst), 
	.clk(clk), 
	.cout(cout), 
	.NbarT(NbarT), 
	.ld(ld)
);

//init decoder
logic [length-1:0] data_t;
decoder BIST_decoder(.q(q[9:7]), .data_t(data_t));

//init sram
logic [size-1:0] ramaddr;
logic [length-1:0] ramin;
logic rwbar, cs;


//init the muxes
multiplexer #(.WIDTH(length)) MUX_D(
	.normal_in(datain), 
	.bist_in(data_t), 
	.NbarT(NbarT), 
	.out(ramin)
);

multiplexer #(.WIDTH(size)) MUX_A(
	.normal_in(address), 
	.bist_in(q[5:0]), 
	.NbarT(NbarT), 
	.out(ramaddr)
);

multiplexer #(.WIDTH(1)) MUX_RW(
	.normal_in(rwbarin), 
	.bist_in(q[6]), 
	.NbarT(NbarT),  
	.out(rwbar)
);

multiplexer #(.WIDTH(1)) MUX_CS(
	.normal_in(csin), 
	.bist_in(1'b1), 
	.NbarT(NbarT), 
	.out(cs)
);

sram BIST_sram(
	.ramaddr(ramaddr[5:0]), 
	.ramin(ramin[7:0]), 
	.rwbar(rwbar), 
	.clk(clk), 
	.cs(cs),
       	.ramout(dataout[7:0])
);


//comparator
logic lt, gt, eq;

comparator BIST_comparator(
	.data_t(data_t),
	.ramout(dataout[7:0]),
	.gt(gt),
	.eq(eq),
	.lt(lt)
);

always_ff @(posedge clk) begin
	fail <= NbarT && q[6] && !eq && opr;
end

endmodule
