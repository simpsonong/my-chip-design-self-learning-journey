//4_bits 2to1 multiplexer golden module

module mux_4_gm(
input [3:0] a,b,
input sel,
input en,
output reg [3:0] y
);


always@(a or b or sel or en)begin

if(!en)begin
y = 4'b0000;
end

else begin

case(sel)
1'b0: y = a;
1'b1: y = b;
endcase

end

end

endmodule

