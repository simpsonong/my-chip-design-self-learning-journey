module sr_latch_gate(
input s, r,
output q, qbar
);

reg prev_q, prev_qbar;

always@(*) begin
#0.12;
prev_q = q;
prev_qbar = qbar;

end

nand (q1, s, prev_qbar);
nand (qbar1, r, prev_q);

nand (q, s, qbar1);
nand (qbar, r, q1);

endmodule



module sr_latch_dataflow(
input s, r,
output q, qbar
);

reg prev_q, prev_qbar;

always@(*) begin
#0.12;
prev_q = q;
prev_qbar = qbar;

end

 assign q1 = ~ ( s && prev_qbar);
 assign qbar1 = ~ ( r && prev_q);

 assign q = ~ ( s && qbar1);
 assign qbar = ~ ( r && q1);

endmodule




 module sr_latch_behavioral(
 input s, r, 
 output prev_q,
 output prev_qbar,
 output reg q, 
 output qbar
 );



 assign qbar = ~q ;
 

 always @ (*) begin

 case ({s,r})
 2'b00 : q <= 1'bx;
 2'b01 : q <= 1'b1;
 2'b10 : q <= 1'b0;
 2'b11 : q <= q;
 endcase

 end

endmodule

