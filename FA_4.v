module FA_4 (
    input [3:0] a,        // 4-bit input 'a'
    input [3:0] b,        // 4-bit input 'b'
    input s_cin,          // Start carry-in for first full adder
    input clk,            // Clock input
    output reg cout,      // Final carry-out (registered)
    output reg [3:0] sum // 4-bit sum output (registered)
);

    // Intermediate carry signals between full adders
    wire [2:0] cin;       // Carry in for intermediate adders
    wire [3:0] sum_comb;  // Combinational sum output (from FA instances)
    wire cout_comb;       // Carry-out from the last full adder (FA3)

    // Full Adder instances
    FA FA0 (.a(a[0]), .b(b[0]), .cin(s_cin), .cout(cin[0]), .sum(sum_comb[0]));
    FA FA1 (.a(a[1]), .b(b[1]), .cin(cin[0]), .cout(cin[1]), .sum(sum_comb[1]));
    FA FA2 (.a(a[2]), .b(b[2]), .cin(cin[1]), .cout(cin[2]), .sum(sum_comb[2]));
    FA FA3 (.a(a[3]), .b(b[3]), .cin(cin[2]), .cout(cout_comb), .sum(sum_comb[3]));

    // Registering sum and cout on the rising edge of clk
    always @(posedge clk) begin
        sum <= sum_comb; // Register the sum at every clock edge
        cout <= cout_comb; // Register the carry-out at every clock edge
    end

endmodule

// XOR Module (for Half Adder)
module _xor (
    input an,   // Input A for XOR
    input bn,   // Input B for XOR
    output out  // Output of XOR
);
    assign out = (~an & bn) | (an & ~bn);
endmodule

// Half Adder Module
module HA (
    input a,    // First input for HA
    input b,    // Second input for HA
    output cout, // Carry output
    output sum  // Sum output
);
    wire xor_out;  // Intermediate wire for XOR result
    _xor x1 (.an(a), .bn(b), .out(xor_out)); // XOR operation
    assign sum = xor_out;  // Sum is the result of XOR
    assign cout = a & b;   // Carry is the AND of the inputs
endmodule

// Full Adder Module
module FA (
    input a,    // First input for FA
    input b,    // Second input for FA
    input cin,  // Carry-in for FA
    output cout, // Carry-out for FA
    output sum   // Sum output for FA
);
    wire w_sum, w_out1, w_out2;  // Intermediate signals for sum and carry

    // First half adder (adds a and b)
    HA ha1 (.a(a), .b(b), .cout(w_out1), .sum(w_sum));
    // Second half adder (adds cin and the result of the first half adder)
    HA ha2 (.a(cin), .b(w_sum), .cout(w_out2), .sum(sum));
    
    // Final carry-out is the OR of the two carry outputs
    assign cout = w_out1 | w_out2;
endmodule
