module test
#(parameter N = 4)
 (output logic [N-1:0]  a, b,
  output logic sel,
  input logic [N-1:0] y
 );
timeunit 1ns/1ns;

initial begin: fsdb_dump
 $fsdbDumpfile("dump.fsdb");
 $fsdbDumpvars;
end: fsdb_dump
initial begin: gen_stimuli
	a = 0;
	b = 0;
	sel = 1;
	#10 a = 1;
	#20 sel = 0;
	#10 b = 1;
	#20 b = 0;
	$finish;
end: gen_stimuli

initial begin: monitor
 $monitor("At %t: \t sel=%b a=%b b=%b y=%b",$realtime, sel, a, b, y);
end: monitor
endmodule: test

module top;
 timeunit 1ns/1ns;
 parameter N = 4;
 logic sel;
 logic [N-1:0] a, b;
 logic [N-1:0] y;

 mux2to1 #(.N(N)) dut(.*);
 test #(.N(N)) test1(.*);
 endmodule: top
