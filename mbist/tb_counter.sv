module tb_counter();

logic [3:0] d_in;
logic clk;
logic ld;
logic u_d;
logic cen;
logic [3:0] q;
logic cout;

counter #(.length(4)) DUT(.*);

initial clk = 0;
always #5 clk = ~clk;

initial begin
	clk = 0;

	cen = 1; ld = 1; u_d = 1; 
	d_in = 4'b1010;
	@(posedge clk);
	#1;
	if (q !== 4'b1010 || cout !== 0) begin
		$display("@@@FAIL");
		$finish();
	end

	
	cen = 1; ld = 0; u_d = 1;
	d_in = 4'b1010;
	@(posedge clk);
	#1;
	if (q !== 4'b1011 || cout !== 0) begin
		$display("@@@FAIL");
		$finish();
	end

	cen = 0; ld = 0; u_d = 1;
	@(posedge clk);
	#1;
	if (q !== 4'b1011 || cout !== 0) begin
		$display("@@@FAIL");
		$finish();
	end

	cen = 1; ld = 0; u_d = 0;
	@(posedge clk);
	#1;
	if (q !== 4'b1010 || cout !==0) begin
		$display("@@@FAIL");
		$finish();
	end

	cen = 1; ld = 1; d_in = 4'b1111;
	@(posedge clk);
	#1;
	ld = 0; u_d = 1;
	@(posedge clk);
	#1;
	if(q !== 4'b0 || cout !== 1) begin
		$display("@@@FAIL");
		$finish();
	end

	cen = 1; ld = 1; d_in = 4'b0;
	@(posedge clk);
	#1;
	ld = 0; u_d = 0;
	@(posedge clk);
	#1;
	if (q !== 4'b1111 || cout !== 1) begin
		$display("@@@FAIL");
		$finish();
	end

	$display("@@@PASS");
	$finish();
end
endmodule
