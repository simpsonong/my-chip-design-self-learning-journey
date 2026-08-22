module register_8_bit_posedge_sync_enable(
input clk,
input en,
input [7:0]d,
output [7:0]q
);

wire NOTHING;

dff_posedge_sync_enable dff_posedge_sync_enable0(.clk(clk),.enable(en),.d(d[0]),.q(q[0]),.qbar(NOTHING));
dff_posedge_sync_enable dff_posedge_sync_enable1(.clk(clk),.enable(en),.d(d[1]),.q(q[1]),.qbar(NOTHING));
dff_posedge_sync_enable dff_posedge_sync_enable2(.clk(clk),.enable(en),.d(d[2]),.q(q[2]),.qbar(NOTHING));
dff_posedge_sync_enable dff_posedge_sync_enable3(.clk(clk),.enable(en),.d(d[3]),.q(q[3]),.qbar(NOTHING));
dff_posedge_sync_enable dff_posedge_sync_enable4(.clk(clk),.enable(en),.d(d[4]),.q(q[4]),.qbar(NOTHING));
dff_posedge_sync_enable dff_posedge_sync_enable5(.clk(clk),.enable(en),.d(d[5]),.q(q[5]),.qbar(NOTHING));
dff_posedge_sync_enable dff_posedge_sync_enable6(.clk(clk),.enable(en),.d(d[6]),.q(q[6]),.qbar(NOTHING));
dff_posedge_sync_enable dff_posedge_sync_enable7(.clk(clk),.enable(en),.d(d[7]),.q(q[7]),.qbar(NOTHING));

endmodule
