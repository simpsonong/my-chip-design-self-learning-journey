// A jk (Jack Kilby) flip-flop which is pulse-triggered can be set and reset and by creating a versatile memory element, invalid state is prevented.

module t_flip_flop_gate (
    input  wire t,
    input  wire clk,
    output wire q,
    output wire qbar
);


    wire j ,k ,s ,r ,q1, qbar1, q2, qbar2;

    reg  prev_q, prev_qbar;

    
    always@(posedge clk)begin
    #0.12;

    prev_q = q;
    prev_qbar = qbar;
    
    end
    
    assign j = t;
    assign k = t;

    nand (s, j, clk, prev_qbar);
    nand (r, k, clk, prev_q);

    nand (q1, s, prev_qbar);
    nand (qbar1, r, prev_q);

    nand (q2, s, qbar1);
    nand (qbar2, r, q1);

    nand (q, s, qbar2);
    nand (qbar, r, q2);


endmodule


module t_flip_flop_dataflow (
    input  wire t,
    input  wire clk,
    output wire q,
    output wire qbar
);

    wire j ,k, s, r, q1, qbar1, q2, qbar2;
    
    reg  prev_q, prev_qbar;

    
    always@(posedge clk)begin
    #0.2;

    prev_q = q;
    prev_qbar = qbar;
    
    end

    assign j = t;
    assign k = t;


    assign s = ~(j & clk & prev_qbar);
    assign r = ~(k & clk & prev_q);

    assign q1 = ~(s & prev_qbar);
    assign qbar1 = ~(r & prev_q);

    assign q2 = ~(s & qbar1);
    assign qbar2= ~(r & q1);

    assign q = ~(s & qbar2);
    assign qbar =~(r & q2);


endmodule


module t_flip_flop_behavioral (
    input  wire t,
    input  wire clk,
    output reg  q,
    output wire qbar
);
                 
  
 
    assign qbar = ~q;

    always @(posedge clk) begin
        case (t)
            1'b0: q <= q;        // HOLD
            1'b1: q <= qbar;     // TOGGLE
        endcase
    end

endmodule
