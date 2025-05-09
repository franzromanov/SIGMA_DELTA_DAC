module cic_filter #(
  parameter BIT_WIDTH = 4,         // Input data width
  parameter STAGES = 3,            // Number of stages
  parameter DECIMATION_RATE = 8,   // Decimation rate
  // Calculate required internal bit width to prevent overflow
  parameter INT_WIDTH = BIT_WIDTH + STAGES * $clog2(DECIMATION_RATE)
)(
  input wire clk,                  // System clock
  input wire rst_n,                // Active low reset
  input wire enable,               // Enable signal
  input wire signed [BIT_WIDTH-1:0] data_in,  // Input data
  output reg signed [BIT_WIDTH-1:0] data_out, // Output data
  output reg data_valid            // Output data valid signal
);

  // Internal signals
  reg [INT_WIDTH-1:0] integrator_reg [STAGES-1:0];
  reg [INT_WIDTH-1:0] comb_reg [STAGES-1:0];
  reg [INT_WIDTH-1:0] comb_delay [STAGES-1:0];
  
  // Counter for decimation
  reg [$clog2(DECIMATION_RATE)-1:0] decimation_counter;
  
  integer i;
  
  // Integrator section (runs at input sample rate)
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      // Reset all registers
      for (i = 0; i < STAGES; i = i + 1) begin
        integrator_reg[i] <= 0;
        comb_reg[i] <= 0;
        comb_delay[i] <= 0;
      end
      decimation_counter <= 0;
      data_out <= 0;
      data_valid <= 0;
    end else if (enable) begin
      // Integrator section
      integrator_reg[0] <= integrator_reg[0] + {{(INT_WIDTH-BIT_WIDTH){data_in[BIT_WIDTH-1]}}, data_in};
      
      for (i = 1; i < STAGES; i = i + 1) begin
        integrator_reg[i] <= integrator_reg[i] + integrator_reg[i-1];
      end
      
      // Decimation counter logic
      if (decimation_counter == DECIMATION_RATE - 1) begin
        decimation_counter <= 0;
        
        // Comb section (runs at output sample rate)
        comb_reg[0] <= integrator_reg[STAGES-1];
        comb_delay[0] <= comb_reg[0];
        
        for (i = 1; i < STAGES; i = i + 1) begin
          comb_reg[i] <= comb_reg[i-1] - comb_delay[i-1];
          comb_delay[i] <= comb_reg[i];
        end
        
        // Final output with bit truncation
        data_out <= comb_reg[STAGES-1][INT_WIDTH-1:INT_WIDTH-BIT_WIDTH];
        data_valid <= 1;
      end else begin
        decimation_counter <= decimation_counter + 1;
        data_valid <= 0;
      end
    end
  end
endmodule
