module TRUNCATOR_1(
    input wire clck,
    input wire rst,
    input signed [3:0] x_in,            // 4-bit signed input
    output reg signed y_out,           // 1-bit output (MSB of extended error)
    output reg signed [2:0] e_out      // 3-bit signed error output (LSBs)
);

    reg signed [4:0] x_in_err;         // Intermediate value: 4-bit input + 3-bit error = 5-bit

    always @(posedge clck or posedge rst) begin
        if (rst) begin
            x_in_err <= 5'd0;
            e_out <= 3'd0;
            y_out <= 1'd0;
        end else begin
            x_in_err <= x_in + e_out;
            y_out <= x_in_err[4];       // MSB is the truncated output
            e_out <= x_in_err[3:1];     // LSBs saved as error for feedback
        end
    end

endmodule
