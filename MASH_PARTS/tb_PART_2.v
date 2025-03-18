`timescale 1ms/1ns 

module tb_PART_2;
	reg signed [3:0] x;
	reg clck,rst;
	wire signed [3:0]y_out;

PART_2 uut (

	.clck(clck),
	.x(x),
	.rst(rst),
	.y_out(y_out)

);






	always #5 clck=~clck;
		initial begin
		
			clck=0;
			rst=1;
			x=0;
			//y_out=0;
			
			#10 rst=0;
			
		  #10 x = 4'b0001; // 1
        #10 x = 4'b0011; // 3
        #10 x = 4'b0100; // 4
        #10 x = 4'b0101; // 5
        #10 x = 4'b0110; // 6
        #10 x = 4'b0111; // 7
        #20 $stop;
				
		end


endmodule