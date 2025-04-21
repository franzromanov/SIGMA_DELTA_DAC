`timescale 1ns / 1ps

module tb_SIGMA_BOY;

    // Parameters for SIGMA_BOY
    parameter WIDTH = 16;
    
    // Testbench signals
    reg [WIDTH-1:0] x1;
    reg clk;
    wire [WIDTH-1:0] y;

    // Instantiate the SIGMA_BOY module
    SIGMA_BOY uut (
        .x1(x1),
        .clk(clk),
        .y(y)
    );

    // Clock generation
    always begin
        #5 clk = ~clk;  // Toggle clock every 5 ns
    end

    // Test sequence
    initial begin
        // Initialize signals
        clk = 0;
        x1 = 0;
        
        // Apply stimulus to x1
        #20 x1 = 16'h0001; // Input 1
        #20 x1 = 16'h0002; // Input 2
        #20 x1 = 16'h0003; // Input 3
        #20 x1 = 16'h0004; // Input 4
        #20 x1 = 16'h0005; // Input 5
        #20 x1 = 16'h0006; // Input 6
        #20 x1 = 16'h0007; // Input 7
        #20 x1 = 16'h0008; // Input 8

        // Finish simulation
        #20 $finish;
    end

    // Monitor output
    initial begin
        $monitor("Time: %0t | Input (x1): %h | Output (y): %h", $time, x1, y);
    end

endmodule
