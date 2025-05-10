module tb_CIC;
    // System parameters
    parameter BIT_WIDTH    = 4;              // Input/output width
    parameter STAGES       = 3;              // Number of CIC stages
    parameter INTERP_RATE  = 4;             // Interpolation rate
    parameter CLK_PERIOD   = 10;             // Clock period in ns
    parameter SIM_LENGTH   = 1000;           // Simulation length in clock cycles
    parameter OUT_SCALE    = 6;              // Output scaling factor
    
    // Clock and control signals
    reg clk;
    reg rst_n;
    reg enable;
    
    // Input/output signals
    reg  signed [BIT_WIDTH-1:0] data_in;
    wire signed [BIT_WIDTH-1:0] cic_out;
    wire cic_valid;
    
    // Instantiate the CIC interpolator
    CIC#(
        .BIT_WIDTH(BIT_WIDTH),
        .STAGES(STAGES),
        .INTERP_RATE(INTERP_RATE),
        .OUT_SCALE_SHIFT(OUT_SCALE)
    ) cic_inst (
        .clk(clk),
        .rst_n(rst_n),
        .enable(enable),
        .data_in(data_in),
        .data_out(cic_out),
        .data_valid(cic_valid)
    );
    
    // Test signal parameters
    localparam MAX_VALUE = 2**(BIT_WIDTH-1)-1;    // Maximum input value (+7 for 4-bit)
    localparam MIN_VALUE = -2**(BIT_WIDTH-1);     // Minimum input value (-8 for 4-bit)
    
    // Process variables
    integer cycle_count;
    integer in_sample_count;
    integer output_file;
    
    // Clock generation
    always #(CLK_PERIOD/2) clk = ~clk;
    
    // Input generation - simple sine-like pattern for 4-bit
    function signed [BIT_WIDTH-1:0] get_input_sample;
        input integer sample_num;
        begin
            case (sample_num % 8)
                0: get_input_sample = 0;
                1: get_input_sample = 1;
                2: get_input_sample = 1;
                3: get_input_sample = 1;
                4: get_input_sample = 0;
                5: get_input_sample = -1;
                6: get_input_sample = -1;
                7: get_input_sample = -1;
            endcase
        end
    endfunction
    
    // Stimulus and monitoring
    initial begin
        // Initialize test
        clk = 0;
        rst_n = 0;
        enable = 0;
        data_in = 0;
        cycle_count = 0;
        in_sample_count = 0;
        
        // Open output file
        output_file = $fopen("cic_mash_output.csv", "w");
        if (output_file == 0) begin
            $display("Error: Could not open output file");
            $finish;
        end
        
        // Write CSV header
        $fwrite(output_file, "cycle,in_sample_num,data_in,cic_out,cic_valid\n");
        
        // Apply reset
        #(CLK_PERIOD*2);
        rst_n = 1;
        #(CLK_PERIOD);
        enable = 1;
        
        // Run simulation
        while (cycle_count < SIM_LENGTH) begin
            // Update input at base rate
            if (cycle_count % INTERP_RATE == 0) begin
                data_in = get_input_sample(in_sample_count);
                in_sample_count = in_sample_count + 1;
            end
            
            #(CLK_PERIOD);
            cycle_count = cycle_count + 1;
            
            // Store data in CSV
            $fwrite(output_file, "%0d,%0d,%0d,%0d,%0d\n", 
                    cycle_count, in_sample_count, data_in, cic_out, cic_valid);
        end
        
        // Close file and finish
        $fclose(output_file);
        $display("Simulation completed: %0d cycles, %0d input samples", 
                 cycle_count, in_sample_count);
        $finish;
    end
    
    // Display key transitions
    always @(posedge clk) begin
        if (enable && rst_n) begin
            if (cycle_count % INTERP_RATE == 0) begin
                $display("Cycle %0d: New input sample %0d = %0d", 
                         cycle_count, in_sample_count, data_in);
            end
            
            // Show every 16th output sample for cleaner output
            if (cycle_count % 16 == 0) begin
                $display("Cycle %0d: CIC output = %0d", cycle_count, cic_out);
            end
        end
    end
    
    // Generate waveform file
    initial begin
        $dumpfile("cic_mash.vcd");
        $dumpvars(0, tb_CIC);
    end
    
    // Analyze output
    reg signed [31:0] acc_out;
    real avg_out;
    integer output_count;
    
    initial begin
        acc_out = 0;
        output_count = 0;
        
        forever begin
            @(posedge clk);
            if (enable && rst_n && cic_valid) begin
                acc_out = acc_out + cic_out;
                output_count = output_count + 1;
                
                // Calculate average every 128 samples
                if (output_count % 128 == 0) begin
                    avg_out = acc_out;
                    avg_out = avg_out / 128;
                    $display("Statistics: Average output over 128 samples = %f", avg_out);
                    acc_out = 0;
                end
            end
        end
    end
endmodule
