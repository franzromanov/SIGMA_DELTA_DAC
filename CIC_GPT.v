// Interpolation filter (CIC) compatible with MASH structure
// Simple CIC interpolator with 2-stage integrator and comb
module CIC_INTERPOLATOR #(
    parameter STAGES = 2,
    parameter WIDTH = 16,
    parameter RATE = 4
)(
    input wire clk,
    input wire rst,
    input wire [WIDTH-1:0] din,
    output wire [WIDTH-1:0] dout
);

    // Integrator stages
    reg [WIDTH-1:0] integrator [0:STAGES-1];
    integer i;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            for (i = 0; i < STAGES; i = i + 1) begin
                integrator[i] <= 0;
            end
        end else begin
            integrator[0] <= integrator[0] + din;
            for (i = 1; i < STAGES; i = i + 1) begin
                integrator[i] <= integrator[i] + integrator[i-1];
            end
        end
    end

    // Downsampled comb stages with delay registers
    reg [WIDTH-1:0] comb [0:STAGES-1];
    reg [WIDTH-1:0] comb_delay [0:STAGES-1];
    reg [$clog2(RATE)-1:0] rate_counter = 0;
    reg [WIDTH-1:0] comb_out = 0;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            rate_counter <= 0;
            for (i = 0; i < STAGES; i = i + 1) begin
                comb[i] <= 0;
                comb_delay[i] <= 0;
            end
            comb_out <= 0;
        end else begin
            rate_counter <= rate_counter + 1;
            if (rate_counter == RATE-1) begin
                comb_delay[0] <= integrator[STAGES-1];
                comb[0] <= integrator[STAGES-1] - comb_delay[0];
                for (i = 1; i < STAGES; i = i + 1) begin
                    comb_delay[i] <= comb[i-1];
                    comb[i] <= comb[i-1] - comb_delay[i];
                end
                comb_out <= comb[STAGES-1];
            end
        end
    end

    assign dout = comb_out;
endmodule
