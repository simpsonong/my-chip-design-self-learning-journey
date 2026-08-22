// A jk (Jack Kilby) flip-flop which is pulse-triggered can be set and reset and by creating a versatile memory element, invalid state is prevented`.
`timescale 1ns/ 10ps
module jkff_pulse_triggered_gate (
    input  wire j,
    input  wire k,
    input  wire clk,
    input  wire clk2, 
    output wire q,
    output wire qbar
    
);

    wire q1, qbar1, q2, qbar2, q3, qbar3, q4, qbar4;
    wire s1, r1, s, r;
    reg prev_q, prev_qbar, prev_q3, prev_qbar3;

    always@(posedge clk)begin
    #0.12;

    prev_q = q;
    prev_qbar = qbar;
    prev_q3 = q3;
    prev_qbar3 = qbar3;    

    end


//JKFF

    nand (s1, j, clk, prev_qbar);
    nand (r1, k, clk, prev_q);

    // SR- LATCH -------------------------------------

    nand (q1, s1, prev_qbar3);
    nand (qbar1, r1, prev_q3);

    nand (q2, s1, qbar1);
    nand (qbar2, r1, q1);

    nand (q3, s1, qbar2);
    nand (qbar3, r1, q2);

//SRFF

    nand (s, q3, clk2);
    nand (r, qbar3, clk2);

    // SR- LATCH -------------------------------------

    
    nand (q4, s, prev_qbar);
    nand (qbar4, r, prev_q);

    nand (q, s, qbar4);
    nand (qbar, r, q4);



endmodule


module jkff_pulse_triggered_dataflow (
    input  wire j,
    input  wire k,
    input  wire clk,
    input  wire clk2,
    output wire q,
    output wire qbar
);

    
  
    wire q1, qbar1, q2, qbar2, q3, qbar3, q4, qbar4;
    wire s1, r1, s, r;
    reg prev_q, prev_qbar, prev_q3, prev_qbar3;


   
    always@(posedge clk)begin
    #0.12;

    prev_q = q;
    prev_qbar = qbar;
    prev_q3 = q3;
    prev_qbar3 = qbar3;    

    end

//JKFF

    assign s1 = ~(j & clk & prev_qbar);
    assign r1 = ~(k & clk & prev_q);

    // SR- LATCH -------------------------------------

    assign q1 = ~(s1 & prev_qbar3);
    assign qbar1 = ~(r1 & prev_q3);

    assign q2 = ~(s1 & qbar1);
    assign qbar2 = ~(r1 & q1);

    assign q3 = ~(s1 & qbar2);
    assign qbar3 = ~(r1 & q2);

//SRFF

    assign s = ~(q3 & clk2);
    assign r = ~(qbar3 & clk2);

    // SR- LATCH -------------------------------------

    
    assign q4 = ~(s & prev_qbar);
    assign qbar4 = ~(r & prev_q);

    assign q = ~(s & qbar4);
    assign qbar = ~(r & q4);



endmodule


module jkff_pulse_triggered_behavioral (
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
