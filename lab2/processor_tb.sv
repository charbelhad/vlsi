module processor_tb();

logic clk;
logic rstN;
logic [31:0] data_in;
logic [31:0] i_data;
logic data_select;
logic [15:0] status_flags;
logic [31:0] data_out;
logic [7:0] status;
logic [2:0] Q;

processor DUT(.*);

initial clk = 0;
always #5 clk = ~clk;

initial begin
rstN = 1'b0; status_flags = 16'hFFFF;
//check mux
data_in = 32'hDEADBEEF; i_data = 32'h11111111; data_select = 1'b1;
#1
if(data_out !== 32'hDEADBEEF) begin
	$display ("@@@FAIL");
	$finish();
end
data_in = 32'hDEADBEEF; i_data = 32'h11111111; data_select = 1'b0;
#1
if(data_out !== 32'h11111111) begin
        $display ("@@@FAIL");
        $finish();
end
data_in = 32'h00000000; i_data = 32'hFFFFFFFF; data_select = 1'b1;
#1
if(data_out !== 32'h00000000) begin
        $display ("@@@FAIL");
        $finish();
end
data_in = 32'h00000000; i_data = 32'hFFFFFFFF; data_select = 1'b0;
#1
if(data_out !== 32'hFFFFFFFF) begin
        $display ("@@@FAIL");
        $finish();
end


//check the pri encoder
status_flags[15:8] = 8'b00000000; 
#1
if(Q!==3'b000) begin
	$display("@@@FAIL");
	$finish();
end

status_flags[15:8] = 8'b00000001;
#1
if(Q!==3'b000) begin
        $display("@@@FAIL");
        $finish();
end

status_flags[15:8] = 8'b00000010;
#1
if(Q!==3'b001) begin
        $display("@@@FAIL");
        $finish();
end

status_flags[15:8] = 8'b00010000;
#1
if(Q!==3'b100) begin
        $display("@@@FAIL");
        $finish();
end

status_flags[15:8] = 8'b10000000;
#1
if(Q!==3'b111) begin
        $display("@@@FAIL");
        $finish();
end

status_flags[15:8] = 8'b10100000;
#1
if(Q!==3'b111) begin
        $display("@@@FAIL");
        $finish();
end



//check the register
//
rstN = 0; status_flags[7:0] = 8'b11111111;
@(posedge clk);
#1
if (status !== 8'h60)
begin
	$display("@@@FAIL");
	$finish();
end

rstN=1; status_flags[7] = 1'b0;
status_flags[4] = 1'b1;
status_flags[3] = 1'b0;
status_flags[2] = 1'b1;
status_flags[1:0] = 2'b01;
@(posedge clk);
#1
if (status !== 8'b01110101) begin
	$display("@@@FAIL");
	$finish();
end



rstN=1; status_flags[7] = 1'b1;
status_flags[4] = 1'b0;
status_flags[3] = 1'b1;
status_flags[2] = 1'b0;
status_flags[1:0] = 2'b10;
@(posedge clk);
#1
if (status !== 8'b11101010) begin
        $display("@@@FAIL");
        $finish();
end

$display("@@@PASS");
$finish();









end

endmodule
