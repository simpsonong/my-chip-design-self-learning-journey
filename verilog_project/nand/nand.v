
// 2-input NAND gate used in my programable-8-bit-microprocessor

module nand_gate(
    input       a, b,
    output      q
);

    // GATE PRIMITIVE
    nand (q, a, b);

endmodule

module nand_dataflow(
    input       a, b,
    output      q
);

    // CONTINUOUS ASSIGNMENT STATEMENT

    assign q = ~(a & b);

endmodule

module nand_behavioral(
    input       a, b,
    output reg  q
);

    // ALWAYS BLOCK with NON-BLOCKING PROCEDURAL ASSIGNMENT STATEMENT
    always @(a or b) begin
        q <= ~(a & b);
    end

endmodule
