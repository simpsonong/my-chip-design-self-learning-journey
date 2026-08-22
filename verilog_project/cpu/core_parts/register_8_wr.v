//wrapper module for 8_bits register

module register_8_wr(
input SYSTEM_CLK,
input ENABLE_CLK,
input [7:0]DATA_IN,
output [7:0]DATA_OUT
);


//WIRE

wire EN;
wire LOW;
wire W1;


//ASSIGN
assign LOW = 1'b0;
assign EN = ~LOW;


//limit the control signal to clk only in golden module

or_1_gm or_1_gm1(
.a(SYSTEM_CLK),
.b(ENABLE_CLK),
.y(W1)
);


//8_bits register golden module

register_8_gm register_8_gm1(
    .clk(W1),
    .en(EN),
    .d(DATA_IN),
    .q(DATA_OUT)
);





endmodule
