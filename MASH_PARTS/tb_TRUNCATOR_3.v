`timescale 1ms/1ns

module tb_TRUNCATOR_3;
	reg clck,rst;
	reg signed [2:0] y_out;
	reg signed [15:0] x_in;
	reg signed [12:0] e_out;


TRUNCATOR_3 uut (
	.clck(clck),
	.rst(rst),
	.x_in(x_in),
	.y_out(y_out),
	.e_out(e_out)
);


always #5 clck=~clck;
	initial begin
		clck=0;
		rst=1;
		x_in=0;
		#10 rst=0;
		
	        #10 x_in = 16'd3; // 3
		#10 x_in = 16'd4; // 4
                #10 x_in = 16'd5; // 5
                #10 x_in = 16'd6; // 6
                #10 x_in = 16'd7; // 7
                #10 x_in = 16'd8; // 8
                #10 x_in = 16'd9; // 9
                #10 x_in = 16'd10; // 10
		#20 $stop;
	end
endmodule
