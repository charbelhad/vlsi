`include "fsm_pkg.svh"
import fsm10_pkg::*;

module fsm_tb;

logic rst_n;
logic clk;
logic jmp;
logic go;
logic y;
state_e state;

fsm DUT(.*);

initial clk = 0;
always #5 clk = ~clk;

task automatic check_state(input state_e expected_state, input logic expected_y);
begin
	if (state !== expected_state || y !== expected_y) begin
		$display("@@@FAIL");
		$finish();
	end
end
endtask

task automatic do_reset;
begin
	rst_n = 0; 
	#1;
	check_state(S0,0);
	#1;
	rst_n = 1;
end
endtask

initial begin

rst_n = 1; go = 0; jmp = 0; 
//rst_n = 0, stays in S0
#2; rst_n = 0; 
#1;
check_state(S0, 0);
#5;

//release rst_n
rst_n = 1; go = 0; jmp = 0;
@(posedge clk);
//go = 0, stays in S0
#1;
check_state(S0,0);

//go = 1, goes to S1
go = 1; jmp = 0;
@(posedge clk);
#1;
check_state(S1, 0);

@(posedge clk);
#1;
check_state(S2, 0);

//S2 -> S3 not dependent on jmp = 0
jmp = 1;
@(posedge clk);
#1; 
check_state(S3, 1);

//S3 -> S4
jmp = 0;
@(posedge clk);
#1; 
check_state(S4,0);

//S4 -> S5
@(posedge clk);
#1;
check_state(S5, 0);

//S5->S6
@(posedge clk);
#1;
check_state(S6, 0);

//S6 -> S7
@(posedge clk);
#1;
check_state(S7,0);

//S7->S8
@(posedge clk);
#1;
check_state(S8,0);

//S8 -> S9
@(posedge clk);
#1;
check_state(S9,0);

//S9 -> S0
@(posedge clk);
#1;
check_state(S0,0);

//check each state -> S3
//S0 to S3
do_reset(); jmp = 1; go = 1;
@(posedge clk); #1; check_state(S3,1);

//check it stays in S3;
@(posedge clk); #1; check_state(S3, 1);

//S1 to S3;
do_reset(); jmp = 0; go = 1; 
@(posedge clk); #1; check_state(S1, 0);
jmp = 1; 
@(posedge clk); #1; check_state(S3, 1);

//S2 to S3;
do_reset(); jmp = 0; go = 1;
@(posedge clk); #1; check_state(S1, 0);
@(posedge clk); #1; check_state(S2, 0);
jmp = 1;
@(posedge clk); #1; check_state(S3, 1);

//S4 to S3;
do_reset(); jmp = 0; go = 1;
@(posedge clk); #1; check_state(S1, 0);
@(posedge clk); #1; check_state(S2, 0);
@(posedge clk); #1; check_state(S3, 1);
@(posedge clk); #1; check_state(S4, 0);
jmp = 1;
@(posedge clk); #1; check_state(S3, 1);

//S5 to S3;
do_reset(); jmp = 0; go = 1;
@(posedge clk); #1; check_state(S1, 0);
@(posedge clk); #1; check_state(S2, 0);
@(posedge clk); #1; check_state(S3, 1);
@(posedge clk); #1; check_state(S4, 0);
@(posedge clk); #1; check_state(S5, 0);
jmp = 1;
@(posedge clk); #1; check_state(S3, 1);

//S6 to S3;
do_reset(); jmp = 0; go = 1;
@(posedge clk); #1; check_state(S1, 0);
@(posedge clk); #1; check_state(S2, 0);
@(posedge clk); #1; check_state(S3, 1);
@(posedge clk); #1; check_state(S4, 0);
@(posedge clk); #1; check_state(S5, 0);
@(posedge clk); #1; check_state(S6, 0);
jmp = 1;
@(posedge clk); #1; check_state(S3, 1);

//S7 to S3;
do_reset(); jmp = 0; go = 1;
@(posedge clk); #1; check_state(S1, 0);
@(posedge clk); #1; check_state(S2, 0);
@(posedge clk); #1; check_state(S3, 1);
@(posedge clk); #1; check_state(S4, 0);
@(posedge clk); #1; check_state(S5, 0);
@(posedge clk); #1; check_state(S6, 0);
@(posedge clk); #1; check_state(S7,0);
jmp = 1;
@(posedge clk); #1; check_state(S3, 1);

//S8 to S3
do_reset(); jmp = 0; go = 1;
@(posedge clk); #1; check_state(S1, 0);
@(posedge clk); #1; check_state(S2, 0);
@(posedge clk); #1; check_state(S3, 1);
@(posedge clk); #1; check_state(S4, 0);
@(posedge clk); #1; check_state(S5, 0);
@(posedge clk); #1; check_state(S6, 0);
@(posedge clk); #1; check_state(S7,0);
@(posedge clk); #1; check_state(S8,0);
jmp = 1;
@(posedge clk); #1; check_state(S3, 1);

//S9 to S3
do_reset(); jmp = 0; go = 1;
@(posedge clk); #1; check_state(S1, 0);
@(posedge clk); #1; check_state(S2, 0);
@(posedge clk); #1; check_state(S3, 1);
@(posedge clk); #1; check_state(S4, 0);
@(posedge clk); #1; check_state(S5, 0);
@(posedge clk); #1; check_state(S6, 0);
@(posedge clk); #1; check_state(S7,0);
@(posedge clk); #1; check_state(S8,0);
@(posedge clk); #1; check_state(S9,0);
jmp = 1;
@(posedge clk); #1; check_state(S3, 1);


$display("@@@PASS");
$finish();







end

endmodule 
