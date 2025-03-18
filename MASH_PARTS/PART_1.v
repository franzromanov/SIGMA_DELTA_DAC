//2y[n]=x[n-1]+x[n-1]+x[n-1]


module PART_1(	
	input clck,rst,
	input signed [3:0]x,
	output reg signed [3:0] y_out
	
	);

	reg signed [3:0] x_1,x_2,y_1;
	



	always @(posedge clck or posedge rst) begin
		if (rst)begin
			x_1<=0;
			x_2<=0;
			y_1<=0;
			
		end else begin
		
			
			y_out<=x_1+x_1+x_1-x_2-x_2+y_1;                   //membagi bilangan biner dengan 2 sama saja dengan menggeser ke kanan satu bit (karena tiap posisi adalah kelipatan dari pangkat 2) . seperti pada desimal, membagi suatu bilangan ratusan dengan 10 akan menggesernya ke arah kanan (puluhan)
			y_out=y_out>>>1;
			x_2<=x_1;
			y_1<=y_out;
			x_1<=x;
			end 
	end
	


endmodule
