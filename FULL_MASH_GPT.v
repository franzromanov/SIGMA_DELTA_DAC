module sigma_delta_dac (
    input clk,
    input rst,
    input [3:0] x1,
    output y
);

    // Internal signals
    reg signed [4:0] x2, x3;
    reg signed [3:0] y1;
    reg signed [3:0] y2;
    reg signed [4:0] e1;
    reg signed [4:0] integrator1;
    reg signed [4:0] feedback_poly_out;
    reg signed [3:0] x1_delayed;
    reg signed [4:0] z1, z2;
    reg signed [4:0] z1_delayed, z2_delayed;
    reg signed [2:0] m_trunc;
    reg signed [3:0] m_dac_out;

    reg signed [4:0] temp_sum;  // Added intermediate register

    // Delays
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            x1_delayed <= 0;
            z1 <= 0;
            z2 <= 0;
            z1_delayed <= 0;
            z2_delayed <= 0;
            integrator1 <= 0;
        end else begin
            x1_delayed <= x1;
            z1 <= x2;
            z2 <= integrator1;
            z1_delayed <= z1;
            z2_delayed <= z2;
        end
    end

    // Computation
    always @(*) begin
        x2 = x1 + z1;
        x3 = {x2[4], 4'b0000};  // 1-bit truncator (MSB)

        // 1-bit DAC
        if (x3[4] == 1'b1)
            y1 = -8;
        else
            y1 = 7;

        y2 = y1 - z1_delayed[3:0];
        e1 = x2 - x3;

        integrator1 = e1 + z2;
        feedback_poly_out = (z1 <<< 1) - z2;

        // Avoid inline bit slicing: use temp_sum
        temp_sum = integrator1 + feedback_poly_out;
        m_trunc = temp_sum[4:2];  // extract bits separately

        case (m_trunc)
            3'b000: m_dac_out = -4;
            3'b001: m_dac_out = -3;
            3'b010: m_dac_out = -2;
            3'b011: m_dac_out = -1;
            3'b100: m_dac_out = 1;
            3'b101: m_dac_out = 2;
            3'b110: m_dac_out = 3;
            3'b111: m_dac_out = 4;
            default: m_dac_out = 0;
        endcase
    end

    assign y = y1[3];  // MSB of 1-bit DAC output

endmodule
