//wrapper module for ALU_4bits (to convert active LOW to active HIGH)

module alu_4_wr(
input   [3:0]A_BAR,B_BAR,S,
input   M,
input   CI,
output  AEQB,
output  [3:0]F_BAR,
output  CO,
output  P_BAR,
output  G_BAR
);

//WIRE
wire CO_BAR;

//ASSIGN (active LOW to active HIGH)
assign CO = CO_BAR;
assign CI_BAR = ~CI;


//ALU golden module
alu_4_gm alu_4_gm1 (
    .a     (A_BAR),
    .b     (B_BAR),
    .s     (S),
    .m     (M),
    .ci_bar(CI_BAR),
    .aeqb  (AEQB),
    .f0    (F_BAR[0]),
    .f1    (F_BAR[1]),
    .f2    (F_BAR[2]),
    .f3    (F_BAR[3]),
    .co_bar(CO_BAR),
    .x     (P_BAR)
    .y     (G_BAR)
);



endmodule
	
