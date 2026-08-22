
// 2-input AND gate used in my programable-8-bit-microprocessor

module and_gate(
    input       a, b,     
    output      q
);       

    // GATE PRIMITIVE
    and (q, a, b);

endmodule

module and_dataflow(
    input       a, b,     
    output      q
);       

    // CONTINUOUS ASSIGNMENT STATEMENT

    assign q = a & b;

endmodule

module and_behavioral(
    input       a, b,     
    output reg  q
);       

    // ALWAYS BLOCK with NON-BLOCKING PROCEDURAL ASSIGNMENT STATEMENT
    always @(a or b) begin
        q <= a & b;
    end

endmodule
