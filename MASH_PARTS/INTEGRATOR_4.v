module INTEGRATOR_4 (input wire clk,input wire reset,
		     input wire signed [3:0] in,	output reg signed [3:0] out);

	always @(posedge clk) begin
    	if (reset) begin
        	out <= 4'b0; 
    	end else begin
        	out <= out + in;  // Accumulate the input value
    	end
	end

endmodule
