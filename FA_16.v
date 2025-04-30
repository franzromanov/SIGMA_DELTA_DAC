module FA_16 (clck, a, b, s_cin, cout, sum);
    input [15:0] a, b;
    input s_cin, clck;
    output reg cout;
    output reg [15:0] sum;
    
    wire [15:0] sum_comb;
    wire [14:0] cin;
    wire cout_comb;

    // Full adder instances (combinational logic)
    FA FA0 (.a(a[0]), .b(b[0]), .cin(s_cin), .cout(cin[0]), .sum(sum_comb[0]));
    FA FA1 (.a(a[1]), .b(b[1]), .cin(cin[0]), .cout(cin[1]), .sum(sum_comb[1]));
    FA FA2 (.a(a[2]), .b(b[2]), .cin(cin[1]), .cout(cin[2]), .sum(sum_comb[2]));
    FA FA3 (.a(a[3]), .b(b[3]), .cin(cin[2]), .cout(cin[3]), .sum(sum_comb[3]));
    FA FA4 (.a(a[4]), .b(b[4]), .cin(cin[3]), .cout(cin[4]), .sum(sum_comb[4]));
    FA FA5 (.a(a[5]), .b(b[5]), .cin(cin[4]), .cout(cin[5]), .sum(sum_comb[5]));
    FA FA6 (.a(a[6]), .b(b[6]), .cin(cin[5]), .cout(cin[6]), .sum(sum_comb[6]));
    FA FA7 (.a(a[7]), .b(b[7]), .cin(cin[6]), .cout(cin[7]), .sum(sum_comb[7]));
    FA FA8 (.a(a[8]), .b(b[8]), .cin(cin[7]), .cout(cin[8]), .sum(sum_comb[8]));
    FA FA9 (.a(a[9]), .b(b[9]), .cin(cin[8]), .cout(cin[9]), .sum(sum_comb[9]));
    FA FA10 (.a(a[10]), .b(b[10]), .cin(cin[9]), .cout(cin[10]), .sum(sum_comb[10]));
    FA FA11 (.a(a[11]), .b(b[11]), .cin(cin[10]), .cout(cin[11]), .sum(sum_comb[11]));
    FA FA12 (.a(a[12]), .b(b[12]), .cin(cin[11]), .cout(cin[12]), .sum(sum_comb[12]));
    FA FA13 (.a(a[13]), .b(b[13]), .cin(cin[12]), .cout(cin[13]), .sum(sum_comb[13]));
    FA FA14 (.a(a[14]), .b(b[14]), .cin(cin[13]), .cout(cin[14]), .sum(sum_comb[14]));
    FA FA15 (.a(a[15]), .b(b[15]), .cin(cin[14]), .cout(cout_comb), .sum(sum_comb[15]));





    // Registering outputs on clock edge
    always @(posedge clck) begin
        sum <= sum_comb;
        cout <= cout_comb;
    end

endmodule


// XOR module
module _xor(an, bn, out);
    input an, bn;
    output out;
    assign out = ( ~an & bn ) | ( an & ~bn );
endmodule
// Finished

// Half Adder
module HA(a, b, cout, sum);
    input a, b;
    output cout, sum;
    
    wire xor_out;
    _xor x1 (.an(a), .bn(b), .out(xor_out));
    assign sum = xor_out;
    assign cout = a & b;
endmodule
// Finished

// Full Adder
module FA(a, b, cin, cout, sum);
    input a, b, cin;
    output cout, sum;
    wire w_sum, w_out1, w_out2;
    
    HA ha1 (.a(a), .b(b), .cout(w_out1), .sum(w_sum));
    HA ha2 (.a(cin), .b(w_sum), .cout(w_out2), .sum(sum));
    assign cout = w_out1 | w_out2;
endmodule
// Finished
