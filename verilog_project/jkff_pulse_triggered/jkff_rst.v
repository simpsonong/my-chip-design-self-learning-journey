// A jk (Jack Kilby) flip-flop which is pulse-triggered can be set and reset and by creating a versatile memory element, invalid state is prevented.

module jk_flip_flop_gate (
    input  wire j,
    input  wire k,
    input  wire clk,
    input  wire clk2, 
    input  wire q_prev,
    input  wire qbar_prev,
    input  wire q3_prev,
    input  wire qbar3_prev,
    output wire q3,
    output wire qbar3,
    output wire q,
    output wire qbar
    
);

    wire q1, qbar1, q2, qbar2, q4, qbar4;
    wire s1, r1, s, r;

//JKFF

    nand (s1, j, clk, qbar_prev);
    nand (r1, k, clk, q_prev);

    // SR- LATCH -------------------------------------

    nand (q1, s1, qbar3_prev);
    nand (qbar1, r1, q3_prev);

    nand (q2, s1, qbar1);
    nand (qbar2, r1, q1);

    nand (q3, s1, qbar2);
    nand (qbar3, r1, q2);

//SRFF

    nand (s, q3, clk2);
    nand (r, qbar3, clk2);

    // SR- LATCH -------------------------------------

    
    nand (q4, s, qbar_prev);
    nand (qbar4, r, q_prev);

    nand (q, s, qbar4);
    nand (qbar, r, q4);



endmodule


module jk_flip_flop_dataflow (
    input  wire j,
    input  wire k,
    input  wire clk,
    input  wire clk2,
    input  wire q_prev,
    input  wire qbar_prev,
    input  wire q3_prev,
    input  wire qbar3_prev,
    output wire q3,
    output wire qbar3,
    output wire q,
    output wire qbar
);


  
    wire q1, qbar1, q2, qbar2, q4, qbar4;
    wire s1, r1, s, r;

//JKFF

    assign s1 = ~(j & clk & qbar_prev);
    assign r1 = ~(k & clk & q_prev);

    // SR- LATCH -------------------------------------

    assign q1 = ~(s1 & qbar3_prev);
    assign qbar1 = ~(r1 & q3_prev);

    assign q2 = ~(s1 & qbar1);
    assign qbar2 = ~(r1 & q1);

    assign q3 = ~(s1 & qbar2);
    assign qbar3 = ~(r1 & q2);

//SRFF

    assign s = ~(q3 & clk2);
    assign r = ~(qbar3 & clk2);

    // SR- LATCH -------------------------------------

    
    assign q4 = ~(s & qbar_prev);
    assign qbar4 = ~(r & q_prev);

    assign q = ~(s & qbar4);
    assign qbar = ~(r & q4);



endmodule


module jk_flip_flop_behavioral (
    input  wire j,
    input  wire k,
    input  wire clk,
    input  wire clk2,
    output reg  q,
    output wire qbar
);

    assign qbar = ~q;

    always @(posedge clk) begin
        case ({j,k,clk2})
            3'b001: q <= q;        // HOLD
            3'b011: q <= 1'b0;     // RESET
            3'b101: q <= 1'b1;     // SET
            3'b111: q <= ~q;       // TOGGLE
        
            default: q <= q;

        endcase
    end

endmodule
