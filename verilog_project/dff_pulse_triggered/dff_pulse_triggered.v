// A d (delay) flip-flop which is pulse-triggered can be set and reset.

module dff_pulse_triggered_gate (
    input       clk,        // Clock
    input       clk2,
    input       d,          
    output      q,          
    output      qbar
);



    // INTERNAL WIRES
    wire q2,qbar2, q3, qbar3, s, r, s1, r1, s2, r2;

    reg  prev_q, prev_qbar, prev_q2, prev_qbar2;


    always@(posedge clk)begin
    #0.12;

    prev_q = q;
    prev_qbar = qbar;
    prev_q2 = q2;
    prev_qbar2 = qbar2;

    end

    assign s = d;
    assign r = ~d;


    // NAND3
    nand (s1, s, clk);

    // NAND4
    nand (r1, r, clk);

    // SR- LATCH -------------------------------------

    nand (q1, s1, prev_qbar2);
    nand (qbar1, r1, prev_q2);
  
    nand (q2, s1, qbar1);
    nand (qbar2, r1, q1);

//SRFF

    nand (s2, q2, clk2);
    nand (r2, qbar2, clk2);

    // SR- LATCH -------------------------------------


    nand (q3, s2, prev_qbar);
    nand (qbar3, r2, prev_q);

    nand (q, s2, qbar3);
    nand (qbar, r2, q3);
   

endmodule



module dff_pulse_triggered_dataflow(
    input       clk,        // Clock
    input       clk2,
    input       d,          
    output      q,          
    output      qbar);      




    // INTERNAL WIRES
    wire q2,qbar2, q3, qbar3, s, r, s1, r1, s2, r2;
    reg  prev_q, prev_qbar, prev_q2, prev_qbar2;


    always@(posedge clk)begin
    #0.12;

    prev_q = q;
    prev_qbar = qbar;
    prev_q2 = q2;
    prev_qbar2 = qbar2;

    end

    assign s = d;
    assign r = ~d;


    // NAND3
    assign s1 = ~(s & clk);

    // NAND4
    assign r1 = ~(r & clk);

    // SR- LATCH -------------------------------------

    assign q1 = ~(s1 & prev_qbar2);
    assign qbar1 = ~(r1 & prev_q2);

    assign q2 = ~(s1 & qbar1);
    assign qbar2 = ~(r1 & q1);


//SRFF

    assign s2 = ~(q2 & clk2);
    assign r2 = ~(qbar2 & clk2);

    // SR- LATCH -------------------------------------


    assign q3 = ~(s2 & prev_qbar);
    assign qbar3 = ~(r2 & prev_q);

    assign q = ~(s2 & qbar3);
    assign qbar = ~(r2 & q3);



endmodule



module dff_pulse_triggered_behavioral (
    input        clk,        // Clock
    input        clk2,
    input        d,          //
    output reg   q,          // Output
    output wire  qbar
);

assign qbar = ~q;

always @ ( posedge clk ) begin

    if (clk2) begin

    q <= d;

    end else begin
    
    q <= q;

    end

end




endmodule
