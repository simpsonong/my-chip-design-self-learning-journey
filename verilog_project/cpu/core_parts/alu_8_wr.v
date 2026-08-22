//wrapper module for 8_bits ALU

module alu_8_wr(
input   [7:0]IN_A,IN_B,
input   [19:15]ALU_FUNC,
input   CIN,
output  [7:0]OUT,
output  C4,C8,
output  Z
);

wire CARRY;
wire NOTHING1,NOTHING2;
wire NOTHING3,NOTHING4;
wire AEQB1,AEQB2;

assign C4 = CARRY;

alu_4_wr alu_4_wr_msb (
    .A     (A[3:0]),
    .B     (B[3:0]),
    .S     (ALU_FUNC[18:15]),
    .M     (ALU_FUNC[19]),
    .CI    (CIN),
    .AEQB  (AEQB1),
    .F0    (OUT[0]),
    .F1    (OUT[1]),
    .F2    (OUT[2]),
    .F3    (OUT[3]),
    .CO    (C4),
    .P_BAR (NOTHING1),
    .G_BAR (NOTHING2)
);


alu_4_wr alu_4_wr_msb (
    .A     (A[7:4]),
    .B     (B[7:4]),
    .S     (ALU_FUNC[18:15]),
    .M     (ALU_FUNC[19]),
    .CI    (CIN),
    .AEQB  (AEQB2),
    .F0    (OUT[4]),
    .F1    (OUT[5]),
    .F2    (OUT[6]),
    .F3    (OUT[7]),
    .CO    (C8),
    .P_BAR (NOTHING3),
    .G_BAR (NOTHING4)
);

and_1_gm and_1_gm1(
.a(AEQB1)
.b(AEQB2)
.y(Z)
);

endmodule
