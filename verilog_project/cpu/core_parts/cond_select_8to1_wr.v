//wrapper module for 1_bit 8to1 multiplexer (for condition select)

module cond_select_8to1_wr(
input A,B,C,
input [7:0]D,
input EN_BAR,
output reg Y,
output W
);

//WIRE
wire EN;


//ASSIGN (active LOW to active HIGH)
assign EN= ~EN_BAR;


//8to1 multiplexer golden module (for condition select)

cond_select_8to1_gm cond_select_8to1_gm1 (
    .a(A),
    .b(B),
    .c(C),
    .d(D),
    .en(EN),
    .y(Y),
    .w(W)
);





endmodule
