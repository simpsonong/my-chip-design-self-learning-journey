// A jk (Jack Kilby) flip-flop which is pulse-triggered can be set and reset and by creating a versatile memory element, invalid state is prevented.

module jk_flip_flop_gate (
    input  wire j,
    input  wire k,
    input  wire clk,
    output wire q,
    output wire qbar
);

    wire s, r, q1, qbar1, q2, qbar2;
    reg  prev_q, prev_qbar;


    always@(posedge clk)begin
    #0.12;
    
    prev_q = q;
    prev_qbar = qbar;
    
    end




    nand (s, j, clk, prev_qbar);
    nand (r, k, clk, prev_q);

    nand (q1, s, prev_qbar);
    nand (qbar1, r, prev_q);

    nand (q2, s, qbar1);
    nand (qbar2, r, q1);

    nand (q, s, qbar2);
    nand (qbar, r, q2);

endmodule


module jk_flip_flop_dataflow (
    input  wire j,
    input  wire k,
    input  wire clk,
    output wire q,
    output wire qbar
);


    wire s, r, q1, qbar1, q2, qbar2;
    reg  prev_q, prev_qbar;



    always@(posedge clk)begin
    #0.12;
    
    prev_q = q;
    prev_qbar = qbar;
    
    end

    assign s = ~(j & clk & prev_qbar);
    assign r = ~(k & clk & prev_q);

    assign q1 = ~(s & prev_qbar);
    assign qbar1 = ~(r & prev_q);

    assign q2 = ~(s & qbar1);
    assign qbar2= ~(r & q1);

    assign q = ~(s & qbar2);
    assign qbar =~(r & q2);


endmodule


module jk_flip_flop_behavioral (
    input  wire j,
    input  wire k,
    input  wire clk,
    output reg  q,
    output wire qbar
);

  

    assign qbar = ~q;

    always @(posedge clk) begin
        case ({j,k})
            2'b00: q <= q;        // HOLD
            2'b01: q <= 1'b0;     // RESET
            2'b10: q <= 1'b1;     // SET
            2'b11: q <= ~q;       // TOGGLE
        endcase
    end

endmodule
