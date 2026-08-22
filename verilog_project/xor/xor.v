module xor_gate(
input a,b,
output q
);

  xor (q,a,b);

endmodule


module xor_dataflow(
input a,b,
output q
);

  assign q = a ^ b;

endmodule


module xor_behavioral(
input a,b,
output reg q
);

  always @ (a or b) begin
    q <= a ^ b;
  end

endmodule
