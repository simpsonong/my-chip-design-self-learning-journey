module mux_to_demux(
input a,b,c,d,
input [1:0] sel,
output a_out, b_out, c_out, d_out
);

wire y;

multiplexer_4to1 dut_multiplexer_4to1(.sel(sel), .a(a), .b(b), .c(c), .d(d), .y(y));
demultiplexer dut_demultiplexer(.sel(sel), .y(y), .a(a_out), .b(b_out), .c(c_out), .d(d_out));


endmodule

module multiplexer_4to1(
input a,b,c,d,
input [1:0] sel,
output reg y
);

always@(a or b or c or d or sel)begin


case(sel)
2'b00: y = a;
2'b01: y = b;
2'b10: y = c;
2'b11: y = d;

endcase


end

endmodule

module demultiplexer(
input y,
input [1:0]sel,
output reg a,b,c,d
);

always@(y or sel) begin

case(sel)
2'b00: begin
a = y; b = 1'b0; c = 1'b0; d = 1'b0;
end
2'b01: begin
a = 1'b0; b = y; c = 1'b0; d = 1'b0;
end
2'b10: begin
a = 1'b0; b = 1'b0; c = y; d = 1'b0;
end
2'b11: begin
a = 1'b0; b = 1'b0; c = 1'b0; d = y;
end

endcase

end

endmodule
