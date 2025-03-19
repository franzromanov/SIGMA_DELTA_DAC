module TRUNCATOR_3(
	input clck,rst,
	input signed [15:0]x_in,
	output reg signed [2:0] y_out,
	output reg signed [12:0]e_out

);


	reg signed [15:0]x_in_err;

	always @(posedge clck or posedge rst) begin
		if (rst) begin
			x_in_err<=16'd0;
			e_out<=13'd0;
			y_out<=3'd0;
		end else begin
	
			x_in_err<=x_in+e_out;
			y_out<=x_in_err[15:13];
			e_out<=x_in_err[12:0];
		end
		
	end

endmodule
