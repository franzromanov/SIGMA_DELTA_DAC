module TRUNCATOR_3(
	input clck,rst,
	input signed [3:0]x_in,
	output reg signed [2:0] y_out,
	output reg signed e_out

);


	reg signed [4:0]x_in_err;


 always@(*)begin
	 
		 if(rst==1)begin
			 x_in_err=5'sd0;
			 y_out=3'd0;
		 end else begin
			 x_in_err = x_in+e_out;
			 y_out = x_in_err[3:1];
		 end

	 end
	 

    always @(posedge clck or posedge rst) begin
	
         if (rst) begin
				
            e_out    <= 1'sd0;
				
	 end else if(clck) begin
				
		 e_out    <=x_in_err[0];
	 end

endmodule
