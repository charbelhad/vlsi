module tb_multiplexer();

logic [5:0] normal_in, bist_in, out;
logic NbarT;

multiplexer #(.WIDTH(6)) DUT(.*);

initial begin
	bist_in = 6'b101010;
	normal_in = 6'b010101;
	NbarT = 0;
	#2;
	if (out !== 6'b010101) begin
		$display("@@@FAIL");
		$finish();
	end

	NbarT = 1;
	#2;
	if(out !== 6'b101010) begin
		$display("@@@FAIL");
		$finish();
	end

	$display("@@@PASS");
	$finish();
end
endmodule
