module rtl_16bit_adder_tb;

logic [15:0] a,b;
logic cin;
logic [15:0] s;
logic cout;

rtl_16bit_adder DUT(.*);

initial begin

	a = 16'h0000; b = 16'h0000; cin = 1'b0;
	#5
	if (s !== 16'h0000 || cout !== 1'b0) begin
		$display("@@@FAIL");
		$finish();
	end

	a = 16'h0000; b = 16'h0000; cin = 1'b1;
        #5
        if (s !== 16'h0001 || cout !== 1'b0) begin
                $display("@@@FAIL");
                $finish();
        end

	a = 16'h0001; b = 16'h0001; cin = 1'b0;
        #5
        if (s !== 16'h0002 || cout !== 1'b0) begin
                $display("@@@FAIL");
                $finish();
        end

        a = 16'h000F; b = 16'h0001; cin = 1'b0;
        #5
        if (s !== 16'h0010 || cout !== 1'b0) begin
                $display("@@@FAIL");
                $finish();
        end

        a = 16'h00FF; b = 16'h0001; cin = 1'b0;
        #5
        if (s !== 16'h0100 || cout !== 1'b0) begin
                $display("@@@FAIL");
                $finish();
        end

        a = 16'h0FFF; b = 16'h0001; cin = 1'b0;
        #5
        if (s !== 16'h1000 || cout !== 1'b0) begin
                $display("@@@FAIL");
                $finish();
        end

	a = 16'hFFFF; b = 16'h0001; cin = 1'b0;
        #5
        if (s !== 16'h0000 || cout !== 1'b1) begin
                $display("@@@FAIL");
                $finish();
        end

        a = 16'hFFFF; b = 16'hFFFF; cin = 1'b0;
        #5
        if (s !== 16'hFFFE || cout !== 1'b1) begin
                $display("@@@FAIL");
                $finish();
        end

        a = 16'hFFFF; b = 16'hFFFF; cin = 1'b1;
        #5
        if (s !== 16'hFFFF || cout !== 1'b1) begin
                $display("@@@FAIL");
                $finish();
        end

        a = 16'h8000; b = 16'h8000; cin = 1'b0;
        #5
        if (s !== 16'h0000 || cout !== 1'b1) begin
                $display("@@@FAIL");
                $finish();
        end

        a = 16'hAAAA; b = 16'h5555; cin = 1'b0;
        #5
        if (s !== 16'hFFFF || cout !== 1'b0) begin
                $display("@@@FAIL");
                $finish();
        end

        a = 16'h1234; b = 16'h4321; cin = 1'b0;
        #5
        if (s !== 16'h5555 || cout !== 1'b0) begin
                $display("@@@FAIL");
                $finish();
        end

	$display("@@@PASS");
	$finish();















end






endmodule
