module DECODER_3(
    input A, B, C,
    output x1, x2, x3, x4, x5, x6, x7
);

    assign x1 = A | B | C;  // A + B + C
    assign x2 = B | A;      // B + A
    assign x3 = (B & C) | A; // BC + A
    assign x4 = A;          // A
    assign x5 = (A & C) | (A & B); // AC + AB
    assign x6 = A & B;      // AB
    assign x7 = A & B & C;  // ABC

endmodule
