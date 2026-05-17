module tb_sram();

logic [5:0] ramaddr;
logic [7:0] ramin;
logic rwbar;
logic clk;
logic cs;
logic [7:0] ramout;
sram DUT(.*);

initial clk = 0;
always #5 clk = ~clk;

initial begin

cs = 1;
rwbar = 0;
ramin = 8'h5F;
ramaddr = 6'b101100;

@(posedge clk); #2;
if (ramout !== 8'b0) begin
	$display("@@@FAIL");
	$finish();
end

rwbar = 1;

@(posedge clk); #2;
if (ramout !== 8'h5F) begin
	$display("@@@FAIL");
	$finish();
end

rwbar = 0; ramin = 8'h23;
@(posedge clk); #2;
if(ramout !== 8'h00) begin
	$display("@@@FAIL");
	$finish();
end

rwbar = 1;
@(posedge clk); #2;
if (ramout !== 8'h23) begin
	$display("@@@FAIL");
	$finish();
end

cs = 0;
@(posedge clk); #2;
if (ramout !== 8'b0) begin
	$display("@@@FAIL");
	$finish();
end

$display("@@@PASS");
$finish();
end
endmodule
