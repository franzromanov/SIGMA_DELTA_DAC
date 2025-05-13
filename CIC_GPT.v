module CIC #(
    parameter BIT_WIDTH        = 4,                 // Input/output width (4-bit)
    parameter STAGES           = 3,                 // Number of CIC stages
    parameter INTERP_RATE      = 8,                // Interpolation (upsample) rate
    parameter INT_WIDTH        = BIT_WIDTH + STAGES*$clog2(INTERP_RATE),  // Internal precision
    parameter OUT_SCALE_SHIFT  = 6                  // Output scaling shift for proper amplitude
)(
    input  wire                       clk,          // System clock (high rate)
    input  wire                       rst_n,        // Active-low reset
    input  wire                       enable,       // Enable signal
    input  wire signed [BIT_WIDTH-1:0] data_in,     // 4-bit input at base rate
    output reg  signed [BIT_WIDTH-1:0] data_out,    // 4-bit output at high rate
    output reg                         data_valid   // Indicates valid output data
);
    // Calculate appropriate midpoint and half-scale for 4-bit signed output
    localparam signed [BIT_WIDTH-1:0] MAX_OUTPUT = 2**(BIT_WIDTH-1) - 1;  // +7 for 4-bit
    localparam signed [BIT_WIDTH-1:0] MIN_OUTPUT = -2**(BIT_WIDTH-1);     // -8 for 4-bit

    // Comb stage registers (run at input sample rate)
    reg signed [INT_WIDTH-1:0] comb_reg   [0:STAGES-1];
    reg signed [INT_WIDTH-1:0] comb_delay [0:STAGES-1];
    reg signed [INT_WIDTH-1:0] comb_out;
    
    // Integrator stage registers (run at output sample rate)
    reg signed [INT_WIDTH-1:0] integ_reg  [0:STAGES-1];
    
    // Upsample counter and rate control
    reg [$clog2(INTERP_RATE)-1:0] rate_count;
    
    // Temporary variables for signal processing
    reg signed [INT_WIDTH-1:0] stuffer;
    reg signed [INT_WIDTH-1:0] output_scaled;
    reg signed [BIT_WIDTH:0] output_saturated;  // One extra bit for saturation check
    reg signed [INT_WIDTH-1:0] ext_in;
    integer i;
    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // Reset all stages and counters
            for (i = 0; i < STAGES; i = i + 1) begin
                comb_reg[i]   <= 0;
                comb_delay[i] <= 0;
                integ_reg[i]  <= 0;
            end
            comb_out    <= 0;
            rate_count  <= 0;
            data_out    <= 0;
            data_valid  <= 0;
            
        end else if (enable) begin
            data_valid <= 1'b1;  // Output is always valid when enabled
            
            // Process new input sample at lower rate
            if (rate_count == 0) begin
                // Sign-extend the input for internal processing
                
                ext_in = {{(INT_WIDTH-BIT_WIDTH){data_in[BIT_WIDTH-1]}}, data_in};
                
                // Comb section (differentiators)
                comb_reg[0]   <= ext_in - comb_delay[0];
                comb_delay[0] <= ext_in;
                
                for (i = 1; i < STAGES; i = i + 1) begin
                    comb_reg[i]   <= comb_reg[i-1] - comb_delay[i];
                    comb_delay[i] <= comb_reg[i-1];
                end
                
                // Store comb output for upsampling
                comb_out <= comb_reg[STAGES-1];
            end
            
            // Zero insertion for upsampling
            stuffer = (rate_count == 0) ? comb_out : {INT_WIDTH{1'b0}};
            
            // Integrator section (accumulators)
            integ_reg[0] <= integ_reg[0] + stuffer;
            for (i = 1; i < STAGES; i = i + 1) begin
                integ_reg[i] <= integ_reg[i] + integ_reg[i-1];
            end
            
            // Scale the output to compensate for CIC gain and bit growth
            // For 4-bit interface to MASH, we need appropriate scaling
            output_scaled = integ_reg[STAGES-1] >>> OUT_SCALE_SHIFT;
            
            // Saturation logic for 4-bit output
            if (output_scaled > MAX_OUTPUT)
                data_out <= MAX_OUTPUT;
            else if (output_scaled < MIN_OUTPUT)
                data_out <= MIN_OUTPUT;
            else
                data_out <= output_scaled[BIT_WIDTH-1:0];
            
            // Update rate counter
            if (rate_count == INTERP_RATE - 1)
                rate_count <= 0;
            else
                rate_count <= rate_count + 1;
        end else begin
            data_valid <= 1'b0;
        end
    end
    
    // Synthesis-time display of parameters
    initial begin
        $display("CIC Interpolator Configuration for MASH Sigma-Delta:");
        $display("- BIT_WIDTH = %0d bits", BIT_WIDTH);
        $display("- STAGES = %0d", STAGES);
        $display("- INTERP_RATE = %0d", INTERP_RATE);
        $display("- Internal width = %0d bits", INT_WIDTH);
        $display("- Output scaling shift = %0d bits", OUT_SCALE_SHIFT);
        $display("- Theoretical gain = %0d", INTERP_RATE**STAGES);
    end
    
endmodule
