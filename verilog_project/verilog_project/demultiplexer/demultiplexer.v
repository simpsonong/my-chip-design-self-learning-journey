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
