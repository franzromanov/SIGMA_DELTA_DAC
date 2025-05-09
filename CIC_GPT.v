module CIC #(
    parameter BIT_WIDTH       = 4,                   // Input/output data width
    parameter STAGES          = 3,                   // Number of stages
    parameter INTERP_RATE     = 8,                   // Interpolation (upsample) rate
    // Internal width to avoid overflow: BIT_WIDTH + STAGES*log2(INTERP_RATE)
    parameter INT_WIDTH       = BIT_WIDTH + STAGES*$clog2(INTERP_RATE)
)(
    input  wire                      clk,
    input  wire                      rst_n,        // active-low reset
    input  wire                      enable,
    input  wire signed [BIT_WIDTH-1:0] data_in,    // new sample at input rate
    output reg signed [BIT_WIDTH-1:0] data_out    // interpolated output at high rate
);

  // Comb stage registers (operate at input rate)
  reg signed [INT_WIDTH-1:0] comb_reg   [0:STAGES-1];
  reg signed [INT_WIDTH-1:0] comb_delay [0:STAGES-1];
  reg signed [INT_WIDTH-1:0] comb_out_reg;

  // Integrator stage registers (operate at output rate)
  reg signed [INT_WIDTH-1:0] integ_reg  [0:STAGES-1];

  // Up-sample counter (0..INTERP_RATE-1)
  reg [$clog2(INTERP_RATE)-1:0] up_cnt;

  integer i;

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      // Reset comb, integrators and counter
      for (i = 0; i < STAGES; i = i + 1) begin
        comb_reg[i]   <= 0;
        comb_delay[i] <= 0;
        integ_reg[i]  <= 0;
      end
      comb_out_reg <= 0;
      up_cnt       <= 0;
      data_out     <= 0;

    end else if (enable) begin
      // --- Comb section: only once per new input frame (when up_cnt == 0) ---
      if (up_cnt == 0) begin
        // Sign-extend input
        reg signed [INT_WIDTH-1:0] ext_in;
        ext_in = {{(INT_WIDTH-BIT_WIDTH){data_in[BIT_WIDTH-1]}}, data_in};

        // First comb stage
        comb_reg[0]   <= ext_in - comb_delay[0];
        comb_delay[0] <= ext_in;
        // Remaining comb stages
        for (i = 1; i < STAGES; i = i + 1) begin
          comb_reg[i]   <= comb_reg[i-1] - comb_delay[i];
          comb_delay[i] <= comb_reg[i-1];
        end
        // Capture final comb output
        comb_out_reg <= comb_reg[STAGES-1];
      end

      // --- Upsample & Integrator section: run at full clk-rate ---
      reg signed [INT_WIDTH-1:0] stuffer;
      // Insert comb_out_reg on first cycle, zeros on others
      stuffer = (up_cnt == 0) ? comb_out_reg : {INT_WIDTH{1'b0}};

      // Integrators
      integ_reg[0] <= integ_reg[0] + stuffer;
      for (i = 1; i < STAGES; i = i + 1) begin
        integ_reg[i] <= integ_reg[i] + integ_reg[i-1];
      end

      // Truncate high bits back to BIT_WIDTH
      data_out <= integ_reg[STAGES-1][INT_WIDTH-1 -: BIT_WIDTH];

      // Update upsample counter
      if (up_cnt == INTERP_RATE - 1)
        up_cnt <= 0;
      else
        up_cnt <= up_cnt + 1;
    end
  end

endmodule
