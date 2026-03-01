//`timescale 1ns/1ps

module pri_en_tb();

logic [3:0] I;
logic [1:0] Y;
pri_en DUT(.*);



initial begin

I = 4'b0000; 
#5
if (Y !== 2'b00) begin
	$display("@@@FAIL");
	$finish();
end

I = 4'b0001;
#5
if (Y !== 2'b00) begin
        $display("@@@FAIL");
        $finish();
end

I = 4'b0010;
#5
if (Y !== 2'b01) begin
        $display("@@@FAIL");
        $finish();
end

I = 4'b0011;
#5
if (Y !== 2'b01) begin
        $display("@@@FAIL");
        $finish();
end

I = 4'b0100;
#5
if (Y !== 2'b10) begin
        $display("@@@FAIL");
        $finish();
end

I = 4'b0101;
#5
if (Y !== 2'b10) begin
        $display("@@@FAIL");
        $finish();
end

I = 4'b0110;
#5
if (Y !== 2'b10) begin
        $display("@@@FAIL");
        $finish();
end

I = 4'b0111;
#5
if (Y !== 2'b10) begin
        $display("@@@FAIL");
        $finish();
end

I = 4'b1000;
#5
if (Y !== 2'b11) begin
        $display("@@@FAIL");
        $finish();
end

I = 4'b1001;
#5
if (Y !== 2'b11) begin
        $display("@@@FAIL");
        $finish();
end

I = 4'b1010;
#5
if (Y !== 2'b11) begin
        $display("@@@FAIL");
        $finish();
end

I = 4'b1011;
#5
if (Y !== 2'b11) begin
        $display("@@@FAIL");
        $finish();
end

I = 4'b1100;
#5
if (Y !== 2'b11) begin
        $display("@@@FAIL");
        $finish();
end

I = 4'b1101;
#5
if (Y !== 2'b11) begin
        $display("@@@FAIL");
        $finish();
end

I = 4'b1110;
#5
if (Y !== 2'b11) begin
        $display("@@@FAIL");
        $finish();
end

I = 4'b1111;
#5
if (Y !== 2'b11) begin
        $display("@@@FAIL");
        $finish();
end

$display("@@@PASS");
$finish();
end

//initial begin
//	$fsdbDumpfile("dump.fsdb");
//	$fsdbDumpvars;
//end

endmodule

