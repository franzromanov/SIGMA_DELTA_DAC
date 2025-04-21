module Decoder_8 (
    input A, B, C, D,
    output x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15


    assign x1  = A | B | C | D;
    assign x2  = A | B | C;
    assign x3  = A | B | (C & D);
    assign x4  = A | B;
    assign x5  = (B & D) | (B & C) | A;
    assign x6  = (B & C) | A;
    assign x7  = (B & C & D) | A;
    assign x8  = A;
    assign x9  = (A & B) | (A & D) | (A & C);
    assign x10 = (A & B) | (A & C);
    assign x11 = (A & C & ~D) | (A & B);
    assign x12 = A & B;
    assign x13 = (A & B & D) | (A & B & C);
    assign x14 = A & B & C;
    assign x15 = A & B & C & D;


endmodule
