module stimulus_module(
    input wire clck,
    input wire rst,
    output reg [13:0] out,   // 7-segment display output
    output signed osc_out, out_clck
);
    wire signed osc_out_, out_clck_;
    
    // Fixed stimulus values
    wire signed [3:0] x = 4'b0110;
    wire signed y_result;     // MSB output
    wire signed e_result;  // Error bits
  
    // Instantiate PART_1 logic with proper connections
    PART_1 dut (
        .clck(clck),
        .rst(rst),
        .x_in(x),
        .y_out(y_result),      // Connect to proper output
        .sig_out(e_result),      // Error output
		  .clck_out(out_clck_)
    );
    
    
    assign osc_out = e_result;
    assign out_clck = out_clck_;
    
    // Here you might want to add logic for the 7-segment display
    // Currently 'out' is declared but never assigned
    
endmodule
