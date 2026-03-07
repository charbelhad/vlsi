module traffic_light_controller_tb;

logic clk;
logic reset;
logic [1:0] light_NS;
logic [1:0] light_EW;

traffic_light_controller DUT(.*); 

initial clk = 0;
always #5 clk = ~clk;

//write task to detect failure 
task automatic check_state(input logic [1:0] expected_NS, input logic [1:0] expected_EW);
begin 
if (expected_NS !== light_NS || expected_EW !== light_EW) begin
	$display("@@@FAIL");
	$finish();
end
end
endtask


initial begin

//set reset;
reset = 1'b1;
#2;
//check that FSM is all red
check_state(2'b00, 2'b00);

//release reset
reset = 1'b0; #2;

//now go through all FSM
//NS Green, EW Red
@(posedge clk); #1; 
check_state(2'b10, 2'b00);

//NS Yellow, EW Red
@(posedge clk); #1;
check_state(2'b01, 2'b00);

//NS Red, EW Green
@(posedge clk); #1;
check_state(2'b00, 2'b10);

//NS Red, EW Yellow
@(posedge clk); #1;
check_state(2'b00, 2'b01);

//NS Green, EW Red
@(posedge clk); #1;
check_state(2'b10, 2'b00);

//check it goes back to all red
reset = 1'b1; #2;
check_state(2'b00, 2'b00);

$display("@@@PASS");
$finish();
end




endmodule
