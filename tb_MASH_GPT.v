`timescale 1ns/1ps

module tb_main;

    // Signals
    reg clk;
    reg rst;
    reg [3:0] x1;
    wire y;

    // Instantiate the DAC module
    sigma_delta_dac uut (
        .clk(clk),
        .rst(rst),
        .x1(x1),
        .y(y)
    );

    // Clock generation: 10 ns period (100 MHz)
    always #5 clk = ~clk;

    // Test sequence
    initial begin
        // Initialize signals
        clk = 0;
        rst = 1;
        x1 = 4'd0;

        // Hold reset for a few clock cycles
        #20;
        rst = 0;

        // After reset, apply unit step: input becomes 1
        #20;
        x1 = 4'd1;

        // Run for total of 1000 clock cycles (10,000 ns)
        #10000;

        $finish;
    end

    // Monitor signal changes
    initial begin
        $monitor("Time=%t | rst=%b | x1=%d | y=%b", $time, rst, x1, y);
    end

endmodule
