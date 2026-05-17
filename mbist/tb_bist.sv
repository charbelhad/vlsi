module tb_bist();

logic start, rst, clk, csin, rwbarin, opr;
logic [5:0] address;
logic [7:0] datain;
logic [7:0] dataout;
logic fail;

bist #(.size(6), .length(8)) DUT(.*);

initial clk = 0;
always #5 clk = ~clk;
initial begin
	start = 0;
	rst = 1;
	csin = 0;
	rwbarin = 1;
	opr = 0;
	address = 6'd0;
	datain = 8'h00;

	@(posedge clk); #2;
	rst = 0;
	csin = 1;
	rwbarin = 0;
	address = 6'd3;
	datain = 8'hA5;
	
	@(posedge clk); #2;
	
	if(dataout !== 8'h00) begin
		$display("@@@FAIL");
		$finish();
	end

	rwbarin = 1;
	@(posedge clk); #2;
	if (dataout !== 8'ha5 || fail !== 1'b0) begin
		$display("@@@FAIL");
		$finish();
	end

	csin = 0;
	rwbarin = 0;
	address = 6'd4;
	datain = 8'hFF;
	@(posedge clk); #2;
	csin = 1;
	rwbarin = 1;
	@(posedge clk); #2;

	if (dataout == 8'hFF) begin
		$display("@@@FAIL");
		$finish();
	end

	//BIST test
	opr = 1; 
	start = 1;
       csin = 0;
	rwbarin = 0;
 	address = 6'd0;
	datain = 8'h00;	
	@(posedge clk); #2;
	start = 0;

	//BIST read cycle
	opr = 0;
	wait (DUT.NbarT == 1'b1 && DUT.rwbar == 1'b1);	//let it enter bist mode
	force DUT.eq = 1'b0;
	@(posedge clk); #2;
	
	if (fail !== 1'b0) begin
		$display("@@@FAIL");
		$finish();
	end
	release DUT.eq;
	//BIST write cycle
	opr = 1; 
	wait (DUT.NbarT == 1'b1 && DUT.rwbar == 1'b0);
	if (DUT.cs !== 1'b1) begin
		$display("@@@FAIL");
		$finish();
	end
	force DUT.eq = 1'b0;
	@(posedge clk); #2;
	if (fail !== 1'b0) begin
		$display("@@@FAIL");
		$finish();
	end
	release DUT.eq;

	opr = 1;
	wait (DUT.NbarT == 1'b1 && DUT.rwbar == 1'b1);
	force DUT.eq = 1'b0;
	@(posedge clk); #2;

	if (fail !== 1'b1) begin
		$display("@@@FAIL");
		$finish();
	end
	release DUT.eq;


	//corrupt some location
	

	$display("@@@PASS");
	$finish();
end
endmodule


