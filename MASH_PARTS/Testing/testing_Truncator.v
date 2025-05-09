module TRUNCATOR_3 (
    input  wire         clck,
    input  wire         rst,
    input  wire signed [3:0] x_in,   
    output reg signed sig_out,clck_out,
	 output reg signed [2:0]y_out
        
	 
);



	 
    reg signed [4:0] x_in_err=5'sd0;
	 reg signed  e_out=1'sd0;
	 reg signed [2:0]buffer=3'sd0;
	 reg signed [2:0]mem=3'sd0;
	 reg [4:0]cycle=0;
	 reg [4:0]shift=0;
	 reg [19:0] prescaler=0;
	 
	 always@(*)begin
	 
		 if(rst==1)begin
			 x_in_err=5'sd0;
			 y_out=3'sd0;
		 end else begin
			 x_in_err = x_in+e_out;
			 y_out = x_in_err[3:1];
		 end

	 end
	 

    always @(posedge clck or posedge rst) begin
	
			
			
         if (rst) begin
				
            e_out    <= 3'sd0;
				buffer <=3'sd0;
				mem<=3'sd0;
				shift<=0;
				cycle<=0;
				sig_out<=0;
				clck_out<=0;
				
			end else if(clck) begin
			
			
				e_out    <=x_in_err[0];
				
				if(cycle<1) begin
				
					cycle<=cycle+1;
					mem<=x_in_err[0];
					buffer<=x_in_err[0];
					
				end else if (cycle==1) begin
							
				
					if(prescaler>=20'd255) begin
					
						buffer<=(buffer>>1);
						sig_out<=buffer[0];
						shift<=shift+1;
						clck_out<=~clck_out;
						prescaler<=20'd0;
						if(!(shift<2))begin
							buffer<=mem;
							shift<=0;
						end
					
				
					end else if(prescaler<20'd255)begin
					
						prescaler<=prescaler+1;
						
					end
						  

				end
			end

    end

endmodule
