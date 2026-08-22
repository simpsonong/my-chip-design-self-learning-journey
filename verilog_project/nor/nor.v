
// 2-input NOR gate used in my programable-8-bit-microprocessor

module nor_gate(
    input       a, b,
    output      q
);

    // GATE PRIMITIVE
    nor (q, a, b);

endmodule

module nor_dataflow(
    input       a, b,
    output      q
);

    // CONTINUOUS ASSIGNMENT STATEMENT

    assign q = ~( a || b);

endmodule

module nor_behavioral(
    input       a, b,
    output reg  q
);

    // ALWAYS BLOCK with NON-BLOCKING PROCEDURAL ASSIGNMENT STATEMENT
    always @(a or b) begin
        q <= ~( a || b);
    end

endmodule
