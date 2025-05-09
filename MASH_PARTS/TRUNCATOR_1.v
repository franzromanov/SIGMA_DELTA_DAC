module TRUNCATOR_1(
    input wire clck,
    input wire rst,
    input signed [3:0] x_in,            // 4-bit signed input
    output reg signed y_out,           // 1-bit output (MSB of extended error)
    output reg signed [2:0] e_out      // 3-bit signed error output (LSBs)
);

    reg signed [4:0] x_in_err;         // Intermediate value: 4-bit input + 3-bit error = 5-bit


	 always@(*)begin
	 
		 if(rst==1)begin
			 x_in_err=5'sd0;
			 y_out=0;
		 end else begin
			 x_in_err = x_in+e_out;
			 y_out = x_in_err[4];
		 end

	 end
    
    always @(posedge clck or posedge rst) begin
			
         if (rst) begin
            e_out    <= 3'sd0;

		 end else if(clck) begin
				e_out    <=x_in_err[3:1];
         end
        
    end

endmodule
