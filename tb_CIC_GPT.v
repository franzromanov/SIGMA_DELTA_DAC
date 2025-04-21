`timescale 1ns / 1ps

module tb_CIC_INTERPOLATOR;

    // Parameters for the CIC_INTERPOLATOR
    parameter WIDTH = 16;
    parameter STAGES = 2;
    parameter RATE = 4;
    
    // Testbench signals
    reg clk;
    reg rst;
    reg [WIDTH-1:0] din;
    wire [WIDTH-1:0] dout;

    // Instantiate the CIC_INTERPOLATOR module
    CIC_INTERPOLATOR #(
        .STAGES(STAGES),
        .WIDTH(WIDTH),
        .RATE(RATE)
    ) uut (
        .clk(clk),
        .rst(rst),
        .din(din),
        .dout(dout)
    );

    // Clock generation
    always begin
        #5 clk = ~clk;  // Toggle clock every 5 ns
    end

    // Test sequence
    initial begin
        // Initialize signals
        clk = 0;
        rst = 0;
        din = 0;
        
        // Apply reset
        rst = 1;
        #20;
        rst = 0;
        
        // Apply test stimulus (input signal)
        din = 16'h0001; // Sample input value
        #20;
        
        din = 16'h0002; // Another input value
        #20;

        din = 16'h0003; // Another input value
        #20;

        din = 16'h0004; // Another input value
        #20;
        
        // Additional test cases could be added here

        // Finish simulation
        $finish;
    end

    // Monitor output
    initial begin
        $monitor("Time: %0t | Input: %h | Output: %h", $time, din, dout);
    end

endmodule
