//1_bit 4to1 nand golden module

module nand_4_gm(
    input       a,b,c,d,
    output      q
);

    // CONTINUOUS ASSIGNMENT STATEMENT

    assign q = ~(a & b & c & d);

endmodule


