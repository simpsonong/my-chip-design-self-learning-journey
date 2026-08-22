module 8_bit_register_clk_enable(
input clk,
input en,
input d0,
input d1,
input d2,
input d3,
input d4,
input d5,
input d6,
input d7,
output q0,
output q2,
output q2,
output q3,
output q4,
output q5,
output q6,
output q7
);

wire NOTHING;

dff_posedge_sync_enable dff_posedge_sync_enable0(.clk(clk),.enable(en),.d(d0),.q(q0),.qbar(NOTHING));
dff_posedge_sync_enable dff_posedge_sync_enable1(.clk(clk),.enable(en),.d(d1),.q(q1),.qbar(NOTHING));
dff_posedge_sync_enable dff_posedge_sync_enable2(.clk(clk),.enable(en),.d(d2),.q(q2),.qbar(NOTHING));
dff_posedge_sync_enable dff_posedge_sync_enable3(.clk(clk),.enable(en),.d(d3),.q(q3),.qbar(NOTHING));
dff_posedge_sync_enable dff_posedge_sync_enable4(.clk(clk),.enable(en),.d(d4),.q(q4),.qbar(NOTHING));
dff_posedge_sync_enable dff_posedge_sync_enable5(.clk(clk),.enable(en),.d(d5),.q(q5),.qbar(NOTHING));
dff_posedge_sync_enable dff_posedge_sync_enable6(.clk(clk),.enable(en),.d(d6),.q(q6),.qbar(NOTHING));
dff_posedge_sync_enable dff_posedge_sync_enable7(.clk(clk),.enable(en),.d(d7),.q(q7),.qbar(NOTHING));

endmodule
