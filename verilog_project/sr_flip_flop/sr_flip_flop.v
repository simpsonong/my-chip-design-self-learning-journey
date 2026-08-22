// A sr (set ready) flip-flop which is pulse-triggered can be set and reset.

module sr_flip_flop_gate (
    input       clk,        // Clock
    input       s,          // Inputs
    input       r,          // 
    output      q,          // Output
    output      qbar

);      //



    // INTERNAL WIRES
    wire  q1, qbar1, q2, qbar2, s1, r1;
    reg  prev_q, prev_qbar;


    always@(posedge clk)begin
    #0.12;

    prev_q = q;
    prev_qbar = qbar;

    end

    nand (s1, s, clk);
    nand (r1, r, clk);

    // SR- LATCH -------------------------------------
    
    nand (q1, s1, prev_qbar);
    nand (qbar1, r1, prev_q);

    nand (q, s1, qbar1);
    nand (qbar, r1, q1);


    
    
endmodule   
    


module sr_flip_flop_dataflow(
    input       clk,        // Clock
    input       s,          // Inputs
    input       r,          // 
    output      q,          // Output
    output      qbar);      //


    // INTERNAL WIRES
    wire  q1, qbar1, q2, qbar2, s1, r1;
    reg  prev_q, prev_qbar;


    always@(posedge clk)begin
    #0.12;

    prev_q = q;
    prev_qbar = qbar;

    end  


    assign s1 = ~(s & clk);
    assign r1 = ~(r & clk);

    // SR- LATCH -------------------------------------
    
    assign q1 = ~(s1 & prev_qbar);
    assign qbar1 = ~(r1 & prev_q);

    assign q = ~(s1 & qbar1);
    assign qbar = ~(r1 & q1);   

endmodule


module sr_flip_flop_behavioral (
    input       clk,        // Clock
    input       s,          // Inputs
    input       r,          // 
    output reg  q,          // Output
    output wire qbar);      //


assign qbar = ~q;

always @ ( posedge clk ) begin

    case ({s,r})
    2'b00: q <= q;
    2'b01: q <= 1'b0;
    2'b10: q <= 1'b1;
    2'b11: q <= 1'bx;
    endcase
end




endmodule

