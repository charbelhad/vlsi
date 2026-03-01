module rtl_4bit_adder(
	input logic [3:0] a,
	input logic [3:0] b,
	input logic cin,
	output logic [3:0] s,
	output logic cout
);
    logic [4:0] temp;

    always_comb begin
    temp = a + b + cin; 
    s = temp[3:0];
    cout = temp[4];
    end
endmodule


module rtl_16bit_adder(
	input logic [15:0] a,
	input logic [15:0] b,
	input logic cin,
	output logic [15:0] s,
	output logic cout
);
    logic [2:0] temp_cout;
    rtl_4bit_adder adder1(.a(a[3:0]), .b(b[3:0]), .cin(cin), .s(s[3:0]), .cout(temp_cout[0]));
    rtl_4bit_adder adder2(.a(a[7:4]), .b(b[7:4]), .cin(temp_cout[0]), .s(s[7:4]), .cout(temp_cout[1]));
    rtl_4bit_adder adder3(.a(a[11:8]), .b(b[11:8]), .cin(temp_cout[1]), .s(s[11:8]), .cout(temp_cout[2]));
    rtl_4bit_adder adder4(.a(a[15:12]), .b(b[15:12]), .cin(temp_cout[2]), .s(s[15:12]), .cout(cout));
endmodule
