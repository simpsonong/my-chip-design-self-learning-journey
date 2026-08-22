//wrapper module for 4_bits counter (to convert active LOW to active HIGH)

module counter_4_wr(
input CLK,
input CLR_BAR,
input LD_BAR,
input ENT,
input ENP,
input [3:0]DATA_IN,
output [3:0]DATA_OUT,
output RCO
);

//4_bits counter golden module

counter_4_gm counter_4_gm1 (
    .clk(CLK),
    .clrbar(CLR_BAR),
    .ent(ENT),
    .enp(ENP),
    .ld_bar(LD_BAR),
    .data(DATA_IN),
    .q(DATA_OUT),
    .cout(RCO)
);


endmodule
