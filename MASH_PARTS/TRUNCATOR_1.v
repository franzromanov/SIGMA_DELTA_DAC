module TRUNCATOR_1(
	input clck,rst,
	input signed [15:0]x_in,
	output reg signed y_out,
	output reg signed [14:0]e_out

);


	reg signed [15:0]x_in_err;

	always @(posedge clck or posedge rst) begin
		if (rst) begin
			x_in_err<=16'd0;
			e_out<=15'd0;
			y_out<=1'd0;
		end else begin
	
			x_in_err<=x_in+e_out;
			y_out<=x_in_err[15];
			e_out<=x_in_err[14:0];
		end
		
	end

endmodule
