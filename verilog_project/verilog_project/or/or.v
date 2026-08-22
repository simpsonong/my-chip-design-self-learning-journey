module or_gate(
input a,b,
output q
);

  or (q,a,b);
  
endmodule


module or_dataflow(
input a,b,
output q
);

  assign q = a||b;
  
endmodule


module or_behavioral(
input a,b,
output reg q
);

  always@(a or b) begin
    q <= a||b;
  end
  
endmodule

