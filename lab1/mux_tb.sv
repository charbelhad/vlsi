//`timescale 1ns/1ps
module mux_tb();

logic en;
logic sel;
logic [3:0] D0;
logic [3:0] D1;
logic [3:0] Y;

mux DUT(.*);

initial begin

en = 0; sel = 0; D0 = '1; D1 = '1;
#5
if (Y !== '0) begin
	$display("@@@FAIL");
	$finish();
end

en = 1; sel = 0; D0 = 4'b1000; D1 = '1;
#5
if(Y !== D0) begin
	$display("@@@FAIL");
	$finish(); end

en = 1; sel = 1; D0 = 4'b1000; D1 = '1;
#5
if(Y!==D1) begin
	$display("@@@FAIL");
	$finish(); end

$display("@@@PASS");
$finish();

end

//initial begin
//	$fsdbDumpfile("dump.fsdb");
//	$fsdbDumpvars;
//end

endmodule
