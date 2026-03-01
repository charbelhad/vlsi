module mux2to1
#(parameter N = 4)
 (input logic sel,
  input logic [N-1:0] a, b,
  output logic [N-1:0] y
);
 timeunit 1ns/1ns;

 always_comb begin: logic_code
	 if (sel) y=a;
	 else y = b;
 end: logic_code
endmodule: mux2to1
