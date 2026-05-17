module tb_comparator();

logic [7:0] data_t;
logic [7:0] ramout;
logic gt, eq, lt;

comparator DUT(.*);

initial begin

data_t = 8'h00; ramout = 8'hFF;
#5
if (gt !== 0 || eq !== 0 || lt !== 1) begin
	$display("@@@FAIL");
	$finish();
end

data_t = 8'hFF; ramout = 8'h00;
#5
if (gt !== 1 || eq !== 0 || lt !== 0) begin
        $display("@@@FAIL");
	$finish();
        
end     

data_t = 8'h00; ramout = 8'h00;
#5
if (gt !== 0 || eq !== 1 || lt !== 0) begin
        $display("@@@FAIL");
        $finish();
        
end     

data_t = 8'hFF; ramout = 8'hFF;
#5
if (gt !== 0 || eq !== 1 || lt !== 0) begin
        $display("@@@FAIL");
        $finish();

end

data_t = 8'h55; ramout = 8'h55;
#5
if (gt !== 0 || eq !== 1 || lt !== 0) begin
        $display("@@@FAIL");
        $finish();

end

data_t = 8'h56; ramout = 8'h55;
#5
if (gt !== 1 || eq !== 0 || lt !== 0) begin
        $display("@@@FAIL");
        $finish();

end

data_t = 8'h54; ramout = 8'h55;
#5
if (gt !== 0 || eq !== 0 || lt !== 1) begin
        $display("@@@FAIL");
        $finish();

end


$display("@@@PASS");
$finish();
end
endmodule
