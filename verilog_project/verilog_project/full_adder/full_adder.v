module full_adder_gate(
input a,b,
input cin,
output sum,
output cout
);

wire w1,w2,w3;

xor xor1(w1,a,b);
xor xor2(sum,w1,cin);
and and1(w2,w1,cin);
and and2(w3,a,b);
or  or1(cout,w2,w3);

endmodule


module full_adder_dataflow(
input a,b,
input cin,
output sum,
output cout
);

assign sum = a^b^cin;
assign cout = a&b | (a^b)&cin;


endmodule


module full_adder_behavioral(
input a,b,
input cin,
output reg sum,
output reg cout
);

always@(a or b or cin)begin

{cout,sum} <= a + b + cin;

end

endmodule

