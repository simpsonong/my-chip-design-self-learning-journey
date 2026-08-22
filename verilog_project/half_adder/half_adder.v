module half_adder_gate(
input a,b,
output sum,
output cout
);

xor xor1(sum,a,b);
and and1(cout,a,b);

endmodule


module half_adder_dataflow(
input a,b,
output sum,
output cout
);

assign sum = a^b;
assign cout = a&b;


endmodule


module half_adder_behavioral(
input a,b,
output reg sum,
output reg cout
);

always@(a or b)begin

{cout,sum} <= a + b;

end

endmodule
