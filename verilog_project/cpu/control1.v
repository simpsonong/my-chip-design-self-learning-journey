//CONTROL_SECTION

module control(
input CLK,
input [7:0]DATA_IN_A,
input [7:0]DATA_IN_B,
input RESET,
input JAM,
input GO_BAR,
input [3:0]OPCODE,
input [23:0]MICROWORD,
input [3:0]STATUS_BIT,
output [23:13]CONTROL_BITS;
output [7:0]MICORADRESS,
output EIL_BAR
);

//WIRE
wire [7:0] BUFFER_IN;
wire LOW,
wire HIGH,
wire [7:0] HIGH_8;
wire COUNTER_IN_HIGH_SIG;
wire NOTHING;
wire COND_OUT;
wire MPC_LOAD_BAR;

wire [12:9]BOP;
wire COUNT;
wire [7:4]MICROAD_HIGH;
wire [3:0]MICROAD_LOW;


//ASSIGN
//convert microword to vectors
assign CONTROL_BITS = MICROWORD[23:13];
assign BOP = MICROWORD[12:9];            //branch
assign COUNT = MICROWORD[8];             //enable parallel(enp) signal for count
assign MICROAD_HIGH = MICROWORD[7:4];    //msb 4_bits for microadress
assign MICROAD_LOW = MICROWORD[3:0];     //lsb 4_bits for microadress

//general assign
assign LOW = 1'b0;
assign HIGH = 1'b1; //not used in here,but maybe use if future active status changes(ex. active low to active high or vice versa)
assign HIGH_8=8'b11111111;



//8_bits counter
//to increase MICROADRESS 1 at a time to link the microsteps of bigger function

counter_8 COUNTER_8(
.COUNTER_IN_LOW(MICORAD_LOW),
.COUNTER_IN_HIGH(COUNTER_IN_HIGH_SIG),
.COUNT(COUNT),
.MPC_LOAD_BAR(MPC_LOAD_BAR),   //MICRO PROGRAMME COUNTER
.RESET(RESET),
.SYSTEM_CLK(SYSTEM_CLK)
.COUNTER_OUT(BUFFER_IN),
);


//8_bits 2to1 multiplexer
//to jam all process upon receive jam signal from testbench
//by choosing the microadress directing to the function jam

mux_8 MUX8(
.A8(BUFFER_IN),
.B8(HIGH_8),
.S(JAM),
.EN(LOW),
.Y8(MICROAD)
);



//OPCODE
//to examine whether all microsteps of a function is completed,
//if completed get new OPCODE from testbench as the msb of the MICROADRESS to start new function
//if not completed use the msb of the microaddress define by the microstep and continue until all microsteps is finish

OPCODE OPCODE1(
.MICROAD_HIGH(MICROAD_HIGH),
.OPCODE(OPCODE),
.BOP(BOP),
.TO_COUNTER(COUNTER_IN_HIGH_SIG)
.EIL_BAR(EIL_BAR)
);


//1_bit 8to1 multiplexer
//used for examine whether a condition is true
//(in this case conditions are C4,C8,Z,ZP_BAR from processor),
//if true output Y=1 W=~Y(active LOW,W as final output signal)
//otherwise output Y=0 W=~Y(active LOW,W as final output signal)

mux_8_to_1 COND_SELECT(
.D0(STATUS_BITS[2]),
.D1(LOW),
.D2(STATUS_BITS[0]),
.D3(STATUS_BITS[1]),
.D4(GO_BAR),
.D5(STATUS_BITS[3]),
.D6(LOW),
.D7(LOW),
.A(BOP[9]),
.B(BOP[10]),
.C(BOP[11]),
.Y(NOTHING),
.W(COND_OUT)
);


//COUNTER_LD
//output MPC_LOAD_BAR=1 if condition is fulfill
//to decide the state of ENP
//hence decide whether the counter should continue counting
//(BOP[12]=1 means active HIGH,BOP[12]=0 means active LOW)


xor_2 COND_OUT_COUNTER_LD(
.A(BOP[12]),
.B(COND_OUT),
.Y(MPC_LOAD_BAR)
);


endmodule
