module main(clck,rst,out_debug_1,out_debug_2);
	
	input clck,rst;
	wire [3:0]SIG_IN, CIC_OUT,PART_1_OUT,PART_2_OUT,PART_3_OUT,TRUNCATOR_1_OUT,TRUNCATOR_3_OUT,OUT_1,OUT_2,OUT_3,OUT_4,OUT_5;
	wire [6:0]OUT_DECODER;
   parameter BIT_WIDTH    = 4;
   parameter STAGES       = 3;
   parameter INTERP_RATE  = 8;
   parameter OUT_SCALE    = 6;
	output  out_debug_1;
	output [6:0]  out_debug_2;
	
	SIGNAL _SIGNAL(
		.clck(clck),
		.rst(rst),
		.sig_out(SIG_IN)
	);
	
   CIC #(
      .BIT_WIDTH(BIT_WIDTH),
      .STAGES(STAGES),
      .INTERP_RATE(INTERP_RATE),
      .OUT_SCALE_SHIFT(OUT_SCALE)
   )_CIC(
      .clk(clck),
      .rst_n(!(rst)),
      .enable(1),
      .data_in(SIG_IN),
      .data_out(CIC_OUT),
      .data_valid()
   );

	PART_1 _PART_1(
		.clck(clck),
		.rst(rst),
		.x(OUT_2),
		.y_out(PART_1_OUT)
	);
	
	PART_2 _PART_2(
		.clck(clck),
		.rst(rst),
		.x(OUT_DECODER),
		.y_out(PART_2_OUT)
	);
	
	PART_3 _PART_3(
		.clck(clck),
		.rst(rst),
		.x(OUT_5),
		.y_out(PART_3_OUT)
	);
	
	TRUNCATOR_1 _TRUNCATOR_1(
		.clck(clck),
		.rst(rst),
		.x_in(OUT_1),
		.y_out(TRUNCATOR_1_OUT),
	
	);
	
	TRUNCATOR_3 _TRUNCATOR_3(
		.clck(clck),
		.rst(rst),
		.x_in(OUT_4),
		.y_out(TRUNCATOR_3_OUT),
	
	);
	
	DECODER _DECODER_3(
		.clck(clck),
		.rst(rst),
		.A(TRUNCATOR_3_OUT[2]),
		.B(TRUNCATOR_3_OUT[1]),
		.C(TRUNCATOR_3_OUT[0]),
		.x1(OUT_DECODER[0]),
		.x2(OUT_DECODER[1]),
		.x3(OUT_DECODER[2]),
		.x4(OUT_DECODER[3]),
		.x5(OUT_DECODER[4]),
		.x6(OUT_DECODER[5]),
		.x7(OUT_DECODER[6])
	);
	
	/*
	
	DECODER_SIGN _DECODER_SIGN(
	
	);
	*/

	sum_point1 sum_1(

		.CIC_out(CIC_OUT),
		.PART_1_out(PART_1_OUT),
		.sum_point1_out(OUT_1)

	);

	sum_point2 sum_2(

		.sum_point1_out(OUT_1),
		.truncator_1_out(TRUNCATOR_1_OUT),
		.sum_point2_out(OUT_2)

	);

	sum_point4 sum_4(

		.sum_point2_out(OUT_2),
		.PART_3_out(PART_3_OUT),
		.sum_point4_out(OUT_4)

	);


	sum_point5 sum_5(

		.sum_point4_out(OUT_4),
		.Truncator_3_out(TRUNCATOR_3_OUT),
		.sum_point5_out(OUT_5)

	);
	
	assign out_debug_1=TRUNCATOR_1_OUT;
	assign out_debug_2=PART_2_OUT;

endmodule
