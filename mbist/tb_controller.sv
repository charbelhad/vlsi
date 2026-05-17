module tb_controller();

logic start, rst, clk, cout, NbarT, ld;
controller DUT(.*);

initial clk = 0;
always #5 clk = ~clk;

initial begin

	start = 0; rst = 1; cout = 0;
	@(posedge clk);
	#2;
	if (ld !== 1 || NbarT !== 0) begin
		$display("@@@FAIL");
		$finish();
	end

	rst = 0;
	@(posedge clk); #2;
	if (ld !== 1 || NbarT !== 0) begin
		$display("@@@FAIL");
		$finish();
	end

	start = 1; cout = 0;
	@(posedge clk); #2; 
	if (NbarT !== 1 || ld !== 0) begin
		$display("@@@FAIL");
		$finish();
	end

	start = 0; cout = 0;
	@(posedge clk); #2; 
	if (NbarT !== 1 || ld !== 0) begin
		$display("@@@FAIL");
		$finish();
	end

	cout = 1;
	@(posedge clk); #2;
	if (ld !== 1 || NbarT !== 0) begin
		$display("@@@FAIL");
		$finish();
	end

	start = 1; cout = 0;
	@(posedge clk); #2; 
	if (ld !== 0 || NbarT !== 1) begin
		$display("@@@FAIL");
		$finish();
	end

	rst = 1;
	@(posedge clk);	#2;
	if (ld !== 1 || NbarT !== 0) begin
		$display("@@@FAIL");
		$finish();
	end

	$display("@@@PASS");
	$finish();

	
end
endmodule

