module multiplexer_1bit_8to1(
input a,b,c,
input [7:0]d,
output reg y,
output w
);

assign w=~y;

always@(a or b or c or d) begin

case ({a,b,c})
3'b000: y = d[0]; 
3'b001: y = d[1];
3'b010: y = d[2];
3'b011: y = d[3];
3'b100: y = d[4];
3'b101: y = d[5];
3'b110: y = d[6];
3'b111: y = d[7];
endcase

end

endmodule
