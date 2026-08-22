//wrapper module for 2 1_bit 2to1 nor and 1 1_bit 4to1 nand 
(for zero positive testing,if all bits are 0,output is 1)

module zero_positive_wr(
input [7:0] IN_ZP,
output ZP_BAR
);

//WIRE

wire [3:0] W;


//1_bit 2to1 nor golden module(test if IN_ZP[1:0] is 2'b00)

nor_1_gm IN_01 (
    .a(IN_ZP[0]),
    .b(IN_ZP[1]),
    .q(W[0])
);


//1_bit 2to1 nor golden module(test if IN_ZP[3:2] is 2'b00)
nor_1_gm IN_23 (
    .a(IN_ZP[2]),
    .b(IN_ZP[3]),
    .q(W[1])
);


//1_bit 2to1 nor golden module(test if IN_ZP[5:4] is 2'b00)
nor_1_gm IN_45 (
    .a(IN_ZP[4]),
    .b(IN_ZP[5]),
    .q(W[2])
);



//1_bit 2to1 nor golden module(test if IN_ZP[7:6] is 2'b00)
nor_1_gm IN_67 (
    .a(IN_ZP[6]),
    .b(IN_ZP[7]),
    .q(W[3])
);



//1_bit 4to1 nand golden module(if IN_ZP[7:0] is 8'b00000000,then output 1)
nand_4_gm nand_4_gm (
    .a(W[0]),
    .b(W[1]),
    .c(W[2]),
    .d(W[3]),
    .q(ZP_BAR)
);




endmodule
