
module buttons_pressed(
input clk,
input pressed,
output reg out
);

always@(posedge clk)begin

if(pressed)
out <= 1'b1;

else

out <= 1'b0;

end

endmodule



module buttons_lock(
input clk,
input pressed,
output reg out
);

reg lock =1'b0;

always@(posedge clk)begin

if(pressed & ~lock)begin
out <= 1'b1;
lock <= 1'b1;
end

else if (~pressed & lock)begin
out <= 1'b0;
lock <= 1'b0;
end

else
out <= 1'b0;

end

endmodule



module buttons_toggle(
input clk,
input pressed,
output reg out
);

reg lock = 1'b0;
reg toggle;

assign out = toggle;

always@(posedge clk)begin
#0.1;
toggle = out;
end

always@(posedge clk)begin

if(pressed && ~lock)begin
toggle <= ~toggle;
lock <= 1'b1;
end

else if (~pressed & lock)begin
lock <= 1'b0;
end


end

endmodule

