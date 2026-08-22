//wrapper module for 8_bits counter

module counter8(
    input  [3:0]    COUNTER_IN_LOW,     // 
    input  [7:4]    COUNTER_IN_HIGH,    // 
    input           MPC_LOAD_BAR,       //
    input           RESET,              //
    input           COUNT,              //
    input           SYSTEM_CLK,         // 
    output [7:0]    COUNTER_OUT         // 
);


//WIRES
wire HIGH;
wire CARRY;
wire NOTHING;

//ASSIGN VALUES
assign HIGH = 1'b1;


//COUNTER1 - 4-bit synchronous counter

counter_4_gm counter_4_gm_lsb (
    .cllk(SYSTEM_CLK),
    .clrbar(RESET),
    .ld_bar(MPC_LOAD_BAR),
    .ent(HIGH),
    .enp(COUNT),
    .data(COUNTER_IN_LOW),
    .q(COUNTER_OUT[3:0]),
    .cout(CARRY)
);


//COUNTER1 - 4-bit synchronous counter

counter_4_gm counter_4_gm_msb (
    .cllk(SYSTEM_CLK),
    .clrbar(RESET),
    .ld_bar(MPC_LOAD_BAR),
    .ent(HIGH),
    .enp(COUNT),
    .data(COUNTER_IN_HIGH),
    .q(COUNTER_OUT[7:4]),
    .cout(NOTHING)
);



endmodule
