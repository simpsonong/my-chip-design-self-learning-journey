//wrapper module for 4_bits multiplexer
module mux_4_wr(
input [3:0] A,B,
input S,
input EN_BAR,
output reg [3:0] Y
);

//WIRE
wire EN;

//ASSIGN (active LOW to active HIGH)
assign EN = ~EN_BAR;


//4_bit multiplexer golden module

mux_4_gm 1 (
    .a(A),
    .b(B),
    .sel(S),
    .en(EN),
    .y(Y)
);




endmodule
