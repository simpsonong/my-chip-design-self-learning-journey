module nor_data(
input a,b,
output y
);

  assign y=~(a||b);
  
endmodule
