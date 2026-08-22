module opcode(
input [3:0] BOP,
input [3:0]OP_CODE,
input [3:0]MICROAD_HIGH,
output [3:0] TO_COUNTER,
output EIL_BAR
);

wire LOW;

assign LOW = 1'b0;
assign EIL_BAR = W;

mux_4 TO_COUNTER(
.A4(OPCODE),
.B4(MICROAD_HIGH),
.S(W)
.EN_BAR(LOW)
.Y4(TO_COUNTER)
);

nand_4 EIL_BAR(
.A(BOP[0]),
.B(BOP[1]),
.C(BOP[2]),
.D(BOP[3]),
.Y(W)
);

endmodule
