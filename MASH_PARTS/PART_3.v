module PART_3(
	input clck,rst,
	input signed [3:0]x,
	output reg signed [3:0]y_out
);
	
	reg signed [3:0] x_1;
	reg signed [3:0] x_2;
	
	always @(posedge clck or posedge rst) // can reset value when clck is 1 or 0 
		begin
			if (rst) begin
				x_1<=0;
				x_2<=0;
				y_out<=0;
			end else begin
				y_out <= x_1+x_1-x_2;
				
				x_2<=x_1; //x[n-2]
				x_1<=x; //x[n-1]
			end
		end

endmodule
