module tb_CIC;
    parameter BIT_WIDTH    = 4;
    parameter STAGES       = 3;
    parameter INTERP_RATE  = 8;
    parameter CLK_PERIOD   = 10;
    parameter SIM_LENGTH   = 1000;
    parameter OUT_SCALE    = 6;

    reg clk;
    reg rst_n;
    reg enable;

    reg  signed [BIT_WIDTH-1:0] data_in;
    wire signed [BIT_WIDTH-1:0] cic_out;
    wire cic_valid;

    CIC #(
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

    // Clock generation
    always #(CLK_PERIOD/2) clk = ~clk;

    // Unit step input function
    function signed [BIT_WIDTH-1:0] get_input_sample;
        input integer sample_num;
        begin
            if (sample_num < 4)
                get_input_sample = 0;
            else
                get_input_sample = 1;
        end
    endfunction

    integer cycle_count;
    integer in_sample_count;
    integer output_file;
    integer i;

    reg start_sim;

    initial begin
        clk = 0;
        rst_n = 0;
        enable = 0;
        data_in = 0;
        cycle_count = 0;
        in_sample_count = 0;
        start_sim = 0;

        // Open CSV
        output_file = $fopen("cic_debug_output.csv", "w");
        if (!output_file) begin
            $display("Failed to open output file!");
            $finish;
        end

        // CSV Header
        $fwrite(output_file, "cycle,data_in,cic_out,cic_valid,stuffer");
        for (i = 0; i < STAGES; i = i + 1)
            $fwrite(output_file, ",comb_reg[%0d],comb_delay[%0d]", i, i);
        for (i = 0; i < STAGES; i = i + 1)
            $fwrite(output_file, ",integ_reg[%0d]", i);
        $fwrite(output_file, "\n");

        // Reset
        #(CLK_PERIOD * 4);
        rst_n = 1;
        #(CLK_PERIOD);
        enable = 1;
        start_sim = 1;

        // Simulation loop
        while (cycle_count < SIM_LENGTH) begin
            if (start_sim && (cycle_count % INTERP_RATE == 0)) begin
                data_in = get_input_sample(in_sample_count);
                in_sample_count = in_sample_count + 1;
            end

            #(CLK_PERIOD);
            cycle_count = cycle_count + 1;

            // Only write after simulation started
            if (start_sim) begin
                $fwrite(output_file, "%0d,%0d,%0d,%0d,%0d",
                    cycle_count,
                    data_in,
                    cic_out,
                    cic_valid,
                    $signed(cic_inst.stuffer)
                );

                for (i = 0; i < STAGES; i = i + 1)
                    $fwrite(output_file, ",%0d,%0d",
                        $signed(cic_inst.comb_reg[i]),
                        $signed(cic_inst.comb_delay[i])
                    );

                for (i = 0; i < STAGES; i = i + 1)
                    $fwrite(output_file, ",%0d", $signed(cic_inst.integ_reg[i]));

                $fwrite(output_file, "\n");
            end
        end

        $fclose(output_file);
        $display("Simulation complete. CSV saved as cic_debug_output.csv");
        $finish;
    end

    initial begin
        $dumpfile("cic_debug.vcd");
        $dumpvars(0, tb_CIC);
    end
endmodule
