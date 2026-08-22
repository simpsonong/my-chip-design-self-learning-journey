
module priority_arbiter(
input clk,
input rst, //reset
input [3:0] req, //request
output [3:0] gnt //grant
);

always@ (posedge clk or posedge rst)begin

if(rst) begin
gnt <= 4'b0000;
end

else if(req[0])begin
gnt <= 4'b0001;
end

else if(req[1])begin
gnt <= 4'b0010;
end

else if(req[2])begin
gnt <= 4'b0100;
end

else if(req[3])begin
gnt <= 4'b1000;
end

else begin
gnt <= 4'b0000;
end

end


endmodule
