// A d (delay) flip-flop which is pulse-triggered can be set and reset.

module d_flip_flop_gate (
    input       clk,        // Clock
    input       clk1,
    input       d,          //
    output      q,          // Output
    output      qbar
);

     

    // INTERNAL WIRES
    wire   s, r, s1, r1;
    
    assign s = d;
    assign r = ~d;
    

    // NAND3
    nand (s1, s, clk);

    // NAND4
    nand (r1, r, clk);

    // SR- LATCH -------------------------------------

    // NAND1
    nand (q, s1, qbar);

    // NAND2
    nand (qbar, r1, q);



endmodule



module d_flip_flop_dataflow(
    input       clk,        // Clock
    input       d,          //
    output      q,          // Output
    output      qbar);      //


    // INTERNAL WIRES
    wire   s, r, s1, r1;
    
    assign s = d;
    assign r = ~d;
    
    // NAND3
    assign s1 = ~(s & clk);

    // NAND4
    assign r1 = ~(r & clk);

    // SR- LATCH -------------------------------------

    // NAND1
    assign q = ~(s1 & qbar);

    // NAND2
    assign qbar = ~(r1 & q);


endmodule

module d_flip_flop_behavioral (
    input        clk,        // Clock
    input        d,          //
    output reg   q,          // Output
    output wire  qbar
);      

assign qbar = ~q;

always @ ( posedge clk ) begin

    case ( d )

    1'b0: q = 1'b0;
    1'b1: q = 1'b1;

    endcase
end




endmodule
