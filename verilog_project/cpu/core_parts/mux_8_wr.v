//wrapper module for 8_bits 2to1 mutiplexer

module mux_8_wr(
input [7:0] A,B,
input S,
input EN_BAR,
output reg [7:0] Y
);


//ASSIGN (active LOW to active HIGH)
assign EN = ~EN_BAR;



//4bits multiplexer golden module lsb

mux_4_gm mux_4_gm_lsb (
    .a(A[3:0]),
    .b(B[3:0]),
    .sel(S),
    .en(EN),
    .y(Y[3:0])
);



//4bits multiplexer golden module msb

mux_4_gm mux_4_gm_lsb (
    .a(A[7:4]),
    .b(B[7:4]),
    .sel(S),
    .en(EN),
    .y(Y[7:4])
);



endmodule
