//start_module
module FA_4(a,b,s_cin,cout,sum);
//declare_structure
	input [3:0]a;
	input [3:0]b;
	output cout;
	output [3:0]sum;
	input s_cin;
	wire [2:0]cin;

	//inside_structure
		FA(a[0],b[0],s_cin,cin[0],sum[0]);
		FA(a[1],b[1],cin[0],cin[1],sum[1]);
		FA(a[2],b[2],cin[1],cin[2],sum[2]);
		FA(a[3],b[3],cin[2],cout,sum[3]);
		
endmodule
//finished

//create_module
module _xor(an,bn,out);

//declare
	input an,bn;
	output out;
	
	//operation
		assign out = ( ~an & bn ) | ( an & ~bn );
		
endmodule
//finished

//create_module
module HA(a,b,cout,sum);

//declare
	input a,b;
	output cout,sum;
		//inside_structures
		_xor(a,b,sum);
		assign cout = a & b;
	
endmodule
//finished

//start
module FA(a,b,cin,cout,sum);
//declare
	input a,b,cin;
	output cout,sum;
	wire w_sum,w_out1,w_out2;
//structure
	HA(a,b,w_out1,w_sum);
	HA(cin,w_sum,w_out2,sum);
	assign cout = w_out1 | w_out2;
	
endmodule
//finished


