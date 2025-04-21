module SIGMA_BOY (
    input [15:0] x1,
    input clk,
    output [15:0] y
);

    // PART_1: First Stage Modulator (1-bit DAC + Integrator)
    wire [15:0] int1_out, dac1_out, trunc1_out;
    wire cout1;

    // Integrator 1: Accumulate input x1 with feedback from 1-bit DAC
    FA_16 integrator1 (
        .clck(clk),
        .a(x1),
        .b(~dac1_out),
        .s_cin(1'b1),
        .cout(cout1),
        .sum(int1_out)
    );

    // Truncator (1-bit output)
    assign trunc1_out = {15'b0, int1_out[15]}; // LSB truncation

    // 1-bit DAC (decoder)
    wire dac1_bit;
    assign dac1_bit = trunc1_out[0];
    assign dac1_out = {16{dac1_bit}}; // Output full scale if 1

    // PART_2: Second Stage Modulator (3-bit DAC + Integrator)
    wire [15:0] error_stage2, error_stage2_delay, diff_stage2, int2_out, trunc2_out, dac2_out;
    wire cout2;

    // Calculate error: x1 - dac1_out
    FA_16 error_calc (
        .clck(clk),
        .a(x1),
        .b(~dac1_out),
        .s_cin(1'b1),
        .cout(),
        .sum(error_stage2)
    );

    // Apply (1 - z⁻¹) to the error signal before integration
    reg [15:0] error_stage2_reg;
    always @(posedge clk)
        error_stage2_reg <= error_stage2;

    wire [15:0] stage2_input;
    FA_16 diff_calc (
        .clck(clk),
        .a(error_stage2),
        .b(~error_stage2_reg),
        .s_cin(1'b1),
        .cout(),
        .sum(stage2_input)
    );

    // Integrator 2
    FA_16 integrator2 (
        .clck(clk),
        .a(stage2_input),
        .b(16'b0),
        .s_cin(1'b0),
        .cout(cout2),
        .sum(int2_out)
    );

    // Truncator (3-bit output, using MSBs)
    wire [2:0] trunc2_bits;
    assign trunc2_bits = int2_out[15:13];

    // 3-bit DAC (decoder)
    wire [6:0] decoder_out;
    DECODER_3 dac3bit (
        .A(trunc2_bits[2]),
        .B(trunc2_bits[1]),
        .C(trunc2_bits[0]),
        .x1(decoder_out[0]),
        .x2(decoder_out[1]),
        .x3(decoder_out[2]),
        .x4(decoder_out[3]),
        .x5(decoder_out[4]),
        .x6(decoder_out[5]),
        .x7(decoder_out[6])
    );
    assign dac2_out = {9'b0, decoder_out[6:0]};

    // PART_3: Noise Shaping Output (apply 1 - z⁻¹ to int2_out - dac2_out)
    wire [15:0] stage3_diff, stage3_diff_delay, y2;
    assign stage3_diff = int2_out - dac2_out;

    reg [15:0] stage3_diff_reg;
    always @(posedge clk)
        stage3_diff_reg <= stage3_diff;

    assign y2 = stage3_diff - stage3_diff_reg;

    wire [15:0] y1;
    assign y1 = trunc1_out;
    assign y = y1 + y2;

endmodule
