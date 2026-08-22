//8_bits PROCESSOR

module processor(
input [23:13] CONTROL_BITS,
input [7:0] DATA_IN_A,DATA_IN_B,
input SYSTEM_CLK,
input EIL_BAR,
output [7:0] DATA_OUT,
output [3:0] STATUS_BITS
);

//WIRE
wire [23:21] ALU_DEST;
wire CIN;
wire [19:15]ALU_FUNC;
wire B_SOURCE;
wire A_SOURCE;
wire [7:0]MUX_IN_A;
wire [7:0]MUX_IN_B;
wire [7:0]MUX_IN_TA;
wire [7:0]MUX_IN_TB;
wire [7:0]ALU_IN_A;
wire [7:0]ALU_IN_B;
wire ALU_OUT;
wire IN_ZP;
wire LOW;



//ASSIGN

assign ALU_DEST = CONTROL_BITS[23:21];
assign CIN = CONTROL_BITS[20];
assign ALU_FUNC = CONTROL_BITS[19:15];
assign B_SOURCE = CONTROL_BITS[14];
assign A_SOURCE = CONTROL_BITS[13];

assign LOW = 1'b0;
assign DATA_OUT = IN_ZP //IN Zero Positive

//8_bits register (to recorrd DATA_IN_A and B)

register_8 register_a(
.DATA_IN(DATA_IN_A),
.CLK(SYSTEM_CLK),
.EN(EIL_BAR),
.DATA_OUT(MUX_IN_A)
);

register_8 register_b(
.DATA_IN(DATA_IN_B),
.CLK(SYSTEM_CLK),
.EN(EIL_BAR),
.DATA_OUT(MUX_IN_B)
);


//8_bits register
//(to record outcome of ALU to enable the modification of ALU_OUT,ex.ALU+A，ALU+B)

register_8 temp_register_a(
.DATA_IN(ALU_OUT0),
.CLK(SYSTEM_CLK),
.EN(ALU_DEST[23]),
.DATA_OUT(MUX_IN_TA)       //MUX INPUT TEMPORARY A
);

register_8 temp_register_b(
.DATA_IN(ALU_OUT),
.CLK(SYSTEM_CLK),
.EN(ALU_DEST[22]),
.DATA_OUT(MUX_IN_TB)
);

//8_bits 2to1 multiplexer
//(to choose whether using ALU_OUT or DATA_IN_A for ALU_IN_A)
mux_8 MUX_8_A(
.A8(MUX_IN_A),
.B8(MUX_IN_TA),
.S(A_SOURCE),
.EN(LOW),
.Y8(ALU_IN_A)
);



//8_bits 2to1 multiplexer
//(to choose whether using ALU_OUT or DATA_IN_B for ALU_IN_B)
mux_8 MUX_8_A(
.A8(MUX_IN_B),
.B8(MUX_IN_TB),
.S(B_SOURCE),
.EN(LOW),
.Y8(ALU_IN_B)
);



//8_bits arithmetic and logic unit(ALU)

alu8 ALU1(
.DATA_IN_A(ALU_IN_A),
.DATA_IN_B(ALU_IN_B),
.CIN(CIN),
.M(ALU_FUNC[19]),
.S(ALU_FUNC[18:15]),
.ALU_OUT(ALU_OUT),
.C4(STATUS_BITS[0]),
.C8(STATUS_BITS[1]),
.Z(STATUS_BITS[2])

);


//8_bits register
//(to record outcome of ALU for verification via testbench and do ZERO POSITIVE test)


register_8 f_register(
.DATA_IN(ALU_OUT),
.CLK(SYSTEM_CLK),
.EN(ALU_DEST[21]),
.DATA_OUT(IN_ZP)
);



//ZERO POSITIVE test

zero_positive ZP1(
.IN(IN_ZP)
.ZP_BAR(STATUS_BITS[3])
);





endmodule
