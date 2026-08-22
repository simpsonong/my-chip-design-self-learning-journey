
module mimic(
 input clk,
 inout Q_gate,QBAR_gate,Q_data,QBAR_data,
 output reg prev_Qgate, prev_Qbargate, prev_Qdata, prev_Qbardata
);



always @ (posedge clk) begin

#0.3;


prev_Qgate = Q_gate;

prev_Qbargate = QBAR_gate;

prev_Qdata = Q_data;

prev_Qbardata = QBAR_data;


end

endmodule

