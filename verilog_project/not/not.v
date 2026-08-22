module not_gate(
    input       a,    
    output      q
);      

    not (q, a);

endmodule



module not_dataflow(
    input       a,    
    output      q
);      

    assign q = ~a;

endmodule



module not_behavioral(
    input       a,     
    output reg  q
);       

    always @(a) begin
        q <= ~a;
    end

endmodule
