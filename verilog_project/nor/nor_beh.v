module nor_beh(
input a,b,
output reg y
);

  always@(a or b) begin
    y=~(a||b);
  end
  
endmodule

