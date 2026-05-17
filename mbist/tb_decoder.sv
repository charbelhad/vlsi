module tb_decoder();

logic [2:0] q;
logic [7:0] data_t;

decoder DUT(.*);

initial begin

	q = 3'b000; 
	#5;
	if (data_t !== 8'b10101010) begin
		$display("@@@FAIL");
		$finish();
	end

	q = 3'b001;
        #5;
        if (data_t !== 8'b01010101) begin
                $display("@@@FAIL");
                $finish();
	end

        q = 3'b010;
        #5;
        if (data_t !== 8'b11110000) begin
                $display("@@@FAIL");
                $finish();
	end

        q = 3'b011;
        #5;
        if (data_t !== 8'b00001111) begin
                $display("@@@FAIL");
                $finish();
	end

        q = 3'b100;
        #5;
        if (data_t !== 8'b00000000) begin
                $display("@@@FAIL");
                $finish();
	end

        q = 3'b101;
        #5;
        if (data_t !== 8'b11111111) begin
                $display("@@@FAIL");
                $finish();
	end

	q = 3'b110;
        #5;
        if (data_t !== 8'bxxxxxxxx) begin
                $display("@@@FAIL");
                $finish();
	end

	q = 3'b111;
        #5;
        if (data_t !== 8'bxxxxxxxx) begin
                $display("@@@FAIL");
                $finish();
	end
	$display("@@@PASS");
	$finish();
end
endmodule
