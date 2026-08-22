//1_bit 2to1 nor golden module

module nor_1_gm(
    input       a, b,
    output      q
);




    // CONTINUOUS ASSIGNMENT STATEMENT

    assign q = ~(a || b);

endmodule
