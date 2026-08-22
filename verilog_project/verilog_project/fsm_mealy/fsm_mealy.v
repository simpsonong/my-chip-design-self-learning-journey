
module fsm_mealy(
input clk,
input rst,
input in,
output reg found
);

parameter [2:0] 
START = 3'b000,
ZERO1 = 3'b001,
ZERO2 = 3'b010,
ONE1  = 3'b011,
ONE2  = 3'b100,
MATCH = 3'b101;

reg [2:0] state,next_state;

always@(*)begin

case(state)

START: begin

if(in == 0)begin
next_state = ZERO1;
found = 1'b0;
end

else begin
next_state = START;
found = 1'b0;
end
end



ZERO1: begin

if(in == 0)begin
next_state = ZERO2;
found = 1'b0;
end

else begin
next_state = START;
found = 1'b0;
end
end



ZERO2: begin

if(in == 1)begin
next_state = ONE1;
found = 1'b0;
end

else begin
next_state = ZERO2;
found = 1'b0;
end
end



ONE1: begin

if(in == 1)begin
next_state = ONE2;
found = 1'b0;
end

else begin
next_state = ZERO1;
found = 1'b0;
end
end



ONE2: begin

if(in == 0)begin
next_state = MATCH;
found = 1'b1;
end

else begin
next_state = START;
found = 1'b0;
end
end



MATCH: begin

if(in == 1)begin
next_state = START;
found = 1'b0;
end

else begin
next_state = ZERO2;
found = 1'b0;
end
end

default: found = 1'b0;

endcase

end


always@(posedge clk) begin
if(rst)begin
state <= START;
end

else begin
state <= next_state;
end

end


endmodule
